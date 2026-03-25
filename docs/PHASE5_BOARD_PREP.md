# Phase 5 Board Bring-Up Preparation

> **Version**: V1.7 | **Updated**: 2026-03-24 | **Owner**: Justin JU

## Goal

Prepare the validated software-driven simulation flow for later hardware board validation.

## Recommended First Hardware Target

Use the current SDK-aligned evalsoc path as the first hardware target:

- `SOC=evalsoc`
- `BOARD=nuclei_fpga_eval`
- `CORE=n300`
- `DOWNLOAD=ilm`
- `FPGA_NAME=davinci_a7_35t` as the default shell to inspect and try first

Reason:
- the working SDK app already builds against `evalsoc`
- the SDK already provides a matching board directory and OpenOCD config
- this is the smallest gap from the validated Phase 4 simulation flow

## Default Shell Mapping

Keep the software-visible board target and the FPGA shell target distinct:

- SDK / OpenOCD target:
  - `SOC=evalsoc`
  - `BOARD=nuclei_fpga_eval`
  - `CORE=n300`
- official FPGA shell target:
  - default `FPGA_NAME=davinci_a7_35t`
  - fallback `FPGA_NAME=mcu200t` / `ddr200t` only if the board path changes back to the official eval boards

Current official shell entry files:

- Davinci A7-35T shell:
  - [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/src/system.v)
  - [nuclei-config.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/constrs/nuclei-config.xdc)
  - [nuclei-master.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/davinci_a7_35t/constrs/nuclei-master.xdc)
- MCU200T shell:
  - [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/mcu200t/src/system.v)
  - [nuclei-config.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/mcu200t/constrs/nuclei-config.xdc)
  - [nuclei-master.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/mcu200t/constrs/nuclei-master.xdc)
- DDR200T shell:
  - [system.v](/home/gstar/Desktop/e203_hbirdv2/fpga/ddr200t/src/system.v)
  - [nuclei-config.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/ddr200t/constrs/nuclei-config.xdc)
  - [nuclei-master.xdc](/home/gstar/Desktop/e203_hbirdv2/fpga/ddr200t/constrs/nuclei-master.xdc)

## Current Dependency Baseline On This Machine

Available now:
- `riscv64-unknown-elf-gcc`
- `riscv64-unknown-elf-gdb`
- `openocd`
- SDK source tree under `third_party/nuclei-sdk`
- evalsoc board OpenOCD config:
  - [openocd_evalsoc.cfg](/home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg)

Remaining gaps on this machine after rerunning `check_phase5_board_env.sh`:
- a connected FTDI/JTAG adapter matching the board config `0403:6010`
- a locked UART serial device path
- a detected `vivado` executable or explicit `VIVADO_BIN`
- a real FPGA bitstream / board image containing the integrated NICE RTL
- board-side memory-map confirmation against the current simulation assumptions
- optional Nuclei model availability

## Debug Hooks To Keep

Software-visible hook:
- continue using the `cnn_accel_demo` app and preserve the `CLEAR/WLOAD/DLOAD/COMP/RSTAT` sequence

JTAG hook:
- recommended first debug path is OpenOCD + GDB with:
  - [openocd_evalsoc.cfg](/home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg)

UART hook:
- lock one serial path for board logs before first hardware run
- keep a simple pass/fail print in the board-oriented app path once board stdout is available

Simulation hook:
- keep [run_sdk_fullsoc_regression.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh) as the pre-board gate
- do not attempt board runs until that regression still passes on the current tree

## Simulation-To-Board Gaps

These are the main gaps still separating Phase 4 simulation closure from board execution:

1. The current validated path loads ITCM/DTCM images directly in simulation.
2. Real board bring-up will need a download path through JTAG/OpenOCD or another board-specific loader.
3. The current SDK app uses `E203_HBIRD_SAFE_STARTUP` to trim evalsoc startup assumptions.
4. A real board run must confirm that the same trimmed startup is still valid with the actual board clocks, reset, and UART path.
5. The SoC simulation observes NICE activity directly through testbench logs.
6. A board run will need equivalent observability via UART prints, GDB register inspection, or additional software breadcrumbs.
7. The simulation environment bypasses board-level peripherals and timing uncertainty.
8. A board run must separately validate board power-on, reset release, JTAG attach, and serial console behavior.

## First Board Run Checklist

1. Run the full pre-board verification sweep:
   - `bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_preboard_verification.sh`
2. Run the board environment checker:
   - `bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/check_phase5_board_env.sh`
3. Print the exact first-run commands:
   - `bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/print_fpga_bringup_commands.sh`
4. Confirm the actual hardware target still matches `SOC=evalsoc BOARD=nuclei_fpga_eval CORE=n300 DOWNLOAD=ilm`.
5. Confirm the default shell target `FPGA_NAME=davinci_a7_35t` is still aligned with the real board manual and pin map.
6. Confirm `openocd` is installed and the FTDI adapter is visible.
7. Lock the UART device path and baud rate for log collection.
8. Confirm the FPGA image or board firmware really contains the integrated NICE-enabled SoC.
9. Only then attempt JTAG attach, program load, and `cnn_accel_demo` execution.

## Suggested First OpenOCD And GDB Flow

Open terminal 1:

```bash
openocd -f /home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg
```

Open terminal 2:

```bash
/home/gstar/Desktop/gcc/bin/riscv64-unknown-elf-gdb \
  /home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk/application/baremetal/cnn_accel_demo/cnn_accel_demo.elf
```

Suggested early GDB commands:

```gdb
target remote :3333
monitor reset halt
load
break main
continue
```

## Phase 5 Exit Direction

Phase 5 will be considered ready to close when the following are explicit and low-ambiguity:
- required host tools
- actual board target and download path
- JTAG attach method
- UART observation path
- simulation-to-board functional gaps
- first board-run checklist
