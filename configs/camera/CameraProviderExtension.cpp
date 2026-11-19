#include <cstdlib>
#include <stdint.h>
#include <string>
#include <thread>
#include <chrono>
#include <mutex>
#include <android-base/file.h>

static constexpr const char* FLASH_NODE = "/sys/class/camera/flash/rear_flash";
// A54 stock SM5714 torch-brightness-levels: <0 1 2 5 7>.
// Commands 1003/1004, 1005/1006 and 1007-1009 select the same respective steps.
static constexpr int32_t kLevelToRawValue[] = {0, 1001, 1002, 1003, 1005, 1007};
static constexpr int32_t kMaxStrengthLevel =
        sizeof(kLevelToRawValue) / sizeof(kLevelToRawValue[0]) - 1;

static std::mutex gStateMutex;
static int32_t gLevel = 0;  // last requested strength level, 0 = off
static uint64_t gGeneration = 0;

bool supportsTorchStrengthControlExt() { return true; }
int32_t getTorchDefaultStrengthLevelExt() { return 1; }
int32_t getTorchMaxStrengthLevelExt() { return kMaxStrengthLevel; }

int32_t getTorchStrengthLevelExt() {
    std::lock_guard<std::mutex> lock(gStateMutex);
    return gLevel;
}

void setTorchStrengthLevelExt(int32_t torchStrength, bool enabled) {
    int level = enabled ? torchStrength : 0;
    if (level < 0) level = 0;
    if (level > kMaxStrengthLevel) level = kMaxStrengthLevel;
    int raw = kLevelToRawValue[level];

    uint64_t generation;
    {
        std::lock_guard<std::mutex> lock(gStateMutex);
        generation = ++gGeneration;
        gLevel = level;
        android::base::WriteStringToFile(std::to_string(raw), FLASH_NODE);
    }

    if (raw > 0) {
        std::thread([generation, raw]() {
            for (int attempt = 0; attempt < 3; ++attempt) {
                std::this_thread::sleep_for(std::chrono::milliseconds(60));
                std::lock_guard<std::mutex> lock(gStateMutex);
                if (gGeneration != generation) return;  // superseded
                std::string value;
                if (android::base::ReadFileToString(FLASH_NODE, &value) &&
                        atoi(value.c_str()) == raw) {
                    return;  // already holds our value
                }
                android::base::WriteStringToFile(std::to_string(raw), FLASH_NODE);
            }
        }).detach();
    }
}
