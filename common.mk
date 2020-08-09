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

-include device/sony/customization/customization.mk

# Enable building packages from device namspaces.
# Might be temporary! See:
# https://android.googlesource.com/platform/build/soong/+/master/README.md#name-resolution
PRODUCT_SOONG_NAMESPACES += \
    $(PLATFORM_COMMON_PATH) \
    vendor/qcom/opensource/core-utils \
    hardware/qcom/gps \
    vendor/qcom/opensource/location

# \
    hardware/qcom/display/sde

# Common path
COMMON_PATH := device/sony/common

# Build for primary target arch only, instead of 32-bit
AUDIOSERVER_MULTILIB := first

# Build scripts
SONY_CLEAR_VARS := $(COMMON_PATH)/sony_clear_vars.mk
SONY_BUILD_SYMLINKS := $(COMMON_PATH)/sony_build_symlinks.mk

DEVICE_PACKAGE_OVERLAYS += $(COMMON_PATH)/overlay

PRODUCT_ENFORCE_RRO_TARGETS := *

PRODUCT_DEXPREOPT_SPEED_APPS += SystemUI

# Google GSI public keys for /avb
# Needed for official GSIs while maintaining AVB and vbmeta.
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)
ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
# Developer GSI images
# https://developer.android.com/topic/generic-system-image/releases
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)
endif

# OVERRIDE_PRODUCT_ENFORCE_PRODUCT_PARTITION_INTERFACE := false

# Force using the following regardless of shipping API level:
#   PRODUCT_TREBLE_LINKER_NAMESPACES
#   PRODUCT_SEPOLICY_SPLIT
#   PRODUCT_ENFORCE_VINTF_MANIFEST
#   PRODUCT_NOTICE_SPLIT
PRODUCT_FULL_TREBLE_OVERRIDE := false
PRODUCT_ENFORCE_VINTF_MANIFEST_OVERRIDE := false

# VNDK
# Force using VNDK regardless of shipping API level
PRODUCT_USE_VNDK_OVERRIDE := true
# Include vndk/vndk-sp/ll-ndk modules
PRODUCT_PACKAGES += \
    vndk_package

# Force building a recovery image: Needed for OTA packaging to work since Q
PRODUCT_BUILD_RECOVERY_IMAGE := true

# Force building a boot image. This needs to be set explicitly since Android R
PRODUCT_BUILD_BOOT_IMAGE := true

# Android R: Disable logic for new vendor_boot
# Our devices do not support it
PRODUCT_BUILD_VENDOR_BOOT_IMAGE := false

SOMC_KERNEL_VERSION := mainline
KERNEL_PATH := kernel/$(SOMC_KERNEL_VERSION)

# Sanitized prebuilt kernel headers
-include $(KERNEL_PATH)/common-headers/KernelHeaders.mk

# Codecs Configuration
PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video.xml

# Common etc
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/system/etc/nfcee_access.xml:system/etc/nfcee_access.xml

# GPS Configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/gps.conf:$(TARGET_COPY_OUT_VENDOR)/etc/gps.conf


# QMI Configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/qmi_fw.conf:$(TARGET_COPY_OUT_VENDOR)/etc/qmi_fw.conf

# QMI
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/data/dsi_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/data/dsi_config.xml \
    $(COMMON_PATH)/rootdir/vendor/etc/data/netmgr_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/data/netmgr_config.xml \
    $(COMMON_PATH)/rootdir/vendor/etc/data/qmi_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/data/qmi_config.xml

# QSEECOM TZ Storage
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/gpfspath_oem_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/gpfspath_oem_config.xml

# Sec Configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/sec_config:$(TARGET_COPY_OUT_VENDOR)/etc/sec_config

# Seccomp policy
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/seccomp_policy/imsrtp.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/imsrtp.policy \
    $(COMMON_PATH)/rootdir/vendor/etc/seccomp_policy/mediacodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy

# Audio Configuration
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/a2dp_in_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_in_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml

# Additional native libraries
# See https://source.android.com/devices/tech/config/namespaces_libraries
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/public.libraries.txt:$(TARGET_COPY_OUT_VENDOR)/etc/public.libraries.txt

# ramdump cleaner
PRODUCT_PACKAGES_DEBUG += \
    rdclean.sh

# Depend on symlink creation in /vendor:
PRODUCT_PACKAGES += \
    adreno_symlinks \
    camera_symlinks \
    qca_cld3_symlinks \
    rfsa_symlinks \
    tftp_symlinks

# Create firmware mount point folders in /vendor:
PRODUCT_PACKAGES += \
    firmware_folders


ifeq ($(MODEM_CONFIG_LEGACY_PLATFORM),true)
MODEM_CONFIG := $(shell find $(COMMON_PATH)/rootdir/vendor/oem/modem-config-legacy -type f -printf '%p:$(TARGET_COPY_OUT_VENDOR)/oem/modem-config/%P\n')
else
MODEM_CONFIG := $(shell find $(COMMON_PATH)/rootdir/vendor/oem/modem-config -type f -printf '%p:$(TARGET_COPY_OUT_VENDOR)/oem/modem-config/%P\n')
endif
PRODUCT_COPY_FILES += $(MODEM_CONFIG)

# Bluetooth
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/sysconfig/component-overrides.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sysconfig/component-overrides.xml

-include device/sony/customization/customization.mk

USE_SODP_APNS ?= true
ifeq ($(USE_SODP_APNS),true)
# Community APN list
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/rootdir/vendor/etc/apns-conf.xml:system/etc/apns-conf.xml
endif #USE_SODP_APNS

$(call inherit-product, device/sony/common/common-init.mk)
$(call inherit-product, device/sony/common/common-odm.mk)
$(call inherit-product, device/sony/common/common-odm-camx.mk)
$(call inherit-product, device/sony/common/common-odm-mmcam.mk)
$(call inherit-product, device/sony/common/common-packages.mk)
$(call inherit-product, device/sony/common/common-perm.mk)
$(call inherit-product, device/sony/common/common-prop.mk)
$(call inherit-product, device/sony/common/common-treble.mk)
$(call inherit-product, device/sony/common/common-binds.mk)
