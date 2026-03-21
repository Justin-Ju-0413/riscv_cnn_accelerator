# Current State

## Purpose

Single compressed state file for session recovery and low-overhead context
loading.

## Goal

Integrate the CNN NICE accelerator into `e203_hbirdv2` completely and safely.

## Version

- Current version: `V1.7`

## Active Phase

- Phase: `Phase 5 active`
- Objective: lock the board target, dependency baseline, debug hooks, and simulation-to-board gaps before the first hardware run

## Repositories

- Main repo:
  - path: `/home/gstar/Desktop/riscv_cnn_accelerator`
  - branch: `bringup_v1`
  - head: `a621629`
- SoC repo:
  - path: `/home/gstar/Desktop/e203_hbirdv2`
  - branch: `cnn_bringup_v1`
  - head: `690eec8`
  - remotes:
    - `origin` -> `git@github.com:Justin-Ju-0413/e203_hbirdv2.git`
    - `upstream` -> `https://github.com/riscv-mcu/e203_hbirdv2.git`

## Verified

- Main project checks pass:
  - `./Project_Manager.sh gen_model`
  - `./Project_Manager.sh run_hw`
  - `./Project_Manager.sh precheck`
- Phase 4 recovery entry is now validated locally:
  - [run_sdk_fullsoc_regression.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh)
  - rebuilds the SDK app
  - regenerates and splits ITCM/DTCM images
  - runs the official full-SoC E203 simulation
  - observes final `RSTAT=320`
- Current local host tools confirmed present:
  - `riscv64-unknown-elf-gcc`
  - `riscv64-unknown-elf-gdb`
- Current local host tools and board links still missing or unconfirmed after running `check_phase5_board_env.sh`:
  - `openocd` not found in `PATH`
  - FTDI/JTAG device `0403:6010` not detected via `lsusb`
  - board-side UART device path not locked via `SERIAL_DEV`
  - Nuclei model / `ncycm` still not confirmed present
- SDK-side board support confirmed present for the recommended first target:
  - `SOC=evalsoc`
  - `BOARD=nuclei_fpga_eval`
  - `CORE=n300`
  - OpenOCD config exists at
    [openocd_evalsoc.cfg](/home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg)

## Phase 2 Result

- Phase 2 is complete on the current request/response-only NICE scope.
- The integration now has:
  - Phase 1 full-SoC closure
  - Phase 2 mock-harness safety coverage
  - Phase 2 official lightweight-chain safety coverage
- No new RTL blocker was found while closing Phase 2.

## Phase 3 Result

- The official Nuclei GNU toolchain requirement is confirmed in practice.
- The SDK-native app performs software/hardware self-check logic.
- The software-driven full-SoC execution path is validated in official E203 RTL simulation.
- Two integration blockers were resolved during Phase 3 closure:
  - evalsoc startup assumptions were trimmed to an E203-safe subset for the SDK app bring-up path
  - successful non-`RSTAT` NICE operations now emit completion responses so E203 long-pipe bookkeeping can retire them

## Phase 4 Result

- The nested `third_party/nuclei-sdk` delta is exported as a portable patch.
- A reusable patch helper is available.
- A one-command SDK-to-full-SoC regression entry is available and validated.
- Recovery and handoff instructions are centralized in
  [PHASE4_RECOVERY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE4_RECOVERY.md).

## Phase 5 Progress

- Recommended first board target is now locked for preparation work:
  - `SOC=evalsoc`
  - `BOARD=nuclei_fpga_eval`
  - `CORE=n300`
  - `DOWNLOAD=ilm`
- Board-prep doc is now centralized in
  [PHASE5_BOARD_PREP.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE5_BOARD_PREP.md).
- A host dependency and connection checker is now available:
  - [check_phase5_board_env.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/check_phase5_board_env.sh)
- Main unresolved hardware-prep gaps are now explicit:
  - `openocd` installation
  - FTDI/JTAG device presence
  - UART serial path
  - real board image containing the NICE-enabled SoC
  - board-side memory map confirmation

## Execution Entry Points

- Pre-board regression gate:
  - [run_sdk_fullsoc_regression.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh)
  - `bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh`
- Board environment checker:
  - [check_phase5_board_env.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/check_phase5_board_env.sh)
  - `bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/check_phase5_board_env.sh`
- Full-SoC wrapper:
  - [run_nice_patch.sh](/home/gstar/Desktop/e203_hbirdv2/vsim/run_nice_patch.sh)
  - `bash /home/gstar/Desktop/e203_hbirdv2/vsim/run_nice_patch.sh`

## Key Files

- Board prep doc:
  - [PHASE5_BOARD_PREP.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE5_BOARD_PREP.md)
- Board environment checker:
  - [check_phase5_board_env.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/check_phase5_board_env.sh)
- Phase 4 recovery doc:
  - [PHASE4_RECOVERY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE4_RECOVERY.md)
- SDK portability patch:
  - [nuclei-sdk-phase3-e203-safe.patch](/home/gstar/Desktop/riscv_cnn_accelerator/patches/nuclei-sdk-phase3-e203-safe.patch)
- OpenOCD board config:
  - [openocd_evalsoc.cfg](/home/gstar/Desktop/riscv_cnn_accelerator/third_party/nuclei-sdk/SoC/evalsoc/Board/nuclei_fpga_eval/openocd_evalsoc.cfg)

## Next Focus

- `check_phase5_board_env.sh` now confirms the current machine still lacks `openocd`, FTDI/JTAG visibility, and a locked UART path.
- Install or connect those missing pieces before attempting any board run.
- Keep the Phase 4 simulation gate as the last check before hardware execution.
- After dependencies are real, do the first OpenOCD + GDB attach and confirm board observability.

## Compression Rules

- Read this file first in future sessions.
- Read `INTEGRATION_ROADMAP.md` only for long-range planning.
- Read `PROGRESS.md` only for dated history.
- Avoid loading multiple large docs unless the task explicitly needs them.
