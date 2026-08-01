# Engineering Design History

This directory contains engineering-only design history copied from the local graduation design library. It intentionally excludes thesis drafts, final-defense slides, school requirement files, and submission packages.

The purpose is to keep the CNN accelerator GitHub repository self-contained enough to understand the design evolution, verification evidence, board bring-up path, and source-baseline decisions.

## Contents

| Folder | Purpose |
| --- | --- |
| `verification/` | RTL and full-SoC verification flow summaries and result logs |
| `board_bringup/` | Board bring-up decisions, runtime evidence summaries, UART/ILA evidence, and ILA helper scripts |
| `source_baselines/` | Source repository baseline records and paired SoC commit history |

## Current Engineering Chain

```text
RTL verification
  -> full-SoC SDK simulation
  -> board clock/JTAG/ILA bring-up
  -> hello_e203 board validation
  -> CNN/NICE board validation
  -> NICE rs2 index capture fix and board regression
```

## Key Evidence

| Claim | Evidence |
| --- | --- |
| RTL simulation baseline closed | `verification/rtl_sim_results_2026-04-23.txt` |
| Full-SoC simulation baseline closed | `verification/fullsoc_sim_results_2026-04-23.txt` |
| Board runtime evidence collected | `board_bringup/2026-04-28_board_connection_check/BOARD_RUNTIME_EVIDENCE_2026_04_28.md` |
| hello_e203 board path validated | `board_bringup/2026-04-28_board_connection_check/hello_e203_board_artifacts/` |
| NICE rs2 issue fixed and board-verified | `board_bringup/2026-05-09_nice_rs2_fix_verification/BOARD_VERIFICATION.md` |
| Active source baselines recorded | `source_baselines/ENGINEERING_BASELINES.md` |

## Exclusions

The following remain outside this repository by design:

- thesis DOCX/PDF/LaTeX submission packages
- final defense PPT, scripts, and QA packs
- school requirement documents
- MNIST raw dataset
- Vivado bitstreams, heavy build logs, and generated implementation products

## Maintenance Rule

If engineering evidence is updated, copy only lightweight source-like artifacts here: Markdown, text logs, CSV summaries, and reusable scripts. Keep generated binaries and graduation submission artifacts out of this directory.
