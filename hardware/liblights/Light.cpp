/*
 * Copyright (C) 2016 The Android Open Source Project
 * Copyright (C) 2018 Shane Francis
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "lights.sony"

#include <android-base/logging.h>
#include <fstream>
#include <ios>

#include "Light.h"

#ifdef UCOMMSVR_BACKLIGHT
extern "C" {
#include <comm_server/ucomm_ext.h>
}
#endif

namespace android {
namespace hardware {
namespace light {
namespace V2_0 {
namespace implementation {

Light::Light()
{
    LOG(INFO) << __func__ << ": Setup HAL";

    mLastBacklightMode = Brightness::USER;

    mBacklightMax = readInt(LCD_MAX_FILE);

    if (mBacklightMax < 0) {
        LOG(WARNING) << "Max backlight value " << mBacklightMax << " invalid. Using 255";
        mBacklightMax = 255;
    }

    // Bit-shifting optimization does not work above 2^16-1:
    if (mBacklightMax < (1 << 16)) {
        // Find most significant bit:
        int backlightHighestBit = 32 - __builtin_clz((unsigned)mBacklightMax);
        // Bit-shift optimization scales to full 2^x-1; make sure
        // mBacklightMax equals this full set of bits:
        if (mBacklightMax == (1 << backlightHighestBit) - 1)
            // Input value is already 1<<8:
            mBacklightShift = std::max(0, backlightHighestBit - 8);
    }
}

// Methods from ::android::hardware::light::V2_0::ILight follow.
Return<Status> Light::setLight(Type type, const LightState &state)
{
    switch (type) {
    case Type::BACKLIGHT:
        LOG(DEBUG) << __func__ << " : Type::BACKLIGHT";
        setLightBacklight(state);
        break;
    case Type::BATTERY:
        LOG(DEBUG) << __func__ << " : Type::BATTERY";
        setLightBattery(state);
        break;
    case Type::NOTIFICATIONS:
        LOG(DEBUG) << __func__ << " : Type::NOTIFICATIONS";
        setLightNotifications(state);
        break;
    default:
        LOG(DEBUG) << __func__ << " : Unknown light type";
        return Status::LIGHT_NOT_SUPPORTED;
    }
    return Status::SUCCESS;
}

int Light::writeInt(const std::string &path, int value)
{
    std::ofstream stream(path);

    if (!stream) {
        LOG(ERROR) << "Failed to open " << path << ", error=" << errno
                   << "(" << strerror(errno) << ")";
        return -errno;
    }

    LOG(INFO) << path << " = " << value;

    stream << value << std::endl;

    return 0;
}

int Light::readInt(const std::string &path)
{
    std::ifstream stream(path);
    int value = 0;

    if (!stream) {
        LOG(ERROR) << "Failed to open " << path << ", error=" << errno
                   << "(" << strerror(errno) << ")";
        return -errno;
    }

    stream >> value;

    return value;
}

int Light::writeStr(const std::string &path, const std::string &value)
{
    std::ofstream stream(path);

    if (!stream) {
        LOG(ERROR) << "Failed to open " << path << ", error=" << errno
                   << "(" << strerror(errno) << ")";
        return -errno;
    }

    LOG(INFO) << path << " = " << value;

    stream << value << std::endl;

    return 0;
}

std::string Light::getScaledDutyPcts(int brightness, int idle_brightness)
{
    std::string buf, pad;

    if (brightness <= 0) {
        return "0";
    }

    for (auto i : BRIGHTNESS_RAMP) {
        buf += pad;
        buf += std::to_string((i * brightness + (100 - i) * idle_brightness) / 255);
        pad = ",";
    }

    return buf;
}

int Light::isLit(const LightState &state)
{
    return state.color & 0x00ffffff;
}

bool Light::isRgbSyncAvailable()
{
    std::ifstream stream(RGB_BLINK_FILE);
    return stream.good();
}

int Light::rgbToBrightness(const LightState &state)
{
    int color = state.color & 0x00ffffff;
    return ((77 * ((color >> 16) & 0x00ff))
               + (150 * ((color >> 8) & 0x00ff)) + (29 * (color & 0x00ff)))
        >> 8;
}

int Light::setLightBacklight(const LightState &state)
{
    std::lock_guard<std::mutex> lock(mLcdLock);

    int err = 0;
    int brightness = rgbToBrightness(state);
#ifdef LOW_PERSISTENCE_DISPLAY
    Brightness currState = state.brightnessMode;
    bool lpEnabled = state.brightnessMode == Brightness::LOW_PERSISTENCE;
#endif

#ifdef LOW_PERSISTENCE_DISPLAY
    // If we're not in lp mode and it has been enabled or if we are in lp mode
    // and it has been disabled send an ioctl to the display with the update
    if ((mLastBacklightMode != currState && lpEnabled) || (!lpEnabled && mLastBacklightMode == Brightness::LOW_PERSISTENCE)) {
        if ((err = writeInt(PERSISTENCE_FILE, lpEnabled)) != 0) {
            LOG(ERROR) << __func__ << " : Failed to write to " << PERSISTENCE_FILE << ": " << strerror(errno);
        }
        if (lpEnabled != 0) {
            // Try to get the brigntess though property, otherwise it will
            // set the default brightness, which is defined in BoardConfig.mk.
            brightness = property_get_int32(LP_MODE_BRIGHTNESS_PROPERTY,
                DEFAULT_LOW_PERSISTENCE_MODE_BRIGHTNESS);
        }
    }
    mLastBacklightMode = state.brightnessMode;
#endif

    if (!err) {
        if (brightness > 10)
            // TODO: This value is ONLY for calculating a rescaled LED.
            // Since we do not recalculate it based on the light intensity sensor values,
            // make sure it never goes to zero.
            // More importantly, make sure the very low brightness in AOD doesn't set the
            // LED extremely dim on a day.
            mLastBrightness = brightness;

        if (mBacklightShift) {
            // Use bit-shifting optimizations:
            // (For demo/"coolness" purposes only; saved cycles are negligible)
            brightness = brightness << mBacklightShift | brightness >> 8 - mBacklightShift;
        } else if (mBacklightMax != 255) {
            // Adding half of the max (255/2=127) provides proper rounding while staying in integer mode:
            brightness = (brightness * mBacklightMax + 127) / 255;
        }
#ifdef UCOMMSVR_BACKLIGHT
        err = ucommsvr_set_backlight(brightness);
#else
        err = writeInt(LCD_FILE, brightness);
#endif
    }

    if (isLit(batteryState) || isLit(notificationState)) {
        // Update LED only if it is turned on.
        // (We should also check whether mLastBrightness changed)
        std::lock_guard<std::mutex> lock(mLock);
        setNotificationLEDLocked();
    }

    return err;
}

static uint32_t scaleColor(uint32_t rgb, int factor)
{
    // Poor-mans SIMD:
    uint32_t rb = (rgb & 0xff00ff) * factor / 255;
    return rb | (rgb & 0xff00) * factor / 255;
}

int Light::setNotificationLEDLocked()
{
    int red, green, blue;
    bool blink;
    int onMS, offMS;
    LightState state;
    uint32_t rgb = 0, base_rgb = 0;

    if (isLit(batteryState) && isLit(notificationState)) {
        LOG(INFO) << "battery and notification lit";
        // If in a notification+battery state, try to merge the colors.
        // The battery provides the base, with the blinks blending it to
        // the notification color briefly.
        // Yes, this will cause a discrepancy with a green notification on
        // a fully charged battery. Can be fixed by introducing extra off.
        // (So, ramp from battery to off, then to notification, back to off, then to battery)
        if (batteryState.flashMode != Flash::NONE) {
            // Low batter, or something like that. See if we can merge two flashing lights.
            state = batteryState;
        } else {
            if (notificationState.flashMode == Flash::NONE)
                LOG(WARNING) << "Vague non-blinking notification. Blink-blending with battery anyway";
            state = notificationState;
            base_rgb = batteryState.color;
            if (mLastBrightness > 0 && /* Sanity check only: */ mLastBrightness < 256)
                base_rgb = scaleColor(base_rgb, mLastBrightness);
            LOG(INFO) << std::hex << "base_rgb " << base_rgb;
        }

    } else if (isLit(batteryState)) {
        state = batteryState;
    } else {
        state = notificationState;
    }

    switch (state.flashMode) {
    case Flash::TIMED:
        onMS = state.flashOnMs;
        offMS = state.flashOffMs;
        break;
    case Flash::NONE:
    default:
        onMS = 0;
        offMS = 0;
        break;
    }

#if 0
    LOG(DEBUG) << "set_speaker_light_locked mode " << state->flashMode <<
            " colorRGB=" << colorRGB << " onMS=" << onMS << " offMS=" << offMS;
#endif

    rgb = state.color;

    if (mLastBrightness > 0 && /* Sanity check only: */ mLastBrightness < 256)
        rgb = scaleColor(rgb, mLastBrightness);

    LOG(INFO) << std::hex << "Rescaling LED color from " << state.color << " to " << rgb;

    red = rgb >> 16 & 0xFF;
    green = rgb >> 8 & 0xFF;
    blue = rgb & 0xFF;
    blink = onMS > 0 && offMS > 0;

    if (isRgbSyncAvailable()) {
        writeInt(RGB_BLINK_FILE, 0);
    }

    if (blink) {
        if (isRgbSyncAvailable()) {
            writeStr(RED_LED_DUTY_PCTS_FILE, getScaledDutyPcts(red, base_rgb >> 16 & 0xff));
            writeStr(GREEN_LED_DUTY_PCTS_FILE, getScaledDutyPcts(green, base_rgb >> 8 & 0xff));
            writeStr(BLUE_LED_DUTY_PCTS_FILE, getScaledDutyPcts(blue, base_rgb & 0xff));

            writeInt(RED_LED_BASE + "pause_lo", offMS);
            writeInt(GREEN_LED_BASE + "pause_lo", offMS);
            writeInt(BLUE_LED_BASE + "pause_lo", offMS);

            writeInt(RED_LED_BASE + "pause_hi", onMS);
            writeInt(GREEN_LED_BASE + "pause_hi", onMS);
            writeInt(BLUE_LED_BASE + "pause_hi", onMS);

            writeInt(RGB_BLINK_FILE, 1);
        } else {
            if (red) {
                if (writeInt(RED_BLINK_FILE, onMS == offMS ? 2 : 1)) {
                    writeInt(RED_LED_FILE, 0);
                }
            }
            if (green) {
                if (writeInt(GREEN_BLINK_FILE, onMS == offMS ? 2 : 1)) {
                    writeInt(GREEN_LED_FILE, 0);
                }
            }
            if (blue) {
                if (writeInt(BLUE_BLINK_FILE, onMS == offMS ? 2 : 1)) {
                    writeInt(BLUE_LED_FILE, 0);
                }
            }
        }
    } else {
        writeInt(RED_LED_FILE, red);
        writeInt(GREEN_LED_FILE, green);
        writeInt(BLUE_LED_FILE, blue);
    }

    return 0;
}

int Light::setLightBattery(const LightState &state)
{
    std::lock_guard<std::mutex> lock(mLock);

    LOG(INFO) << std::hex << __func__ << ": " << state.color;

    batteryState = state;
    setNotificationLEDLocked();
    return 0;
}

int Light::setLightNotifications(const LightState &state)
{
    std::lock_guard<std::mutex> lock(mLock);

    LOG(INFO) << std::hex << __func__ << ": " << state.color;

    notificationState = state;
    setNotificationLEDLocked();
    return 0;
}

static const std::vector<Type> kSupportedTypes = {
    Type::BACKLIGHT,
    Type::BATTERY,
    Type::NOTIFICATIONS,
};

Return<void> Light::getSupportedTypes(getSupportedTypes_cb _hidl_cb)
{
    hidl_vec<Type> hidl_types{ kSupportedTypes };

    _hidl_cb(hidl_types);

    return Void();
}
} // namespace implementation
} // namespace V2_0
} // namespace light
} // namespace hardware
} // namespace android
