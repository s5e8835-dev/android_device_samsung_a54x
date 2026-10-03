#!/bin/env python3
#
# Copyright (C) 2020-2024 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import common
import re

MODEL = 'getprop("ro.boot.em.model")'
MODEM = 's5e8835.modem_version()'
MODEM_RE = re.compile(r'require\s+modem\.(SM-[A-Z0-9]+)\s*=\s*([A-Z0-9]{13})')

def OTA_Assertions(info, input_zip):
  required = {}
  for line in input_zip.read("OTA/android-info-extra.txt").decode('utf-8').splitlines():
    line = line.strip()
    if not line or line.startswith('#'):
      continue
    match = MODEM_RE.fullmatch(line)
    if not match:
      raise ValueError(f"Invalid modem requirement: {line!r}")
    model, version = match.groups()
    if model in required or not version.startswith(model.removeprefix("SM-")):
      raise ValueError(f"Invalid modem requirement for {model}: {version}")
    required[model] = version

  if not required:
    raise ValueError("No required modem versions in android-info-extra.txt")

  models = ' || '.join(f'{MODEL} == "{model}"' for model in required)
  info.script.AppendExtra(
      f'{models} || abort("E3004: Unsupported model: " + {MODEL} + ".");')
  for model, version in required.items():
    info.script.AppendExtra(f'if {MODEL} == "{model}" then')
    info.script.AppendExtra(
        f'  {MODEM} == "{version}" || abort("E3004: {model} requires modem {version}; '
        f'found " + {MODEM} + ".");')
    info.script.AppendExtra('endif;')

def FullOTA_Assertions(info):
  OTA_Assertions(info, info.input_zip)

def FullOTA_InstallEnd(info):
  OTA_InstallEnd(info)
  return

def IncrementalOTA_Assertions(info):
  # Downgrades use the source update-binary, which may not have modem_version().
  if common.OPTIONS.downgrade:
    raise ValueError("Use a full OTA to downgrade with modem verification")
  OTA_Assertions(info, info.target_zip)

def IncrementalOTA_InstallEnd(info):
  info.input_zip = info.target_zip
  OTA_InstallEnd(info)
  return

def AddImage(info, basename, dest):
  data = info.input_zip.read("IMAGES/" + basename)
  common.ZipWriteStr(info.output_zip, basename, data)
  info.script.Print("Patching {} image unconditionally...".format(dest.split('/')[-1]))
  info.script.AppendExtra('package_extract_file("%s", "%s");' % (basename, dest))

def AddFirmwareImage(info, model, basename, dest, simple=False, offset=8):
  if ("RADIO/%s_%s" % (basename, model)) in info.input_zip.namelist():
    data = info.input_zip.read("RADIO/%s_%s" % (basename, model))
    common.ZipWriteStr(info.output_zip, "firmware/%s/%s" % (model, basename), data);
    info.script.Print("Patching {} image unconditionally...".format(basename.split('.')[0]));
    if simple:
      info.script.AppendExtra('package_extract_file("firmware/%s/%s", "%s");' % (model, basename, dest))
    else:
      size = info.input_zip.getinfo("RADIO/%s_%s" % (basename, model)).file_size
      info.script.AppendExtra('assert(s5e8835.write_data_bt("firmware/%s/%s", "%s", %d, %d));' % (model, basename, dest, offset, size))
      return size
    return 0

def OTA_InstallEnd(info):
  AddImage(info, "dtbo.img", "/dev/block/by-name/dtbo")
  AddImage(info, "vbmeta.img", "/dev/block/by-name/vbmeta")
  AddImage(info, "init_boot.img", "/dev/block/by-name/init_boot")
  AddImage(info, "vendor_boot.img", "/dev/block/by-name/vendor_boot")

  if "RADIO/models" in info.input_zip.namelist():
    modelsIncluded = []
    for model in info.input_zip.read("RADIO/models").decode('utf-8').splitlines():
      if "RADIO/version_%s" % model in info.input_zip.namelist():
        modelsIncluded.append(model)
        version = info.input_zip.read("RADIO/version_%s" % model).decode('utf-8').splitlines()[0]
        offset = 8
        numImages = 0
        info.script.AppendExtra('# Firmware update to %s for %s' % (version, model))
        info.script.AppendExtra('ifelse (getprop("ro.boot.em.model") == "%s" &&' % model)
        info.script.AppendExtra('s5e8835.verify_no_downgrade("%s") == "0" &&' % version)
        info.script.AppendExtra('getprop("ro.boot.bootloader") != "%s",' % version)
        info.script.AppendExtra('assert(s5e8835.mark_header_bt("/dev/block/by-name/bota", 0, 0, 0));')
        for image in 'fld.bin', 'harx.bin', 'keystorage.bin', 'ldfw.img', 'sboot.bin', 'tzar.img', 'tzsw.img', 'uh.bin', 'up_param.bin':
          size = AddFirmwareImage(info, model, image, "/dev/block/by-name/bota", False, offset)
          if size > 0:
            numImages += 1
            offset += size + 36 # header size
        info.script.AppendExtra('assert(s5e8835.mark_header_bt("/dev/block/by-name/bota", 0, %d, 3142939818));' % numImages)
        AddFirmwareImage(info, model, "modem.bin", "/dev/block/by-name/radio", True)
        AddFirmwareImage(info, model, "modem_debug.bin", "/dev/block/by-name/cp_debug", True)
        info.script.AppendExtra(',"");')

    modelCheck = ""
    for model in modelsIncluded:
      if len(modelCheck) > 0:
        modelCheck += ' || '
      modelCheck += 'getprop("ro.boot.em.model") == "%s"' % model
    if len(modelCheck) > 0:
      info.script.AppendExtra('%s || abort("Unsupported model, not updating firmware!");' % modelCheck)
  return
