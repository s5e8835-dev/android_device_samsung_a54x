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
    hardware/samsung_slsi-linaro/exynos/gralloc/gralloc4 \
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

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio.effect@7.0-impl \
    android.hardware.audio@7.1-impl \
    android.hardware.audio.service \
    android.hardware.bluetooth.audio-impl \
    audio.bluetooth.default \
    audio.primary.s5e8835 \
    audio.r_submix.default \
    audio.usb.default

$(call soong_config_set,samsungAudioVars,soundbooster_dsp_library,//vendor/samsung/a54x:lib_SoundBooster_ver1100)

PRODUCT_PACKAGES += \
    SamsungDAP \
    libsamsungSoundbooster_plus \
    SoundBoosterStage

PRODUCT_COPY_FILES += \
    frameworks/av/services/audiopolicy/config/bluetooth_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration_7_0.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/enginedefault/config/example/phone/audio_policy_engine_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_engine_configuration.xml \
    frameworks/av/services/audiopolicy/enginedefault/config/example/phone/audio_policy_engine_default_stream_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_engine_default_stream_volumes.xml \
    frameworks/av/services/audiopolicy/enginedefault/config/example/phone/audio_policy_engine_product_strategies.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_engine_product_strategies.xml \
    frameworks/av/services/audiopolicy/enginedefault/config/example/phone/audio_policy_engine_stream_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_engine_stream_volumes.xml \
    $(LOCAL_PATH)/configs/audio/audio_board_info.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_board_info.xml \
    $(LOCAL_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    $(LOCAL_PATH)/configs/audio/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths.xml \
    $(LOCAL_PATH)/configs/audio/mixer_usb_default.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_usb_default.xml \
    $(LOCAL_PATH)/configs/audio/mixer_usb_gray.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_usb_gray.xml \
    $(LOCAL_PATH)/configs/audio/mixer_usb_white.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_usb_white.xml

TARGET_EXCLUDES_AUDIOFX := true

$(call soong_config_set_bool,exynos_audio,support_direct_multi_channel_stream,true)
$(call soong_config_set_bool,exynos_audio,use_camcorder_quad_mic,true)
$(call soong_config_set_bool,exynos_audio,use_offload_effect_library,true)
$(call soong_config_set_bool,exynos_audio,use_quad_mic,true)
$(call soong_config_set_bool,exynos_audio,use_sec_audio_samsungrecord,true)
$(call soong_config_set_bool,exynos_audio,use_sec_audio_support_gamechat_spk_aec,true)
$(call soong_config_set_bool,exynos_audio,use_usb_offload,true)
$(call soong_config_set,exynos_audio,predefined_low_capture_duration,20)
$(call soong_config_set,exynos_audio,proxy_header,//$(LOCAL_PATH):audio_proxy_headers)
$(call soong_config_set,exynos_audio,sec_resampler_library,//vendor/samsung/a54x:libSamsungPostProcessConvertor)

# android.hardware.audio feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml

# Charger
PRODUCT_PACKAGES += \
    charger_res_images_vendor

# Health
PRODUCT_PACKAGES += \
    android.hardware.health-service.samsung \
    android.hardware.health-service.samsung-recovery

# Lineage Health
$(call soong_config_set,lineage_health,fast_charge_node,/sys/class/sec/switch/afc_disable)
$(call soong_config_set,lineage_health,fast_charge_value_none,1)
$(call soong_config_set,lineage_health,fast_charge_value_fast_charge,0)

PRODUCT_PACKAGES += vendor.lineage.health-service.default

# Display
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@4.0-service \
    android.hardware.graphics.mapper@4.0-impl

PRODUCT_PACKAGES += \
    android.hardware.composer.hwc3-service.slsi

# Graphics
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := 450dpi
PRODUCT_AAPT_PREBUILT_DPI := xxxhdpi xxhdpi xhdpi hdpi

# Memtrack
PRODUCT_PACKAGES += \
    android.hardware.memtrack-service.samsung-mali

# Public Libraries
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/linker/public.libraries.txt:$(TARGET_COPY_OUT_VENDOR)/etc/public.libraries.txt

# android.hardware.opengles feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml

# android.hardware.vulkan feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml \
    frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
    frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml

# Display
PRODUCT_PACKAGES += \
    displayconfig.xml

# Codec2
PRODUCT_PACKAGES += \
    samsung.hardware.media.c2-service \
    media_codecs_c2.xml \
    media_codecs_performance_c2.xml \

PRODUCT_PACKAGES += \
    media_profiles_V1_0.xml \
    libExynosC2H264Dec \
    libExynosC2H264Enc \
    libExynosC2HevcDec \
    libExynosC2HevcEnc \
    libExynosC2Vp8Dec \
    libExynosC2Vp8Enc

PRODUCT_PACKAGES += \
    codec2.vendor.base.policy \
    codec2.vendor.ext.policy

# DRM
PRODUCT_PACKAGES += \
    com.android.hardware.drm.clearkey

# Camera
PRODUCT_PACKAGES += \
    libvpl

$(call soong_config_set_bool,camera,ext_lib,true)
$(call soong_config_set,libcameraservice,ext_lib,//$(LOCAL_PATH)/configs/camera:libcameraservice_extension.a54x)

# android.hardware.camera feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.ar.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.ar.xml \
    frameworks/native/data/etc/android.hardware.camera.autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml \
    frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml

# Power
PRODUCT_PACKAGES += \
    android.hardware.power-service.pixel-libperfmgr

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/power/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.pixel \
    thermal_symlinks

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/thermal/thermal_info_config.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json

# Task profiles
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/task_profiles.json:$(TARGET_COPY_OUT_VENDOR)/etc/task_profiles.json

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors-service.samsung-multihal \
    sensors.samsung

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/sensors/hals.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sensors/hals.conf

# Touch HAL
PRODUCT_PACKAGES += \
    vendor.lineage.touch-service.samsung

# android.hardware.sensor feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml

# android.hardware.touchscreen feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb-service.samsung \
    android.hardware.usb.gadget-service.samsung

$(call soong_config_set,samsungUsbGadgetVars,gadget_name,13200000.dwc3)

# android.hardware.usb feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/init/init.s5e8835.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.s5e8835.usb.rc

# Vibrator
PRODUCT_PACKAGES += \
    android.hardware.vibrator-service.s5e8835

$(call soong_config_set_bool,samsungVibratorVars,duration_amplitude,false)

# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint-service.s5e8835 \
    A54xSystemUIOverlay

# UDFPS: let the HWC flag the framework dim layer as the DECON fingerprint mask
$(call soong_config_set,samsungUdfpsVars,dim_layer_zorder,0xff)
$(call soong_config_set,samsungUdfpsVars,udfps_zorder,0x100)
$(call soong_config_set,surfaceflinger,udfps_lib,//hardware/samsung/fingerprint:libudfps_extension.samsung)

# DOZE
PRODUCT_PACKAGES += \
    SamsungDoze

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

# UDFPS Customization
TARGET_HAS_UDFPS := true

# RIL
PRODUCT_PACKAGES += \
    cbd \
    libsec-ril \
    secril_config_svc \
    sehradiomanager

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/ril/sehradiomanager.conf:$(TARGET_COPY_OUT_VENDOR)/etc/sehradiomanager.conf

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.telephony.ims.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.ims.xml

# IMS
$(call inherit-product, hardware/lineage/generic-ims/ims.mk)

PRODUCT_PACKAGES += \
    CarrierSettingsConfigOverlay

# EUICC
PRODUCT_PACKAGES += \
    SamsungEsimSwitcher

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/permissions/no-esim.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/no-esim/android.hardware.telephony.euicc.xml

#OpenEUICC
ifneq ($(wildcard $(LOCAL_PATH)/openeuicc),)
PRODUCT_PACKAGES += \
    OpenEUICC \
    OpenEUICCOverlay

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/openeuicc/permission/privapp_whitelist_im.angry.openeuicc.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/privapp_whitelist_im.angry.openeuicc.xml \
    frameworks/native/data/etc/android.hardware.telephony.euicc.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/android.hardware.telephony.euicc.xml
endif

# android.hardware.location.gps feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml

# NFC
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
    frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
    frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.uicc.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl:64 \
    android.hardware.bluetooth@1.0-service \
    libbt-vendor:64 \
    bt_did.slsi.conf

# android.hardware.bluetooth feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml

# WiFi
PRODUCT_PACKAGES += \
    WifiOverlay \
    android.hardware.wifi-service \
    hostapd \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(LOCAL_PATH)/configs/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

PRODUCT_CFI_INCLUDE_PATHS += hardware/samsung_slsi/scsc_wifibt/wpa_supplicant_lib

# android.hardware.wifi feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/init/wifi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/wifi.rc

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS += *

#  feature declarations
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.app_widgets.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.app_widgets.xml \
    frameworks/native/data/etc/android.software.picture_in_picture.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.picture_in_picture.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml
