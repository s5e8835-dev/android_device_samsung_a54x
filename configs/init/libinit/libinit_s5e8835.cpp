/*
 * Copyright (C) The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <libinit_dalvik_heap.h>
#include <libinit_utils.h>
#include <libinit_variant.h>
#include "vendor_init.h"

#include <android-base/properties.h>

using android::base::GetProperty;

static const variant_info_t a54xnaxx = {
    .device = "a54x",
    .model = "SM-A546B",
    .name = "a54xnaxx",
    .build_fingerprint = "samsung/a54xnaxx/a54x:16/BP2A.250605.031.A3/A546BXXUFEYI4:user/release-keys",
    .build_desc = "a54xnaxx-user 16 BP2A.250605.031.A3 A546BXXUFEYI4 release-keys"
};

static const variant_info_t a54xnsxx = {
    .device = "a54x",
    .model = "SM-A546E",
    .name = "a54xnsxx",
    .build_fingerprint = "samsung/a54xnsxx/a54x:16/BP2A.250605.031.A3/A546EXXUFEYI4:user/release-keys",
    .build_desc = "a54xnsxx-user 16 BP2A.250605.031.A3 A546EXXUFEYI4 release-keys"
};

static const std::vector<variant_info_t> variants = {
    a54xnaxx,
    a54xnsxx,
};

void vendor_load_properties() {
    search_variant(variants);

    std::string model = GetProperty("ro.boot.product.model", "");
    if (model.empty()) {
        model = GetProperty("ro.boot.em.model", "");
    }
    set_ro_build_prop("model", model, true);
    set_ro_build_prop("product", model, false);

    set_dalvik_heap();
}
