# Quick Start

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## Purpose

Use this file to recover context in under a minute.

## Current Baseline

- Branch: `bringup_v1`
- Active phase: `Phase 5`
- Delivery baseline: minimal CNN v1 + board-prep automation
- Historical software-driven SoC closure: `RSTAT=320`
- Current minimal CNN v1 full-SoC result: `expected_rstat = 19`

## Fast Verification

```bash
bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_preboard_verification.sh
bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh
```

## Read In This Order

1. [CURRENT_STATE.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/CURRENT_STATE.md)
2. [PHASE_HISTORY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE_HISTORY.md)
3. [PHASE5_BOARD_PREP.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE5_BOARD_PREP.md)

## Immediate Next Step

The remaining work is board-facing: confirm the real board target, confirm
`vivado`, confirm FTDI/JTAG visibility, lock `SERIAL_DEV`, then attempt the
first bitstream-backed board run.
