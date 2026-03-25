# Development Progress Log

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## Purpose

This file is the chronological record of project work. Use
`PHASE_HISTORY.md` for stage-organized reading and `CURRENT_STATE.md` for the
current truth.

## Phase Map

| Phase | Meaning |
|-------|---------|
| Phase 1 | SoC minimum closure |
| Phase 2 | Interface safety validation |
| Phase 3 | Software path closure |
| Phase 4 | Engineering cleanup and recovery |
| Phase 5 | Board bring-up preparation |

## Current Working Branch

- `bringup_v1`

## Timeline

| Date | Phase | Item | Result |
|------|-------|------|--------|
| 2026-03-18 | Phase 1 | Cloned the private repository and configured long-term GitHub SSH access on this machine. | Done |
| 2026-03-19 | Phase 1 | Created `bringup_v1` to isolate bring-up work from `main`. | Done |
| 2026-03-19 | Phase 1 | Installed local simulation tools and verified `gen_model` plus `run_hw`. | Done |
| 2026-03-19 | Phase 1 | Restored `third_party/nuclei-sdk` and fixed local helper path gaps. | Done |
| 2026-03-19 | Phase 1 | Corrected the E203 NICE-side integration behavior and stabilized the core command path. | Done |
| 2026-03-19 | Phase 2 | Expanded local mock verification for normal, negative, boundary, invalid-index, partial-load, and early-`RSTAT` cases. | Done |
| 2026-03-20 | Phase 1 | Pushed the bring-up branch to GitHub as `origin/bringup_v1`. | Done |
| 2026-03-20 | Phase 2 | Updated the official lightweight NICE flow to the validated `xspec + funct7` behavior. | Done |
| 2026-03-20 | Phase 2 | Closed interface safety coverage for invalid opcode, invalid `funct7`, repeated `RSTAT`, busy blocking, and reset-clears-state. | Done |
| 2026-03-20 | Phase 2 | Promoted the validated interface-safe baseline to `V1.6`. | Done |
| 2026-03-21 | Phase 3 | Trimmed startup assumptions and confirmed software-driven full-SoC execution reaches `RSTAT=320`. | Phase 3 closed |
| 2026-03-21 | Phase 4 | Exported the nested SDK delta, added a one-command regression flow, and documented recovery. | Phase 4 closed |
| 2026-03-21 | Phase 5 | Locked the first board-prep target and documented board dependencies and debug hooks. | Phase 5 baseline |
| 2026-03-21 | Phase 5 | Restored the current NICE completion protocol and added a one-command pre-board verification sweep. | Pre-board verified |
| 2026-03-21 | Phase 5 | Formalized the CNN-to-E203 integration boundary and FPGA handoff boundary. | Integration formalized |
| 2026-03-21 | Phase 5 | Consolidated the first delivery package and prepared the project for GitHub sync. | Delivery organized |
| 2026-03-26 | Phase 5 | Added a minimal CNN v1 delivery summary and aligned the board-prep package with the current baseline. | V1.8 documented |
| 2026-03-26 | Phase 5 | Added `PHASE_HISTORY.md`, added `PROJECT_RULES.md`, and unified the core document set under `V1.9`. | Docs package updated |

## Reading Guidance

| Need | Document |
|------|----------|
| Resume work now | [CURRENT_STATE.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/CURRENT_STATE.md) |
| Understand by phase | [PHASE_HISTORY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE_HISTORY.md) |
| Understand the current package | [SUMMARY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/SUMMARY.md) |
