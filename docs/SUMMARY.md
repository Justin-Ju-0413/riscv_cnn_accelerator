# Work Delivery Summary

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## Purpose

Summarize what the current package delivers and what is still open.

## Delivery Snapshot

- Branch: `bringup_v1`
- Delivery baseline: minimal CNN v1 + board-prep automation
- Project trajectory: from NICE dot-product closure to a software-aligned CNN
  v1 baseline prepared for board bring-up

## Delivered Scope

### RTL And Interface

- 16-lane INT8 NICE compute path is stable.
- `CLEAR/WLOAD/DLOAD/COMP/RSTAT` is the locked software-visible command set.
- `CFG` support for hardware ReLU is part of the current baseline.
- Interface safety coverage includes reset, invalid command, invalid index,
  busy-time blocking, and repeated `RSTAT`.

### Software And SoC

- SDK app, firmware, and demo path are aligned to the current minimal CNN v1 flow.
- Python golden, software reference, and SoC-visible data flow are aligned.
- CPU-only and accelerator-visible comparison output are integrated.

### Board-Prep Package

- Full pre-board verification is scripted.
- Board environment checking is scripted.
- First-run FPGA command printing is scripted.
- Vivado/FPGA handoff boundaries are documented.

## Verified Gates

- `./Project_Manager.sh run_hw`
- `bash scripts/run_sdk_fullsoc_regression.sh`
- `bash scripts/run_preboard_verification.sh`
- `bash scripts/check_phase5_board_env.sh`

## Result Baselines

- Historical software-driven SoC closure: `RSTAT=320`
- Current minimal CNN v1 flow: `expected_rstat = 19`

## Remaining Gaps

- `vivado` is not yet confirmed on this machine.
- FTDI/JTAG hardware is not yet visible.
- `SERIAL_DEV` is not yet locked.
- The real board target is not yet finally confirmed.
- No bitstream-backed board run has been completed.

## Related Docs

- Current truth: [CURRENT_STATE.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/CURRENT_STATE.md)
- Full history: [PHASE_HISTORY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE_HISTORY.md)
- Board-facing next step: [PHASE5_BOARD_PREP.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE5_BOARD_PREP.md)
