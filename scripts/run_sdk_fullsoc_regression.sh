#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_DIR="${SDK_DIR:-${ROOT_DIR}/third_party/nuclei-sdk}"
SOC_DIR="${SOC_DIR:-/home/gstar/Desktop/e203_hbirdv2}"
APP_DIR="${APP_DIR:-${SDK_DIR}/application/baremetal/cnn_accel_demo}"
GCC_ROOT="${RISCV_GCC_ROOT:-/home/gstar/Desktop/gcc}"
SIM_TOOL="${SIM_TOOL:-iverilog}"
RUN_TIMEOUT="${RUN_TIMEOUT:-20}"
RST_RELEASE="${RST_RELEASE:-120}"
EXTRA_PLUSARGS="${EXTRA_PLUSARGS:-+PROGRESS_STRIDE=10000}"
AUTO_APPLY_SDK_PATCH="${AUTO_APPLY_SDK_PATCH:-1}"
PATCH_HELPER="${ROOT_DIR}/scripts/apply_nuclei_sdk_phase3_patch.sh"
SPLIT_HELPER="${SOC_DIR}/tb/split_sdk_verilog.sh"
FULLSOC_RUNNER="${SOC_DIR}/vsim/run_nice_patch.sh"
VERILOG_IMAGE="${APP_DIR}/cnn_accel_demo.verilog"
ITCM_IMAGE="${APP_DIR}/cnn_accel_demo.itcm"
DTCM_IMAGE="${APP_DIR}/cnn_accel_demo.dtcm"

require_path() {
  local path="$1"
  local label="$2"
  if [[ ! -e "${path}" ]]; then
    echo "[PHASE4_ERROR] missing ${label}: ${path}" >&2
    exit 1
  fi
}

require_path "${SDK_DIR}" "SDK directory"
require_path "${SOC_DIR}" "SoC directory"
require_path "${APP_DIR}" "SDK application directory"
require_path "${SPLIT_HELPER}" "verilog split helper"
require_path "${FULLSOC_RUNNER}" "full-SoC runner"
require_path "${GCC_ROOT}/bin/riscv64-unknown-elf-gcc" "Nuclei GCC toolchain"

if [[ "${AUTO_APPLY_SDK_PATCH}" == "1" ]]; then
  require_path "${PATCH_HELPER}" "SDK patch helper"
  "${PATCH_HELPER}" "${SDK_DIR}"
fi

export NUCLEI_SDK_ROOT="${SDK_DIR}"
export RISCV_GCC_ROOT="${GCC_ROOT}"
export NUCLEI_TOOL_ROOT="${GCC_ROOT}"
export CROSS_COMPILE="${GCC_ROOT}/bin/riscv64-unknown-elf-"
export PATH="${GCC_ROOT}/bin:${PATH}"

make -C "${APP_DIR}" clean all CORE=n300 DOWNLOAD=ilm
make -C "${APP_DIR}" dasm CORE=n300 DOWNLOAD=ilm
make -C "${APP_DIR}" cnn_accel_demo.verilog CORE=n300 DOWNLOAD=ilm

"${SPLIT_HELPER}" "${VERILOG_IMAGE}"

PATCHCASE='' \
TESTCASE="${ITCM_IMAGE}" \
DTCMCASE="${DTCM_IMAGE}" \
RUN_TIMEOUT="${RUN_TIMEOUT}" \
RST_RELEASE="${RST_RELEASE}" \
EXTRA_PLUSARGS="${EXTRA_PLUSARGS}" \
SIM_TOOL="${SIM_TOOL}" \
"${FULLSOC_RUNNER}"

log_path="$(find "${SOC_DIR}/vsim/run" -maxdepth 2 -name 'cnn_accel_demo.itcm.log' | head -n 1 || true)"
if [[ -z "${log_path}" ]]; then
  echo "[PHASE4_ERROR] unable to locate cnn_accel_demo.itcm.log under ${SOC_DIR}/vsim/run" >&2
  exit 1
fi

if ! grep -q '\[NICE_SUMMARY\].*rstat_320_seen=1' "${log_path}"; then
  echo "[PHASE4_ERROR] NICE summary missing expected rstat_320_seen=1 in ${log_path}" >&2
  exit 1
fi

if ! grep -q '\[NICE_RSP\].*rdat=320.*err=0' "${log_path}"; then
  echo "[PHASE4_ERROR] final NICE response 320/err=0 not found in ${log_path}" >&2
  exit 1
fi

echo "[PHASE4_PASS] sdk build, image split, and full-SoC regression passed"
echo "[PHASE4_LOG] ${log_path}"
