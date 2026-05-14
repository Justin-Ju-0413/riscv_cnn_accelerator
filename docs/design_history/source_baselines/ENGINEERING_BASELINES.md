# Engineering Baselines

This file records the source-code baselines and engineering evidence chain for the CNN accelerator project.

## Active Repositories

| Repository | Branch | Commit | Role |
| --- | --- | --- | --- |
| `riscv_cnn_accelerator` | `codex/a7-bringup-v2-main` | `ba847db4ecc6d696e55a5576e3e17164ac83cb97` | CNN accelerator RTL, software driver, SDK demo, and scripts |
| `e203_hbirdv2` | `codex/a7-bringup-v2-soc` | `1d609725740752b4d4de79a903574b94564538d1` | E203 SoC integration and NICE decoder fix |

## Historical Branches

These branches are retained as history, not as the active engineering baseline:

- `main`
- `master`
- `bringup_v1`
- `cnn_bringup_v1`

## Current Engineering Result

- RTL/NICE unit behavior verified.
- Software-driven full-SoC simulation verified.
- `hello_e203` board validation closed with UART and ILA evidence.
- CNN/NICE board validation closed for the recorded CNN v1 test.
- NICE rs2 index capture bug fixed and board-regressed.

## Key Milestones

| Date | Milestone | Evidence |
| --- | --- | --- |
| 2026-04-23 | RTL and full-SoC baseline rerun | `../verification/` |
| 2026-04-28 | Board clock/JTAG/ILA bring-up and runtime evidence | `../board_bringup/2026-04-28_board_connection_check/` |
| 2026-04-30 | `hello_e203` board validation and boot-chain closure | `../board_bringup/2026-04-28_board_connection_check/hello_e203_board_artifacts/` |
| 2026-05-09 | NICE rs2 fix and CNN v1 board regression | `../board_bringup/2026-05-09_nice_rs2_fix_verification/` |

## NICE rs2 Index Capture Fix

The E203 decoder originally skipped capturing the rs2 register index for NICE instructions when the encoded rs2 value was zero. In this accelerator design, the NICE rs2 field carries an accelerator vector index, not a normal GPR value. Therefore index zero is valid and must still be captured.

Fixes:

- SoC RTL: force NICE rs2 index capture when `nice_need_rs2=1`.
- Accelerator software: harden inline assembly constraints to avoid accidental x0 allocation hazards.

Verification:

- FPGA `cnn_sysclk_ila` rebuild passed timing.
- Board programming passed on Davinci Pro A7-100T.
- ILA capture completed.
- UART reported SW/HW/Expected outputs matching and `CNN v1 DEMO PASSED`.

## Files Changed In Source Repositories

| Repository | File | Purpose |
| --- | --- | --- |
| `e203_hbirdv2` | `rtl/e203/core/e203_exu_decode.v` | RTL decoder fix |
| `riscv_cnn_accelerator` | `sw/inc/custom_insn.h` | Software-side NICE rs2 constraint hardening |
