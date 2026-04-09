# Current State

> **Version**: V2.0 | **Updated**: 2026-04-10 | **Owner**: Justin JU

## Purpose

Session recovery file. Read this first before continuing implementation work.

## Current Snapshot

| Item | Value |
|------|-------|
| Branch | `bringup_v1` |
| Active phase | `Phase 5` |
| Current baseline | A7-100T Route A functional bring-up |
| Latest document package | `V2.0` |

## Repositories

| Repo | Path | Branch |
|------|------|--------|
| Main repo | `E:\riscv-workspace\repos\riscv_cnn_accelerator` | `bringup_v1` |
| SoC repo | `E:\riscv-workspace\repos\e203_hbirdv2` | `cnn_bringup_v1` |

## Closed Technical Baseline

- E203/NICE integration is formally locked.
- The command path `CLEAR/WLOAD/DLOAD/COMP/RSTAT` is stable.
- Minimal CNN v1 software flow is aligned across SDK app, firmware, and demo path.
- CPU-only and accelerator-visible result comparison has been integrated.
- Pre-board verification scripts are available as the gate before any FPGA work.
- A7-100T Vivado programming via `PTD04` has been proven on real hardware.
- The active board strategy is now Route A: UART + LED + ILA evidence first.

## Verified Items

| Item | Status |
|------|--------|
| `./Project_Manager.sh gen_model` | Passed |
| `./Project_Manager.sh run_hw` | Passed |
| `./Project_Manager.sh precheck` | Passed |
| `bash scripts/run_sdk_fullsoc_regression.sh` | Passed |
| `bash scripts/run_preboard_verification.sh` | Passed |
| `bash scripts/check_phase5_board_env.sh` | Passed with updated A7-100T defaults |
| `PTD04 + Vivado` FPGA programming | Passed |
| A7-100T Route A bitstream rebuild | Passed |

## Current Result Baseline

| Flow | Expected result |
|------|-----------------|
| Historical Phase 3 dot-product closure | `RSTAT=320` |
| Current minimal CNN v1 full-SoC flow | `expected_rstat = 19` |

## Host Tools

| Tool | Status |
|------|--------|
| `riscv64-unknown-elf-gcc` | Available |
| `riscv64-unknown-elf-gdb` | Available |
| `openocd` | Available |
| `vivado` | Confirmed |
| `PTD04` | Confirmed for FPGA download |

## Remaining Gaps

- UART COM port still needs to be locked for board log capture.
- Route A board evidence is still pending:
  - UART milestones
  - LED stage observation
  - ILA capture of CPU/NICE activity
- `PTD04` does not yet provide CPU software debug; `BSCANE2` remains a later research path.

## Active Direction

- Keep the SoC-side integration boundary unchanged.
- Preserve the current `evalsoc + nuclei_fpga_eval + n300 + ilm` software-facing path.
- Treat `davinci_a7_100t` as the active board shell target.
- Prioritize Route A functional validation before Route B debug-chain work.
- Keep `PTD04 + BSCANE2` as a non-blocking follow-up research item.

## What To Read Next

| Goal | Document |
|------|----------|
| Understand the whole delivery | [SUMMARY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/SUMMARY.md) |
| Understand all historical work by phase | [PHASE_HISTORY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE_HISTORY.md) |
| See dated progress | [PROGRESS.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PROGRESS.md) |
| Continue board preparation | [PHASE5_BOARD_PREP.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE5_BOARD_PREP.md) |
| Continue A7-100T board bring-up | [DAVINCI_A7_100T_BRINGUP_V2_0.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/DAVINCI_A7_100T_BRINGUP_V2_0.md) |
| Follow long-term collaboration requirements | [PROJECT_RULES.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PROJECT_RULES.md) |

## Reading Rules

- Use this document for current truth only.
- Use `PHASE_HISTORY.md` for stage-by-stage history.
- Use `PROGRESS.md` for chronological reconstruction.
- Update this file when the current baseline or active blockers change.
