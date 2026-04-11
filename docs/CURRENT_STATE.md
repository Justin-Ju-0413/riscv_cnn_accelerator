# Current State

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## Purpose

Session recovery file. Read this first before continuing implementation work.

## Branch Governance Note

This branch is the historical default line retained for compatibility. For the
stable formal baseline use `bringup_v1`. For current A7-100T / Route-A
development use `codex/a7-bringup-v2-main`. See `BRANCH_STRATEGY.md` before
starting new work from this branch.

## Current Snapshot

| Item | Value |
|------|-------|
| Branch | `main` |
| Branch role | Historical default line |
| Active phase | `Phase 5` |
| Current baseline | Minimal CNN v1 + board-prep automation |
| Latest document package | `V1.9` |

## Repositories

| Repo | Path | Branch |
|------|------|--------|
| Main repo | `/home/gstar/Desktop/riscv_cnn_accelerator` | `main` |
| SoC repo | `/home/gstar/Desktop/e203_hbirdv2` | `master` |

## Closed Technical Baseline

- E203/NICE integration is formally locked.
- The command path `CLEAR/WLOAD/DLOAD/COMP/RSTAT` is stable.
- Minimal CNN v1 software flow is aligned across SDK app, firmware, and demo path.
- CPU-only and accelerator-visible result comparison has been integrated.
- Pre-board verification scripts are available as the gate before any FPGA work.

## Verified Items

| Item | Status |
|------|--------|
| `./Project_Manager.sh gen_model` | Passed |
| `./Project_Manager.sh run_hw` | Passed |
| `./Project_Manager.sh precheck` | Passed |
| `bash scripts/run_sdk_fullsoc_regression.sh` | Passed |
| `bash scripts/run_preboard_verification.sh` | Passed |
| `bash scripts/check_phase5_board_env.sh` | Passed with expected environment gaps |

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
| `vivado` | Not yet confirmed |

## Remaining Gaps

- FTDI/JTAG hardware has not been detected on this machine.
- `SERIAL_DEV` has not been locked for UART logging.
- Real board target and final shell-to-board mapping still need confirmation.
- No bitstream-backed board execution has been validated yet.

## Active Direction

- Keep the SoC-side integration boundary unchanged.
- Use pre-board regression as the mandatory gate.
- Treat FPGA work as shell, constraints, tooling, and board-environment work first.
- Preserve the current `evalsoc + nuclei_fpga_eval + n300 + ilm` software-facing path.
- Keep `davinci_a7_35t` as the current default shell target unless board facts force a change.

## What To Read Next

| Goal | Document |
|------|----------|
| Understand the whole delivery | [SUMMARY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/SUMMARY.md) |
| Understand all historical work by phase | [PHASE_HISTORY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE_HISTORY.md) |
| See dated progress | [PROGRESS.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PROGRESS.md) |
| Continue board preparation | [PHASE5_BOARD_PREP.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE5_BOARD_PREP.md) |
| Follow long-term collaboration requirements | [PROJECT_RULES.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PROJECT_RULES.md) |

## Reading Rules

- Use `BRANCH_STRATEGY.md` to confirm whether you should stay on this branch.
- Treat this file as the documentation state of `main`, not the active
  day-to-day engineering line.
- Use `PHASE_HISTORY.md` for stage-by-stage history.
- Use `PROGRESS.md` for chronological reconstruction.
- Update this file when the current baseline or active blockers change.
