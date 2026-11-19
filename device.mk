#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_CHARACTERISTICS := phone

# Inherit proprietary files
$(call inherit-product, vendor/samsung/a54x/a54x-vendor.mk)

# Enable project quotas and casefolding for emulated storage without sdcardfs
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Soong namespaces
$(call inherit-product, hardware/samsung_slsi-linaro/config/config.mk)

# Soong Namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/google/interfaces \
    hardware/google/pixel/pixelstats \
    hardware/google/pixel/usb \
    hardware/google/pixel/power-libperfmgr \
    hardware/google/pixel/thermal \
    hardware/samsung \
    hardware/samsung_slsi-linaro/exynos/cpboot_v3 \
    hardware/samsung_slsi-linaro/exynos/libaudio/audiohal_comv1 \
    hardware/samsung_slsi-linaro/exynos/libaudio/audiohal_comv1/proxy \
    hardware/samsung_slsi/libbt \
    hardware/samsung_slsi/scsc_wifibt/wpa_supplicant_lib

# Setup dalvik vm configs
$(call inherit-product, frameworks/native/build/phone-xhdpi-4096-dalvik-heap.mk)

# Dynamic Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# HIDL
# TODO(b/330696629) remove this once device can drop HIDL.
PRODUCT_PACKAGES += \
    hwservicemanager \
    android.hidl.allocator@1.0-service

# Update
AB_OTA_UPDATER := false
PRODUCT_SOONG_NAMESPACES += bootable/deprecated-ota

# Kernel
PRODUCT_SET_DEBUGFS_RESTRICTIONS := true
PRODUCT_ENABLE_UFFD_GC := true

# Kernel Modules
PRODUCT_PACKAGES += \
    toolbox.vendor_ramdisk

# fastbootd
PRODUCT_PACKAGES += \
    fastbootd

# Init
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/init/fstab.s5e8835:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/fstab.s5e8835 \
    $(LOCAL_PATH)/configs/init/fstab.s5e8835:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.s5e8835 \
    $(LOCAL_PATH)/configs/init/fstab.s5e8835:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.s5e8835 \
    $(LOCAL_PATH)/configs/init/init.s5e8835.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.s5e8835.rc \
    $(LOCAL_PATH)/configs/init/init.recovery.s5e8835.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.s5e8835.rc \
    $(LOCAL_PATH)/configs/init/init.samsung.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.samsung.rc \
    $(LOCAL_PATH)/configs/init/ueventd.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Init
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/init/init.s5e8835.unify.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.s5e8835.unify.rc

# Libinit
$(call soong_config_set,libinit,vendor_init_lib,//$(LOCAL_PATH)/configs/init/libinit:libinit_s5e8835)

# Placeholders
EMPTY_PLACEHOLDER := $(LOCAL_PATH)/configs/placeholder

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/placeholder.xml:$(TARGET_COPY_OUT_VENDOR)/etc/floating_feature.xml \
    $(EMPTY_PLACEHOLDER):$(TARGET_COPY_OUT_VENDOR)/firmware/AIE.bin \
    $(EMPTY_PLACEHOLDER):$(TARGET_COPY_OUT_VENDOR)/firmware/calliope_sram.bin \
    $(EMPTY_PLACEHOLDER):$(TARGET_COPY_OUT_VENDOR)/firmware/mfc_fw.bin \
    $(EMPTY_PLACEHOLDER):$(TARGET_COPY_OUT_VENDOR)/firmware/os.checked.bin \
    $(EMPTY_PLACEHOLDER):$(TARGET_COPY_OUT_VENDOR)/firmware/pablo_icpufw.bin \
    $(EMPTY_PLACEHOLDER):$(TARGET_COPY_OUT_VENDOR)/firmware/vts.bin

# Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl:64 \
    android.hardware.gatekeeper@1.0-service
