#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_DIR="${SDK_DIR:-${ROOT_DIR}/third_party/nuclei-sdk}"
SOC_DIR="${SOC_DIR:-/home/gstar/Desktop/e203_hbirdv2}"
GCC_ROOT="${RISCV_GCC_ROOT:-/home/gstar/Desktop/gcc}"
OPENOCD_BIN="${OPENOCD_BIN:-}"
VIVADO_BIN="${VIVADO_BIN:-}"
SERIAL_DEV="${SERIAL_DEV:-}"
TARGET_BOARD="${TARGET_BOARD:-nuclei_fpga_eval}"
TARGET_SOC="${TARGET_SOC:-evalsoc}"
TARGET_CORE="${TARGET_CORE:-n300}"
FPGA_NAME="${FPGA_NAME:-mcu200t}"

pass() {
  echo "[PHASE5_OK] $1"
}

warn() {
  echo "[PHASE5_WARN] $1"
}

fail() {
  echo "[PHASE5_FAIL] $1"
}

check_path() {
  local path="$1"
  local label="$2"
  if [[ -e "${path}" ]]; then
    pass "${label}: ${path}"
  else
    fail "missing ${label}: ${path}"
  fi
}

check_bin() {
  local path="$1"
  local label="$2"
  if [[ -x "${path}" ]]; then
    pass "${label}: ${path}"
  else
    fail "missing ${label}: ${path}"
  fi
}

check_optional_bin() {
  local path="$1"
  local label="$2"
  if [[ -x "${path}" ]]; then
    pass "${label}: ${path}"
  else
    warn "missing ${label}: ${path}"
  fi
}

check_path "${ROOT_DIR}" "main repo"
check_path "${SDK_DIR}" "SDK directory"
check_path "${SOC_DIR}" "E203 SoC repo"
check_bin "${GCC_ROOT}/bin/riscv64-unknown-elf-gcc" "RISC-V GCC"
check_bin "${GCC_ROOT}/bin/riscv64-unknown-elf-gdb" "RISC-V GDB"
check_path "${SDK_DIR}/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg" "evalsoc OpenOCD config"
check_path "${SDK_DIR}/application/baremetal/cnn_accel_demo" "SDK app path"
check_path "${SOC_DIR}/fpga/Makefile" "official FPGA top Makefile"

case "${FPGA_NAME}" in
  mcu200t|ddr200t)
    pass "FPGA shell target: ${FPGA_NAME}"
    ;;
  *)
    fail "unsupported FPGA_NAME=${FPGA_NAME}; expected mcu200t or ddr200t"
    exit 1
    ;;
esac

check_path "${SOC_DIR}/fpga/${FPGA_NAME}/Makefile" "board Makefile"
check_path "${SOC_DIR}/fpga/${FPGA_NAME}/src/system.v" "board shell system.v"
check_path "${SOC_DIR}/fpga/${FPGA_NAME}/constrs/nuclei-config.xdc" "board config XDC"
check_path "${SOC_DIR}/fpga/${FPGA_NAME}/constrs/nuclei-master.xdc" "board master XDC"
check_path "${SOC_DIR}/fpga/${FPGA_NAME}/script/board.tcl" "board Tcl entry"

if [[ -n "${OPENOCD_BIN}" ]]; then
  check_optional_bin "${OPENOCD_BIN}" "explicit OPENOCD_BIN"
else
  if command -v openocd >/dev/null 2>&1; then
    pass "openocd found in PATH: $(command -v openocd)"
  else
    warn "openocd not found in PATH"
  fi
fi

if [[ -n "${VIVADO_BIN}" ]]; then
  check_optional_bin "${VIVADO_BIN}" "explicit VIVADO_BIN"
else
  if command -v vivado >/dev/null 2>&1; then
    pass "vivado found in PATH: $(command -v vivado)"
  else
    warn "vivado not found in PATH"
  fi
fi

if command -v lsusb >/dev/null 2>&1; then
  if lsusb | grep -qi '0403:6010'; then
    pass "FTDI JTAG device detected (0403:6010)"
  else
    warn "FTDI JTAG device 0403:6010 not detected via lsusb"
  fi
else
  warn "lsusb not available; cannot probe FTDI JTAG presence"
fi

if [[ -n "${SERIAL_DEV}" ]]; then
  check_path "${SERIAL_DEV}" "UART serial device"
else
  warn "SERIAL_DEV not set; UART observation path not locked"
fi

echo "[PHASE5_INFO] recommended board target: SOC=${TARGET_SOC} BOARD=${TARGET_BOARD} CORE=${TARGET_CORE} DOWNLOAD=ilm"
echo "[PHASE5_INFO] default FPGA shell target: FPGA_NAME=${FPGA_NAME}"
echo "[PHASE5_INFO] recommended OpenOCD config: ${SDK_DIR}/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg"
echo "[PHASE5_INFO] official FPGA install command: make -C ${SOC_DIR}/fpga install FPGA_NAME=${FPGA_NAME}"
echo "[PHASE5_INFO] official FPGA setup command: make -C ${SOC_DIR}/fpga setup FPGA_NAME=${FPGA_NAME}"
echo "[PHASE5_INFO] official FPGA bitstream command: make -C ${SOC_DIR}/fpga bit FPGA_NAME=${FPGA_NAME}"
echo "[PHASE5_INFO] next manual checks: board power, JTAG cable, UART console, and memory map consistency"
