# RenderScript HAL
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

# Composer
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.3-impl:64 \
    android.hardware.graphics.composer@2.3-service \

PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@2.0-impl:64 \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.mapper@2.0-impl-2.1
    # android.hardware.graphics.mapper@2.0-service \

# Memtrack
PRODUCT_PACKAGES += \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service

PRODUCT_PACKAGES += \
    android.hardware.health@2.0-service \
    android.hardware.health@2.0-impl

# Configstore
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.1-service

# RIL
# Interface library needed by odm blobs:
PRODUCT_PACKAGES += \
    android.hardware.radio@1.4 \
    android.hardware.radio.config@1.2

# Audio
# android.hardware.soundtrigger@2.2-impl:32 \
# android.hardware.broadcastradio@1.0-impl \

PRODUCT_PACKAGES += \
    android.hardware.audio@6.0-impl:64 \
    android.hardware.audio.service \
    android.hardware.audio.effect@6.0-impl:64 \
    android.hardware.bluetooth.audio@2.0-impl \
    android.hardware.soundtrigger@2.2-impl

# NFC packages
PRODUCT_PACKAGES += \
    android.hardware.nfc@1.2-service

# DRM
PRODUCT_PACKAGES += \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service-lazy \
    android.hardware.drm@1.3-service-lazy.clearkey

ifneq ($(BOARD_USE_LEGACY_USB),true)
# Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service
else
# Simple Usb HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service.basic
endif

# Power
PRODUCT_PACKAGES += \
    android.hardware.power@1.3-service.sony

ifeq ($(AB_OTA_UPDATER),true)
# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-impl.recovery \
    android.hardware.boot@1.0-service
endif
#
# Default keymaster service provides "insuecure" software implementation:
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.0-service

# NOTE: gatekeeperd, that uses the gatekeeper HAL falls back to software
# gatekeeper internally when the HAL is not found.
# Unfortunately the HAL is required for FCM compatibility,
# so we might want to add back the fake "secure" one from goldfish.

# PRODUCT_PACKAGES += \
#     android.hardware.gatekeeper@1.0-impl \
#     android.hardware.gatekeeper@1.0-service \
#     gatekeeper.loire
#
# PRODUCT_PROPERTY_OVERRIDES += \
#     ro.hardware.gatekeeper=loire

# android.hardware.gatekeeper@1.0-service.software
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-service.software

