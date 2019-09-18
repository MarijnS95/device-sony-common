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

# TODO Local package in crosshatch \
    libqcomvoiceprocessingdescriptors \

# Audio deps
PRODUCT_PACKAGES += \
    libfmq

# GFX
PRODUCT_PACKAGES += \
    libhdmi \
    libqdutils \
    libqdMetaData

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
