# RenderScript HAL
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

# Composer
PRODUCT_PACKAGES += \
    vendor.qti.hardware.display.composer-service

# Linked by Adreno/EGL blobs for fallback if 3.0 doesn't exist
PRODUCT_PACKAGES += \
    vendor.qti.hardware.display.mapper@2.0.vendor

# Graphics allocator/mapper
ifeq ($(TARGET_HARDWARE_GRAPHICS_V3),true)

PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@3.0-impl-qti-display \
    android.hardware.graphics.mapper@4.0-impl-qti-display

# android.hardware.graphics.allocator@3.0::IAllocator, and
# android.hardware.graphics.allocator@4.0::IAllocator if
# TARGET_USES_GRALLOC4 is not explicitly set to `false`:
PRODUCT_PACKAGES += \
    vendor.qti.hardware.display.allocator-service

else

PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@2.0-impl:64 \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.mapper@2.0-impl-2.1

endif

# Memtrack
PRODUCT_PACKAGES += \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service

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
