#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

import hashlib
import struct
from pathlib import Path

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixup_remove_arch_suffix,
    lib_fixup_vendorcompat,
    lib_fixups_user_type,
    libs_clang_rt_ubsan,
    libs_proto_3_9_1,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/samsung/a54x',
    'hardware/samsung',
    'hardware/samsung_slsi-linaro/exynos',
    'hardware/samsung_slsi-linaro/graphics',
    'hardware/samsung_slsi-linaro/interfaces',
]

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    libs_proto_3_9_1: lib_fixup_vendorcompat,
    libs_clang_rt_ubsan: lib_fixup_remove_arch_suffix,
    'libuuid': lib_fixup_vendor_suffix,
} # fmt: skip

def camera_provider_filter_fixup(ctx, file, file_path, **kwargs):
    # keep macro 60 in public enumeration
    path = Path(file_path)
    data = bytearray(path.read_bytes())
    digest = hashlib.sha1(data).hexdigest()
    if digest == "d778648e3bbf004a89c7ec08705889f7e8511813":
        return
    if digest not in (
        "0fa27cd65d7be129dd4a39f5c191613426310dce",
        "46941765241c5067e07de48411a29b11060e7108",
    ):
        raise ValueError("Unexpected A54 camera provider binary")
    # compact vector<uint32_t> excluding 56 and 58, update end, return.
    code = bytes.fromhex(
        "e1 7b bf a9 6b ff ff 97 c0 01 00 35 e1 03 40 f9 "
        "29 28 40 a9 eb 03 09 aa 3f 01 0a eb 00 01 00 54 "
        "2c 45 40 b8 9f e1 00 71 80 ff ff 54 9f e9 00 71 "
        "40 ff ff 54 6c 45 00 b8 f8 ff ff 17 2b 04 00 f9 "
        "e1 7b c1 a8 c0 03 5f d6"
    )
    data[0x18e74:0x18e78] = struct.pack("<I", 0x94005807)
    data[0x2ee90:0x2ee90 + len(code)] = code
    # Extend executable PT_LOAD filesz/memsz into existing zero padding.
    struct.pack_into("<QQ", data, 64 + 3 * 56 + 32,
                     0x1ee90 + len(code), 0x1ee90 + len(code))
    if hashlib.sha1(data).hexdigest() != "d778648e3bbf004a89c7ec08705889f7e8511813":
        raise ValueError("Camera provider patch verification failed")
    path.write_bytes(data)


blob_fixups: blob_fixups_user_type = {
    (
        'vendor/bin/hw/android.hardware.security.keymint-service.samsung',
        'vendor/lib64/libskeymint10device.so',
        'vendor/lib64/libskeymint_cli.so',
    ): blob_fixup()
        .add_needed('libshim_crypto.so')
        .replace_needed('libcrypto.so', 'libcrypto-v33.so'),
    'vendor/lib64/libskeymint10device.so': blob_fixup()
        .add_needed('android.hardware.security.rkp-V2-ndk.so'),
    'vendor/lib64/libskeymint_cli.so': blob_fixup()
     .add_needed('android.hardware.security.rkp-V2-ndk.so'),
    'vendor/bin/hw/android.hardware.security.keymint-service.samsung': blob_fixup()
     .add_needed('android.hardware.security.rkp-V2-ndk.so'),
    'vendor/lib64/libwvaidl.so': blob_fixup()
        .add_needed('libshim_binder_ndk.so'),
    (
        'vendor/lib64/ese_spi_nxp.so',
        'vendor/lib64/nfc_nci_nxpsn.so',
    ): blob_fixup()
        .add_needed('libshim_base.so'),
    (
        'vendor/lib64/libaudioparamupdate.so',
        'vendor/lib64/libaboxpcmdump.so',
    ): blob_fixup()
        .replace_needed('libaudioroute.so', 'libaudioroute_samsung.so'),
    'vendor/etc/init/android.hardware.security.keymint-service.samsung.rc': blob_fixup()
        .regex_replace(
            'android\\.hardware\\.security\\.keymint-service\n',
            'android.hardware.security.keymint-service.samsung\n'),
    'vendor/etc/init/nxp.android.hardware.nfc@1.2-service.rc': blob_fixup()
        .regex_replace(
            'interface vendor\\.samsung\\.hardware\\.nfc@2\\.0::ISehNfc default\n',
            ''),
    'vendor/bin/hw/vendor.samsung.hardware.camera.provider-service_64': blob_fixup()
        .call(camera_provider_filter_fixup, need_tmp_dir=False),
    'vendor/etc/init/vendor.samsung.hardware.camera.provider-service_64.rc': blob_fixup()
        .regex_replace('vendor_secdir w', 'w')
        .regex_replace('vendor_secdir', 'camera'),
    'vendor/lib64/libsensorlistener.so': blob_fixup()
        .add_needed('libshim_sensorndkbridge.so'),
    'vendor/lib64/libsec-ril-impl.so': blob_fixup()
        # Always emit uiccApplicationsEnablementChanged
        .sig_replace('1f 00 08 6b ab 01 00 54', '1f 00 08 6b 1f 20 03 d5')
        .sig_replace('bf 02 08 6b ab 01 00 54', 'bf 02 08 6b 1f 20 03 d5')
        # Skip legacy UICC code
        .sig_replace('1f 00 08 6b 0c 01 00 54', '1f 00 08 6b 08 00 00 14'),
    'vendor/lib64/libwvhidl.so': blob_fixup()
        .replace_needed('libprotobuf-cpp-lite-3.9.1.so', 'libprotobuf-cpp-full-3.9.1.so'),
    'vendor/lib64/libenn_user_driver_gpu_lib.so': blob_fixup()
        .replace_needed('libOpenCL.so', 'libGLES_mali.so'),
    (
        'vendor/lib64/sensors.grip.so',
        'vendor/lib64/sensors.inputvirtual.so',
        'vendor/lib64/sensors.sensorhub.so',
    ): blob_fixup()
        .remove_needed('libhidltransport.so')
        .add_needed('libutils-v32.so')
        .binary_regex_replace(b'_ZN7android6Thread3runEPKcim', b'_ZN7utils326Thread3runEPKcim'),
}  # fmt: skip

blob_fixups.update({
    'vendor/lib64/unihal_android.so': blob_fixup()
        .add_needed('libshim_camera.so')
        .add_needed('libshim_sensorndkbridge.so'),
    'vendor/lib64/libscaler_hw.unifunc.so': blob_fixup()
        .add_needed('libshim_camera.so'),
    'vendor/lib64/hw/camera.s5e8835.so': blob_fixup()
        .add_needed('libshim_camera.so'),
})  # fmt: skip

module = ExtractUtilsModule(
    'a54x',
    'samsung',
    namespace_imports=namespace_imports,
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
)

if __name__ == '__main__':
    ExtractUtils(module).run()
