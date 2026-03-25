# Quick Start

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## What This Project Is

This is a RISC-V CNN accelerator integrated into the Hummingbird E203 SoC
through the NICE interface.

Current delivery baseline:

- official E203 integration is closed
- software-driven full-SoC validation is closed
- minimal CNN v1 flow is aligned
- board-prep automation is ready

## Fast Verification

```bash
bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_preboard_verification.sh
bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh
```

## Current Key Facts

| Item | Value |
|------|-------|
| Branch | `bringup_v1` |
| Active phase | `Phase 5` |
| Historical SoC closure result | `RSTAT=320` |
| Current minimal CNN v1 result | `expected_rstat = 19` |
| Unified doc version | `V1.9` |

## Start Reading Here

| Need | Document |
|------|----------|
| Current truth | [CURRENT_STATE.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/CURRENT_STATE.md) |
| Whole project by phase | [PHASE_HISTORY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE_HISTORY.md) |
| Delivery overview | [SUMMARY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/SUMMARY.md) |
| Long-term requirements | [PROJECT_RULES.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PROJECT_RULES.md) |

## Current Next Step

The next real engineering gap is board-facing, not RTL-facing:

1. confirm the real board target
2. confirm `vivado`
3. confirm FTDI/JTAG visibility
4. lock `SERIAL_DEV`
5. attempt the first bitstream-backed board run
