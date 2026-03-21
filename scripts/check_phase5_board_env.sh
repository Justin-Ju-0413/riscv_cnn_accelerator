#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_DIR="${SDK_DIR:-${ROOT_DIR}/third_party/nuclei-sdk}"
GCC_ROOT="${RISCV_GCC_ROOT:-/home/gstar/Desktop/gcc}"
OPENOCD_BIN="${OPENOCD_BIN:-}"
SERIAL_DEV="${SERIAL_DEV:-}"
TARGET_BOARD="${TARGET_BOARD:-nuclei_fpga_eval}"
TARGET_SOC="${TARGET_SOC:-evalsoc}"
TARGET_CORE="${TARGET_CORE:-n300}"

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
check_bin "${GCC_ROOT}/bin/riscv64-unknown-elf-gcc" "RISC-V GCC"
check_bin "${GCC_ROOT}/bin/riscv64-unknown-elf-gdb" "RISC-V GDB"
check_path "${SDK_DIR}/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg" "evalsoc OpenOCD config"
check_path "${SDK_DIR}/application/baremetal/cnn_accel_demo" "SDK app path"

if [[ -n "${OPENOCD_BIN}" ]]; then
  check_optional_bin "${OPENOCD_BIN}" "explicit OPENOCD_BIN"
else
  if command -v openocd >/dev/null 2>&1; then
    pass "openocd found in PATH: $(command -v openocd)"
  else
    warn "openocd not found in PATH"
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
echo "[PHASE5_INFO] recommended OpenOCD config: ${SDK_DIR}/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg"
echo "[PHASE5_INFO] next manual checks: board power, JTAG cable, UART console, and memory map consistency"
