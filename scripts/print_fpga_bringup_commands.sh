#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOC_DIR="${SOC_DIR:-/home/gstar/Desktop/e203_hbirdv2}"
SDK_DIR="${SDK_DIR:-${ROOT_DIR}/third_party/nuclei-sdk}"
GCC_ROOT="${RISCV_GCC_ROOT:-/home/gstar/Desktop/gcc}"
FPGA_NAME="${FPGA_NAME:-mcu200t}"
TARGET_SOC="${TARGET_SOC:-evalsoc}"
TARGET_BOARD="${TARGET_BOARD:-nuclei_fpga_eval}"
TARGET_CORE="${TARGET_CORE:-n300}"
DOWNLOAD_MODE="${DOWNLOAD_MODE:-ilm}"
SERIAL_DEV="${SERIAL_DEV:-/dev/ttyUSB0}"

APP_DIR="${SDK_DIR}/application/baremetal/cnn_accel_demo"
APP_ELF="${APP_DIR}/cnn_accel_demo.elf"
OPENOCD_CFG="${SDK_DIR}/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg"

cat <<EOF
# FPGA Bring-Up Command Sheet

## 1. Pre-board gates
bash ${ROOT_DIR}/scripts/run_preboard_verification.sh
bash ${ROOT_DIR}/scripts/check_phase5_board_env.sh

## 2. Rebuild SDK app
cd ${APP_DIR}
make clean all SOC=${TARGET_SOC} BOARD=${TARGET_BOARD} CORE=${TARGET_CORE} DOWNLOAD=${DOWNLOAD_MODE}

## 3. Prepare official FPGA shell
make -C ${SOC_DIR}/fpga install FPGA_NAME=${FPGA_NAME}
make -C ${SOC_DIR}/fpga setup FPGA_NAME=${FPGA_NAME}

## 4. Build first bitstream
make -C ${SOC_DIR}/fpga bit FPGA_NAME=${FPGA_NAME}

## 5. OpenOCD
openocd -f ${OPENOCD_CFG}

## 6. GDB
${GCC_ROOT}/bin/riscv64-unknown-elf-gdb ${APP_ELF}

## 7. Suggested GDB commands
target remote :3333
monitor reset halt
load
break main
continue

## 8. Suggested UART monitor
picocom -b 115200 ${SERIAL_DEV}
EOF
