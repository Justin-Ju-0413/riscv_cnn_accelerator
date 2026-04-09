#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOC_DIR="${SOC_DIR:-/mnt/e/riscv-workspace/repos/e203_hbirdv2}"
SDK_DIR="${SDK_DIR:-/mnt/e/riscv-workspace/repos/riscv_cnn_accelerator/third_party/nuclei-sdk}"
GCC_ROOT="${RISCV_GCC_ROOT:-}"
RISCV_GDB_BIN="${RISCV_GDB_BIN:-}"
FPGA_NAME="${FPGA_NAME:-davinci_a7_100t}"
TARGET_SOC="${TARGET_SOC:-evalsoc}"
TARGET_BOARD="${TARGET_BOARD:-nuclei_fpga_eval}"
TARGET_CORE="${TARGET_CORE:-n300}"
DOWNLOAD_MODE="${DOWNLOAD_MODE:-ilm}"
SERIAL_DEV="${SERIAL_DEV:-}"
VIVADO_BIN="${VIVADO_BIN:-/mnt/c/Xilinx/Vivado/2023.2/bin/vivado.bat}"

if [[ -z "${GCC_ROOT}" ]] && command -v riscv64-unknown-elf-gcc >/dev/null 2>&1; then
  GCC_ROOT="$(dirname "$(dirname "$(command -v riscv64-unknown-elf-gcc)")")"
fi

if [[ -z "${RISCV_GDB_BIN}" ]] && command -v riscv64-unknown-elf-gdb >/dev/null 2>&1; then
  RISCV_GDB_BIN="$(command -v riscv64-unknown-elf-gdb)"
fi

if [[ -z "${RISCV_GDB_BIN}" ]] && command -v gdb-multiarch >/dev/null 2>&1; then
  RISCV_GDB_BIN="$(command -v gdb-multiarch)"
fi

if [[ -z "${GCC_ROOT}" ]] && [[ -x "/mnt/e/riscv-workspace/toolchains/nuclei/gcc-embedded/bin/riscv64-unknown-elf-gcc" ]]; then
  GCC_ROOT="/mnt/e/riscv-workspace/toolchains/nuclei/gcc-embedded"
fi

if [[ -z "${RISCV_GDB_BIN}" ]] && [[ -x "/mnt/e/riscv-workspace/toolchains/nuclei/gcc-embedded/bin/riscv64-unknown-elf-gdb" ]]; then
  RISCV_GDB_BIN="/mnt/e/riscv-workspace/toolchains/nuclei/gcc-embedded/bin/riscv64-unknown-elf-gdb"
fi

if [[ -z "${GCC_ROOT}" ]] && [[ -x "/usr/bin/riscv64-unknown-elf-gcc" ]]; then
  GCC_ROOT="/usr"
fi

APP_DIR="${SDK_DIR}/application/baremetal/cnn_accel_demo"
APP_ELF="${APP_DIR}/cnn_accel_demo.elf"
OPENOCD_CFG="${SDK_DIR}/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg"

cat <<EOF
# FPGA Bring-Up Command Sheet

## 1. Environment check
SOC_DIR=${SOC_DIR} RISCV_GCC_ROOT=${GCC_ROOT:-/usr} RISCV_GDB_BIN=${RISCV_GDB_BIN:-/usr/bin/gdb-multiarch} FPGA_NAME=${FPGA_NAME} VIVADO_BIN=${VIVADO_BIN} bash ${ROOT_DIR}/scripts/check_phase5_board_env.sh

## 2. Install/update the project demo inside nuclei-sdk
cd ${ROOT_DIR}
bash sw/build/install_sdk_app.sh

## 3. Rebuild SDK app in WSL
cd ${APP_DIR}
PATH="${GCC_ROOT}/bin:\$PATH" make clean all SOC=${TARGET_SOC} BOARD=${TARGET_BOARD} CORE=${TARGET_CORE} DOWNLOAD=${DOWNLOAD_MODE}
PATH="${GCC_ROOT}/bin:\$PATH" make dasm SOC=${TARGET_SOC} BOARD=${TARGET_BOARD} CORE=${TARGET_CORE} DOWNLOAD=${DOWNLOAD_MODE}
PATH="${GCC_ROOT}/bin:\$PATH" make cnn_accel_demo.verilog SOC=${TARGET_SOC} BOARD=${TARGET_BOARD} CORE=${TARGET_CORE} DOWNLOAD=${DOWNLOAD_MODE}

## 4. Prepare official FPGA shell in WSL
make -C ${SOC_DIR}/fpga install FPGA_NAME=${FPGA_NAME}

## 5. Build bitstream from Windows PowerShell
powershell -ExecutionPolicy Bypass -File "${ROOT_DIR}/scripts/Invoke-Vivado-Fpga.ps1" -Action bit -SocDir "E:\\riscv-workspace\\repos\\e203_hbirdv2" -FpgaName ${FPGA_NAME} -VivadoBat "C:\\Xilinx\\Vivado\\2023.2\\bin\\vivado.bat"

## 6. Program the board from Windows Vivado Hardware Manager
# Use ${SOC_DIR}/fpga/${FPGA_NAME}/obj/system.bit

## 7. OpenOCD in WSL
openocd -f ${OPENOCD_CFG}

## 8. GDB in WSL
${RISCV_GDB_BIN:-${GCC_ROOT}/bin/riscv64-unknown-elf-gdb} ${APP_ELF}

## 9. Suggested GDB commands
target remote :3333
monitor reset halt
load
break main
continue

## 10. UART observation
EOF

if [[ -n "${SERIAL_DEV}" ]]; then
  cat <<EOF
python3 -m serial.tools.miniterm ${SERIAL_DEV} 115200
EOF
else
  cat <<'EOF'
# On WSL, use the mapped /dev/ttyS* device if available.
# On Windows, use a native serial terminal against the board COM port.
EOF
fi
