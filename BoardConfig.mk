#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/samsung/a54x

## Inherit proprietary vendor configuration
include vendor/samsung/a54x/BoardConfigVendor.mk

## Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic

## Platform
BOARD_VENDOR := samsung
TARGET_BOARD_PLATFORM := s5e8835
TARGET_BOOTLOADER_BOARD_NAME := s5e8835
TARGET_SOC := s5e8835
include hardware/samsung_slsi-linaro/config/BoardConfig8835.mk

## Security
VENDOR_SECURITY_PATCH := 2025-09-01
