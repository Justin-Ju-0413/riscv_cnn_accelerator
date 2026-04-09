#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_DIR="${SDK_DIR:-${ROOT_DIR}/third_party/nuclei-sdk}"
SOC_DIR="${SOC_DIR:-}"
GCC_ROOT="${RISCV_GCC_ROOT:-}"
RISCV_GDB_BIN="${RISCV_GDB_BIN:-}"
OPENOCD_BIN="${OPENOCD_BIN:-}"
VIVADO_BIN="${VIVADO_BIN:-}"
SERIAL_DEV="${SERIAL_DEV:-}"
TARGET_BOARD="${TARGET_BOARD:-nuclei_fpga_eval}"
TARGET_SOC="${TARGET_SOC:-evalsoc}"
TARGET_CORE="${TARGET_CORE:-n300}"
FPGA_NAME="${FPGA_NAME:-davinci_a7_100t}"
BOARD_FAMILY="${BOARD_FAMILY:-davinci_pro}"
EXPECTED_PART="${EXPECTED_PART:-xc7a100tfgg484-2}"

pass() { echo "[PHASE5_OK] $1"; }
warn() { echo "[PHASE5_WARN] $1"; }
fail() { echo "[PHASE5_FAIL] $1"; }
info() { echo "[PHASE5_INFO] $1"; }

is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

path_exists() {
  [[ -e "$1" ]]
}

bin_exists() {
  [[ -x "$1" ]]
}

gcc_bin_from_root() {
  local root="$1"
  if [[ -x "${root}/bin/riscv64-unknown-elf-gcc" ]]; then
    echo "${root}/bin/riscv64-unknown-elf-gcc"
    return
  fi
  if [[ -x "${root}/gcc/bin/riscv64-unknown-elf-gcc" ]]; then
    echo "${root}/gcc/bin/riscv64-unknown-elf-gcc"
  fi
}

gdb_bin_from_root() {
  local root="$1"
  if [[ -x "${root}/bin/riscv64-unknown-elf-gdb" ]]; then
    echo "${root}/bin/riscv64-unknown-elf-gdb"
    return
  fi
  if [[ -x "${root}/gcc/bin/riscv64-unknown-elf-gdb" ]]; then
    echo "${root}/gcc/bin/riscv64-unknown-elf-gdb"
    return
  fi
  if [[ -x "${root}/bin/gdb-multiarch" ]]; then
    echo "${root}/bin/gdb-multiarch"
    return
  fi
  if [[ -x "${root}/gcc/bin/gdb-multiarch" ]]; then
    echo "${root}/gcc/bin/gdb-multiarch"
  fi
}

check_path() {
  local path="$1"
  local label="$2"
  if path_exists "$path"; then
    pass "${label}: ${path}"
  else
    fail "missing ${label}: ${path}"
  fi
}

check_bin() {
  local path="$1"
  local label="$2"
  if bin_exists "$path"; then
    pass "${label}: ${path}"
  else
    fail "missing ${label}: ${path}"
  fi
}

find_soc_dir() {
  if [[ -n "${SOC_DIR}" && -d "${SOC_DIR}" ]]; then
    echo "${SOC_DIR}"
    return
  fi

  local candidates=(
    "${ROOT_DIR}/../e203_hbirdv2"
    "${ROOT_DIR}/e203_hbirdv2"
    "/mnt/e/riscv-workspace/repos/e203_hbirdv2"
    "/home/${USER}/workspace/e203_hbirdv2"
    "/mnt/c/Users/${USER}/Documents/e203_hbirdv2"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -d "${candidate}" ]]; then
      echo "${candidate}"
      return
    fi
  done
}

find_gcc_root() {
  if [[ -n "${GCC_ROOT}" && -d "${GCC_ROOT}" ]]; then
    echo "${GCC_ROOT}"
    return
  fi

  local glob_candidate
  for glob_candidate in /mnt/e/riscv-workspace/toolchains/*; do
    if [[ -n "$(gcc_bin_from_root "${glob_candidate}" || true)" ]]; then
      echo "${glob_candidate}"
      return
    fi
  done

  local candidates=(
    "/mnt/e/riscv-workspace/toolchains/riscv"
    "/mnt/e/riscv-workspace/toolchains/nuclei/gcc-embedded"
    "/opt/riscv"
    "/usr/local/riscv"
    "/home/${USER}/gcc"
    "/mnt/c/NucleiStudio/toolchain/gcc"
    "/usr"
  )

  local candidate
  for candidate in "${candidates[@]}"; do
    if [[ -n "$(gcc_bin_from_root "${candidate}" || true)" ]]; then
      echo "${candidate}"
      return
    fi
  done

  if command -v riscv64-unknown-elf-gcc >/dev/null 2>&1; then
    dirname "$(dirname "$(command -v riscv64-unknown-elf-gcc)")"
    return
  fi
}

find_openocd_bin() {
  if [[ -n "${OPENOCD_BIN}" ]]; then
    echo "${OPENOCD_BIN}"
    return
  fi

  if command -v openocd >/dev/null 2>&1; then
    command -v openocd
  fi
}

find_vivado_bin() {
  if [[ -n "${VIVADO_BIN}" ]]; then
    echo "${VIVADO_BIN}"
    return
  fi

  if command -v vivado >/dev/null 2>&1; then
    command -v vivado
    return
  fi

  if is_wsl; then
    local candidate
    local candidates=(
      "/mnt/c/Xilinx/Vivado/2024.2/bin/vivado.bat"
      "/mnt/c/Xilinx/Vivado/2024.1/bin/vivado.bat"
      "/mnt/c/Xilinx/Vivado/2023.2/bin/vivado.bat"
      "/mnt/c/Xilinx/Vivado/2023.1/bin/vivado.bat"
      "/mnt/c/AMD/Vivado/2024.2/bin/vivado.bat"
      "/mnt/c/AMD/Vivado/2024.1/bin/vivado.bat"
    )
    for candidate in "${candidates[@]}"; do
      if [[ -f "${candidate}" ]]; then
        echo "${candidate}"
        return
      fi
    done
  fi
}

supports_nuclei_n300_tune() {
  local gcc_bin="$1"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  cat >"${tmp_dir}/probe.c" <<'EOF'
int main(void) { return 0; }
EOF

  if "${gcc_bin}" -mtune=nuclei-300-series -march=rv32imac -mabi=ilp32 \
      -c "${tmp_dir}/probe.c" -o "${tmp_dir}/probe.o" >/dev/null 2>&1; then
    rm -rf "${tmp_dir}"
    return 0
  fi

  rm -rf "${tmp_dir}"
  return 1
}

find_riscv_gdb_bin() {
  if [[ -n "${RISCV_GDB_BIN}" ]]; then
    echo "${RISCV_GDB_BIN}"
    return
  fi

  if command -v riscv64-unknown-elf-gdb >/dev/null 2>&1; then
    command -v riscv64-unknown-elf-gdb
    return
  fi

  if command -v gdb-multiarch >/dev/null 2>&1; then
    command -v gdb-multiarch
    return
  fi

  if [[ -n "${GCC_ROOT}" ]]; then
    local gdb_from_root
    gdb_from_root="$(gdb_bin_from_root "${GCC_ROOT}" || true)"
    if [[ -n "${gdb_from_root}" ]]; then
      echo "${gdb_from_root}"
    fi
  fi
}

SOC_DIR="$(find_soc_dir || true)"
GCC_ROOT="$(find_gcc_root || true)"
OPENOCD_BIN="$(find_openocd_bin || true)"
VIVADO_BIN="$(find_vivado_bin || true)"
RISCV_GDB_BIN="$(find_riscv_gdb_bin || true)"

if [[ "${SDK_DIR}" == "${ROOT_DIR}/third_party/nuclei-sdk" && -d "/mnt/e/riscv-workspace/repos/riscv_cnn_accelerator/third_party/nuclei-sdk" ]]; then
  SDK_DIR="/mnt/e/riscv-workspace/repos/riscv_cnn_accelerator/third_party/nuclei-sdk"
fi

check_path "${ROOT_DIR}" "main repo"
check_path "${SDK_DIR}" "SDK directory"

if [[ -n "${SOC_DIR}" ]]; then
  check_path "${SOC_DIR}" "E203 SoC repo"
else
  fail "unable to locate E203 SoC repo; set SOC_DIR explicitly"
fi

if [[ -n "${GCC_ROOT}" ]]; then
  GCC_BIN="$(gcc_bin_from_root "${GCC_ROOT}" || true)"
  if [[ -n "${GCC_BIN}" ]]; then
    check_bin "${GCC_BIN}" "RISC-V GCC"
  else
    fail "unable to locate riscv64-unknown-elf-gcc under RISCV_GCC_ROOT=${GCC_ROOT}"
  fi
  if [[ -n "${GCC_BIN}" ]] && supports_nuclei_n300_tune "${GCC_BIN}"; then
    pass "Nuclei n300 tune support: ${GCC_BIN}"
  else
    fail "RISC-V GCC lacks -mtune=nuclei-300-series support: ${GCC_BIN:-${GCC_ROOT}}"
  fi
else
  fail "unable to locate RISC-V GCC root; set RISCV_GCC_ROOT explicitly"
fi

if [[ -n "${RISCV_GDB_BIN}" ]]; then
  pass "RISC-V GDB: ${RISCV_GDB_BIN}"
else
  fail "unable to locate RISC-V GDB; set RISCV_GDB_BIN explicitly"
fi

check_path "${SDK_DIR}/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg" "evalsoc OpenOCD config"
check_path "${SDK_DIR}/application/baremetal/cnn_accel_demo" "SDK app path"

if [[ -n "${SOC_DIR}" ]]; then
  check_path "${SOC_DIR}/fpga/Makefile" "official FPGA top Makefile"
fi

case "${FPGA_NAME}" in
  davinci_a7_100t|davinci_a7_35t|mcu200t|ddr200t)
    pass "FPGA shell target: ${FPGA_NAME}"
    ;;
  *)
    fail "unsupported FPGA_NAME=${FPGA_NAME}"
    exit 1
    ;;
esac

if [[ -n "${SOC_DIR}" ]]; then
  if [[ -d "${SOC_DIR}/fpga/${FPGA_NAME}" ]]; then
    pass "board target exists: ${SOC_DIR}/fpga/${FPGA_NAME}"
    check_path "${SOC_DIR}/fpga/${FPGA_NAME}/src/system.v" "board shell system.v"
    check_path "${SOC_DIR}/fpga/${FPGA_NAME}/constrs/nuclei-config.xdc" "board config XDC"
    check_path "${SOC_DIR}/fpga/${FPGA_NAME}/constrs/nuclei-master.xdc" "board master XDC"
    check_path "${SOC_DIR}/fpga/${FPGA_NAME}/script/board.tcl" "board Tcl entry"
  else
    warn "board target missing: ${SOC_DIR}/fpga/${FPGA_NAME}"
  fi
fi

if [[ -n "${OPENOCD_BIN}" ]]; then
  pass "openocd found: ${OPENOCD_BIN}"
else
  warn "openocd not found in PATH"
fi

if [[ -n "${VIVADO_BIN}" ]]; then
  if [[ -f "${VIVADO_BIN}" || -x "${VIVADO_BIN}" ]]; then
    pass "Vivado launcher found: ${VIVADO_BIN}"
  else
    warn "explicit VIVADO_BIN does not exist: ${VIVADO_BIN}"
  fi
else
  warn "Vivado launcher not found; set VIVADO_BIN explicitly"
fi

if is_wsl; then
  pass "host environment: WSL"
  if command -v powershell.exe >/dev/null 2>&1; then
    pass "powershell.exe available from WSL"
  else
    warn "powershell.exe not visible from WSL"
  fi
fi

if [[ -n "${SERIAL_DEV}" ]]; then
  if [[ -e "${SERIAL_DEV}" ]]; then
    pass "UART serial device: ${SERIAL_DEV}"
  else
    warn "SERIAL_DEV is set but not present in WSL: ${SERIAL_DEV}"
  fi
else
  warn "SERIAL_DEV not set"
fi

if command -v lsusb >/dev/null 2>&1; then
  if lsusb | grep -qi '0403:6010'; then
    pass "FTDI JTAG device detected via lsusb (0403:6010)"
  else
    warn "FTDI JTAG device 0403:6010 not detected via lsusb"
  fi
else
  warn "lsusb not available; USB visibility check skipped"
fi

info "expected FPGA part: ${EXPECTED_PART}"
info "recommended board target: SOC=${TARGET_SOC} BOARD=${TARGET_BOARD} CORE=${TARGET_CORE} DOWNLOAD=ilm"
info "current FPGA shell target: FPGA_NAME=${FPGA_NAME}"
info "board family hint: ${BOARD_FAMILY}"
info "recommended OpenOCD config: ${SDK_DIR}/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg"
info "official FPGA install command: make -C ${SOC_DIR}/fpga install FPGA_NAME=${FPGA_NAME}"
info "official FPGA bitstream command: VIVADO=${VIVADO_BIN:-vivado} make -C ${SOC_DIR}/fpga bit FPGA_NAME=${FPGA_NAME}"
