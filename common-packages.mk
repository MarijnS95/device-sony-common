# Copyright (C) 2014 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# TEMPORARY: These libraries are deprecated, not referenced by any AOSP
# nor OSS HAL, but are still required by odm blobs (short term).
# We don't add a dependency on the vndk variants as those end up in
# /system but require these in /vendor instead:
PRODUCT_PACKAGES += \
    libhwbinder.vendor \
    libhidltransport.vendor

# TODO Local package in crosshatch \
    libqcomvoiceprocessingdescriptors \

# Camera
PRODUCT_PACKAGES += camera.v4l2

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.1-service.btlinux

# Audio
PRODUCT_PACKAGES += \
    audio.a2dp.default:64 \
    audio.bluetooth.default:64 \
    audio.hearing_aid.default:64 \
    audio.r_submix.default:64 \
    audio.usb.default:64

# Audio deps
PRODUCT_PACKAGES += \
    libfmq

# GFX
PRODUCT_PACKAGES += \
    libhdmi

PRODUCT_PACKAGES += \
    gralloc.gbm \
    hwcomposer.drm \
    libGLES_mesa \
    gallium_dri

PRODUCT_PACKAGES += \
    memtrack.default

# NFC packages
PRODUCT_PACKAGES += \
    NfcNci \
    Tag

# OSS Time service
PRODUCT_PACKAGES += \
    timekeep \
    TimeKeep \

# OSS Power HAL
# PRODUCT_PACKAGES += \
#     librqbalance

# OSS WIFI and BT MAC tool
PRODUCT_PACKAGES += \
    macaddrsetup

# RIL
PRODUCT_PACKAGES += \
    libandroid_net \
    libprotobuf-cpp-full

# FIXME: master: compat for libprotobuf
# See https://android-review.googlesource.com/c/platform/prebuilts/vndk/v28/+/1109518
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full-vendorcompat

# RenderScript
PRODUCT_PACKAGES += \
    librsjni

# libRSDriver_adreno dependency
PRODUCT_PACKAGES += \
    libLLVM

# ExtendedSettings
PRODUCT_PACKAGES += \
    ExtendedSettings

# Charger
PRODUCT_PACKAGES += \
    charger_res_images

# AOSP Packages
PRODUCT_PACKAGES += \
    Launcher3QuickStep \
    libion \
    libjson \
    libxml2 \

# External exFat tools
PRODUCT_PACKAGES += \
    mkfs.exfat \
    fsck.exfat

# For config.fs
PRODUCT_PACKAGES += \
    fs_config_files \
    fs_config_dirs

PRODUCT_PACKAGES += \
    ODMVersionCheck
