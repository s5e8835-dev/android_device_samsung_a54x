/*
 * Copyright (C) 2022 The LineageOS Project
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

#include <endian.h>
#include <fcntl.h>
#include <libgen.h>
#include <unistd.h>

#include <cstdint>
#include <cstring>

#include <android-base/file.h>
#include <android-base/properties.h>
#include <android-base/unique_fd.h>
#include <edify/expr.h>
#include <otautil/error_code.h>
#include <ziparchive/zip_archive.h>

namespace {

// Samsung CP TOC layout, also used by cpboot_v3.
struct ModemTocEntry {
  char name[12];
  uint32_t offset;
  uint32_t load_address;
  uint32_t size;
  uint32_t crc;
  uint32_t count;
};
static_assert(sizeof(ModemTocEntry) == 32);

std::string ReadModemVersion(int fd) {
  constexpr size_t kMaxEntries = 16;
  constexpr size_t kFooterAlignment = 16;
  constexpr size_t kQbrOffset = 16;
  constexpr size_t kVersionOffset = 32;
  constexpr size_t kVersionLength = 13;
  ModemTocEntry toc[kMaxEntries];
  if (!android::base::ReadFullyAtOffset(fd, toc, sizeof(toc), 0) ||
      std::memcmp(toc[0].name, "TOC", sizeof("TOC")) != 0) {
    return {};
  }

  const uint32_t count = le32toh(toc[0].count);
  if (count < 2 || count > kMaxEntries) {
    return {};
  }
  for (uint32_t i = 1; i < count; ++i) {
    if (std::memcmp(toc[i].name, "VSS", sizeof("VSS")) != 0) {
      continue;
    }
    const uint32_t offset = le32toh(toc[i].offset);
    const uint32_t size = le32toh(toc[i].size);
    if (offset < sizeof(toc) || size == 0) {
      return {};
    }

    // EYI4's signing footer starts at the first 16-byte boundary after VSS.
    const uint64_t end = static_cast<uint64_t>(offset) + size;
    const uint64_t footer_offset = (end + kFooterAlignment - 1) & ~(kFooterAlignment - 1);
    char footer[kVersionOffset + kVersionLength + 1];
    if (!android::base::ReadFullyAtOffset(fd, footer, sizeof(footer), footer_offset) ||
        std::memcmp(footer, "SignerVer03", sizeof("SignerVer03")) != 0 ||
        std::memcmp(footer + kQbrOffset, "QBR", sizeof("QBR")) != 0 ||
        footer[kVersionOffset + kVersionLength] != '_') {
      return {};
    }

    std::string version(footer + kVersionOffset, kVersionLength);
    if (version.find_first_not_of("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ") != std::string::npos) {
      return {};
    }
    return version;
  }
  return {};
}

Value* ModemVersionFn(const char* name, State* state,
                      const std::vector<std::unique_ptr<Expr>>& argv) {
  if (!argv.empty()) {
    return ErrorAbort(state, kArgsParsingFailure, "%s() expects no arguments", name);
  }

  android::base::unique_fd fd(open("/dev/block/by-name/radio", O_RDONLY | O_CLOEXEC));
  const std::string version = fd.ok() ? ReadModemVersion(fd.get()) : "";
  return StringValue(version.empty() ? "unknown (could not read CP version)" : version);
}

}  // namespace

Value *VerifyNoDowngradeFn(const char* name, State *state,
                             const std::vector<std::unique_ptr<Expr>>& argv) {
  int ret = 1;
  std::vector<std::string> args;

  if (argv.size() != 1 || !ReadArgs(state, argv, &args))
    return ErrorAbort(state, kArgsParsingFailure,
                      "%s() error parsing arguments", name);

  std::string blModel = android::base::GetProperty("ro.boot.em.model", "");
  std::string shortModel = blModel.substr(blModel.find("-") + 1, std::string::npos);
  std::string blVer = android::base::GetProperty("ro.boot.bootloader", "");
  if (blVer.length() >= shortModel.length() + 4
      && args[0].length() >= shortModel.length() + 4) { // <model>XXU<binary>
    std::string curBinary = blVer.substr(shortModel.length() + 3, 1);
    std::string newBinary = args[0].substr(shortModel.length() + 3, 1);
    if (newBinary.at(0) >= curBinary.at(0)) {
      ret = 0;
    }
  }

  return StringValue(std::to_string(ret));
}

Value *MarkHeaderBtFn(const char* name, State *state,
                        const std::vector<std::unique_ptr<Expr>>& argv) {
  int ret = 0;
  std::vector<std::string> args;
  const char* partition;
  uint32_t magicOffset;
  uint32_t numImages;
  uint32_t magic1;

  if(argv.size() < 4 || argv.size() > 4 || !ReadArgs(state, argv, &args))
    return ErrorAbort(state, kArgsParsingFailure,
                      "%s() error parsing arguments", name);

  partition = args[0].c_str();
  magicOffset = std::atoi(args[1].c_str());
  numImages = std::atoi(args[2].c_str());
  magic1 = std::atoi(args[3].c_str());

  int fd = open(partition, O_RDWR);
  if (fd < 0)
    return ErrorAbort(state, kFileOpenFailure,
                      "%s() failed to open %s", name, partition);

  magic1 = magic1 << (magicOffset * 8);
  numImages = numImages << (magicOffset * 8);
  write(fd, (char*)&magic1, sizeof(uint32_t));
  write(fd, (char*)&numImages, sizeof(uint32_t));
  close(fd);

  return StringValue(std::to_string(ret));
}

#define FILENAME_MAX_LEN 32

Value *WriteDataBtFn(const char* name, State *state,
                        const std::vector<std::unique_ptr<Expr>>& argv) {
  int ret = 0;
  std::vector<std::string> args;
  const char* file;
  const char* filename;
  const char* partition;
  uint32_t offset;
  uint32_t filesize;

  if(argv.size() < 4 || argv.size() > 4 || !ReadArgs(state, argv, &args))
    return ErrorAbort(state, kArgsParsingFailure,
                      "%s() error parsing arguments", name);

  file = args[0].c_str();
  filename = basename(file);
  partition = args[1].c_str();
  offset = std::atoi(args[2].c_str());
  filesize = std::atoi(args[3].c_str());

  int fd = open(partition, O_RDWR);
  if (fd < 0)
    return ErrorAbort(state, kFileOpenFailure,
                      "%s() failed to open %s", name, partition);

  char filename_padded[FILENAME_MAX_LEN] = { 0 };
  strcpy(&filename_padded[0], filename);

  lseek(fd, offset, SEEK_SET);
  write(fd, &filename_padded[0], FILENAME_MAX_LEN);
  write(fd, (char*)&filesize, sizeof(uint32_t));

  // write data
  ZipArchiveHandle za = state->updater->GetPackageHandle();
  ZipEntry64 entry;
  if (FindEntry(za, file, &entry) != 0) {
    return ErrorAbort(state, kPackageExtractFileFailure,
                      "%s() %s not found in package", name, file);
  }

  if (ExtractEntryToFile(za, &entry, fd))
    return ErrorAbort(state, kPackageExtractFileFailure,
                      "%s() failed to extract %s from package", name, file);

  close(fd);

  return StringValue(std::to_string(ret));
}

void Register_librecovery_updater_s5e8835() {
  RegisterFunction("s5e8835.modem_version", ModemVersionFn);
  RegisterFunction("s5e8835.verify_no_downgrade", VerifyNoDowngradeFn);
  RegisterFunction("s5e8835.mark_header_bt", MarkHeaderBtFn);
  RegisterFunction("s5e8835.write_data_bt", WriteDataBtFn);
}
