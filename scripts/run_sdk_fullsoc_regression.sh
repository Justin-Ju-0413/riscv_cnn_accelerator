#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_DIR="${SDK_DIR:-${ROOT_DIR}/third_party/nuclei-sdk}"
SOC_DIR="${SOC_DIR:-/home/gstar/Desktop/e203_hbirdv2}"
APP_DIR="${APP_DIR:-${SDK_DIR}/application/baremetal/cnn_accel_demo}"
GCC_ROOT="${RISCV_GCC_ROOT:-/home/gstar/Desktop/gcc}"
SIM_TOOL="${SIM_TOOL:-iverilog}"
RUN_TIMEOUT="${RUN_TIMEOUT:-60}"
RST_RELEASE="${RST_RELEASE:-120}"
EXTRA_PLUSARGS="${EXTRA_PLUSARGS:-+PROGRESS_STRIDE=50000 +SUMMARY_DRAIN_CYCLES=64}"
AUTO_APPLY_SDK_PATCH="${AUTO_APPLY_SDK_PATCH:-1}"
PATCH_HELPER="${ROOT_DIR}/scripts/apply_nuclei_sdk_phase3_patch.sh"
INSTALL_HELPER="${ROOT_DIR}/sw/build/install_sdk_app.sh"
SPLIT_HELPER="${SOC_DIR}/tb/split_sdk_verilog.sh"
FULLSOC_RUNNER="${SOC_DIR}/vsim/run_nice_patch.sh"
VERILOG_IMAGE="${APP_DIR}/cnn_accel_demo.verilog"
ITCM_IMAGE="${APP_DIR}/cnn_accel_demo.itcm"
DTCM_IMAGE="${APP_DIR}/cnn_accel_demo.dtcm"
EXPECTED_RSTAT="${EXPECTED_RSTAT:-19}"
MEM_INIT_HEADER="${SOC_DIR}/rtl/e203/core/e203_fpga_mem_init.vh"
mem_init_header_backup=""
mem_init_header_was_present=0

restore_mem_init_header() {
  if [[ ${mem_init_header_was_present} -eq 1 ]]; then
    mv -f "${mem_init_header_backup}" "${MEM_INIT_HEADER}"
  else
    rm -f "${MEM_INIT_HEADER}"
  fi
}

write_mem_init_header() {
  if [[ -e "${MEM_INIT_HEADER}" ]]; then
    mem_init_header_was_present=1
    mem_init_header_backup="$(mktemp "${MEM_INIT_HEADER}.XXXXXX.bak")"
    cp -p "${MEM_INIT_HEADER}" "${mem_init_header_backup}"
  fi

  printf '%s\n' \
    '`ifndef E203_FPGA_MEM_INIT_VH' \
    '`define E203_FPGA_MEM_INIT_VH' \
    "\`define E203_ITCM_INIT_FILE \"${ITCM_IMAGE}.verilog\"" \
    "\`define E203_DTCM_INIT_FILE \"${DTCM_IMAGE}.verilog\"" \
    '`endif' > "${MEM_INIT_HEADER}"
}

trap restore_mem_init_header EXIT

find_tool_bin() {
  local root="$1"
  local tool="$2"

  if [[ -x "${root}/bin/${tool}" ]]; then
    echo "${root}/bin/${tool}"
    return
  fi

  if [[ -x "${root}/gcc/bin/${tool}" ]]; then
    echo "${root}/gcc/bin/${tool}"
    return
  fi
}

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
GCC_BIN="$(find_tool_bin "${GCC_ROOT}" riscv64-unknown-elf-gcc || true)"
if [[ -z "${GCC_BIN}" ]]; then
  echo "[PHASE4_ERROR] missing Nuclei GCC toolchain under ${GCC_ROOT}" >&2
  exit 1
fi

if [[ "${AUTO_APPLY_SDK_PATCH}" == "1" ]]; then
  require_path "${PATCH_HELPER}" "SDK patch helper"
  "${PATCH_HELPER}" "${SDK_DIR}"
fi

require_path "${INSTALL_HELPER}" "SDK app install helper"
"${INSTALL_HELPER}"

export NUCLEI_SDK_ROOT="${SDK_DIR}"
export RISCV_GCC_ROOT="${GCC_ROOT}"
export NUCLEI_TOOL_ROOT="${GCC_ROOT}"
export CROSS_COMPILE="${GCC_BIN%gcc}"
if [[ -d "${GCC_ROOT}/gcc/bin" ]]; then
  export PATH="${GCC_ROOT}/gcc/bin:${PATH}"
else
  export PATH="${GCC_ROOT}/bin:${PATH}"
fi

make -C "${APP_DIR}" clean all CORE=n300 DOWNLOAD=ilm
make -C "${APP_DIR}" dasm CORE=n300 DOWNLOAD=ilm
make -C "${APP_DIR}" cnn_accel_demo.verilog CORE=n300 DOWNLOAD=ilm

"${SPLIT_HELPER}" "${VERILOG_IMAGE}"
write_mem_init_header

runner_stdout_log="$(mktemp "${ROOT_DIR}/.tmp_fullsoc_stdout.XXXXXX.log")"

set +e
set -o pipefail
env \
  PATCHCASE='' \
  TESTCASE="${ITCM_IMAGE}" \
  DTCMCASE="${DTCM_IMAGE}" \
  RUN_TIMEOUT="${RUN_TIMEOUT}" \
  RST_RELEASE="${RST_RELEASE}" \
  EXTRA_PLUSARGS="${EXTRA_PLUSARGS} +EXPECTED_RSTAT=${EXPECTED_RSTAT}" \
  SIM_TOOL="${SIM_TOOL}" \
  "${FULLSOC_RUNNER}" 2>&1 | tee "${runner_stdout_log}"
runner_rc=${PIPESTATUS[0]}
set +o pipefail
set -e

log_path="$(find "${SOC_DIR}/vsim/run" -maxdepth 2 -name 'cnn_accel_demo.itcm.log' | head -n 1 || true)"

normalized_log="${runner_stdout_log}.normalized"
python3 - <<'PY' "${runner_stdout_log}" "${normalized_log}"
from pathlib import Path
import sys

raw = Path(sys.argv[1]).read_bytes()
normalized = raw.replace(b"\x00", b"").replace(b"\r", b"\n")
Path(sys.argv[2]).write_bytes(normalized)
PY

for _ in 1 2 3 4 5; do
  if grep -aq "\\[NICE_SUMMARY\\].*expected_rstat_seen=1.*expected_rstat=${EXPECTED_RSTAT}" "${normalized_log}" &&
     grep -aq "\\[NICE_RSP\\].*rdat=${EXPECTED_RSTAT}.*err=0" "${normalized_log}"; then
    break
  fi
  sleep 1
done

if ! grep -aq "\\[NICE_SUMMARY\\].*expected_rstat_seen=1.*expected_rstat=${EXPECTED_RSTAT}" "${normalized_log}"; then
  echo "[PHASE4_ERROR] NICE summary missing expected RSTAT ${EXPECTED_RSTAT} in ${runner_stdout_log}" >&2
  exit 1
fi

if ! grep -aq "\\[NICE_RSP\\].*rdat=${EXPECTED_RSTAT}.*err=0" "${normalized_log}"; then
  echo "[PHASE4_ERROR] expected NICE response ${EXPECTED_RSTAT}/err=0 not found in ${runner_stdout_log}" >&2
  exit 1
fi

if [[ ${runner_rc} -ne 0 && ${runner_rc} -ne 124 ]]; then
  echo "[PHASE4_ERROR] full-SoC runner exited with ${runner_rc}" >&2
  exit "${runner_rc}"
fi

if [[ ${runner_rc} -eq 124 ]]; then
  echo "[PHASE4_INFO] full-SoC runner hit timeout after expected NICE completion; treating regression as pass"
fi

echo "[PHASE4_PASS] sdk build, image split, and full-SoC regression passed"
echo "[PHASE4_LOG] ${runner_stdout_log}"
if [[ -n "${log_path}" ]]; then
  echo "[PHASE4_INNER_LOG] ${log_path}"
fi
