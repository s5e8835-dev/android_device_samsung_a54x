/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <sync/sync.h>
#include <ui/GraphicBufferMapper.h>
#include <ui/Rect.h>
#include <utils/Errors.h>

using android::Rect;
using android::status_t;

extern "C" {
status_t _ZN7android19GraphicBufferMapper4lockEPK13native_handlejRKNS_4RectEPPvPiS9_(
        void* thisptr, buffer_handle_t handle, uint32_t usage, const Rect& bounds, void** vaddr,
        int32_t* outBytesPerPixel, int32_t* outBytesPerStride) {
    auto* gpm = static_cast<android::GraphicBufferMapper*>(thisptr);
    auto result = gpm->lock(handle, static_cast<int64_t>(usage), bounds);
    if (!result.has_value()) {
        return result.error().asStatus();
    }
    *vaddr = result->address;
    if (outBytesPerPixel) *outBytesPerPixel = result->bytesPerPixel;
    if (outBytesPerStride) *outBytesPerStride = result->bytesPerStride;
    return android::OK;
}

status_t _ZN7android19GraphicBufferMapper6unlockEPK13native_handle(void* thisptr,
                                                                   buffer_handle_t handle) {
    android::base::unique_fd outFence;
    auto* gpm = static_cast<android::GraphicBufferMapper*>(thisptr);
    status_t status = gpm->unlock(handle, &outFence);
    if (status == android::OK && outFence.get() >= 0) {
        sync_wait(outFence.get(), -1);
        outFence.reset();
    }
    return status;
}
}
