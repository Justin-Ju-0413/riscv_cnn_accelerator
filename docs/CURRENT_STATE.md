# Current State

> **Version**: V1.9 | **Updated**: 2026-08-12 | **Owner**: Justin JU

## Purpose

Session recovery file. Read this first before continuing implementation work.

## Repository Governance Note

`main` is the maintained landing branch for documentation, CI, and immutable
Release navigation. The FYP is complete. Older A7, environment-baseline, and
MPhil branches are retained research snapshots, not active delivery lines.
Use the paired Release tags below for reproducible work and read
`BRANCH_STRATEGY.md` before starting new research.

## Current Snapshot

| Item | Value |
|------|-------|
| Branch | `main` |
| Branch role | Maintained landing and release navigation |
| Project phase | FYP closed; research lineage retained |
| Reproducible baseline | `env-baseline-2026-07-27` |
| Bounded MPhil PoC | `mphil-nice-v2-poc-v0.1.0` |
| Latest document package | `V1.9` |

## Repositories

| Repo | Path | Branch |
|------|------|--------|
| Main repo | `<repo-root>` | `main` |
| SoC repo | `${SOC_DIR}` | `main` |

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

## Maintenance Direction

- Keep the SoC-side integration boundary and NICE encodings unchanged.
- Preserve the paired baseline and MPhil PoC tags as immutable evidence.
- Treat A7 board work, constraints, UART/JTAG/ILA, and Vivado results as
  historical unless a new explicitly scoped research stream revalidates them.
- Preserve the existing `evalsoc + nuclei_fpga_eval + n300 + ilm` evidence path.

## What To Read Next

| Goal | Document |
|------|----------|
| Understand the whole delivery | [SUMMARY.md](SUMMARY.md) |
| Understand all historical work by phase | [PHASE_HISTORY.md](PHASE_HISTORY.md) |
| See dated progress | [PROGRESS.md](PROGRESS.md) |
| Understand historical board preparation | [PHASE5_BOARD_PREP.md](PHASE5_BOARD_PREP.md) |
| Follow long-term collaboration requirements | [PROJECT_RULES.md](PROJECT_RULES.md) |

## Reading Rules

- Use `BRANCH_STRATEGY.md` to confirm whether you should stay on this branch.
- Treat this file as the maintained repository state of `main`.
- Use `PHASE_HISTORY.md` for stage-by-stage history.
- Use `PROGRESS.md` for chronological reconstruction.
- Update this file when the current baseline or active blockers change.
