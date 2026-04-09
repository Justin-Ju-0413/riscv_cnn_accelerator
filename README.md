# Lightweight CNN Accelerator for RISC-V (Hummingbird E203)

## Project Overview

This project implements a lightweight CNN accelerator integrated with the
Hummingbird E203 RISC-V core through the NICE interface.

### Key Features

- Host core: Hummingbird E203 (`RV32IMAC`)
- Interface: NICE valid/ready request-response flow
- Data precision: INT8 weights and activations, INT32 accumulation
- Architecture: 4x4 PE array with output-stationary dataflow
- Current delivery baseline: A7-100T Route A functional bring-up

## Project Structure

```text
riscv_cnn_accelerator/
├── algo/                    # Algorithm reference models
├── hw/                      # RTL, testbenches, and simulation assets
├── sw/                      # Firmware and software-side support
├── scripts/                 # Automation and regression entry scripts
├── patches/                 # Third-party patch exports
├── docs/                    # Project documentation
│   ├── QUICKSTART.md
│   ├── CURRENT_STATE.md
│   ├── SUMMARY.md
│   ├── PHASE_HISTORY.md
│   ├── PROJECT_RULES.md
│   ├── PROGRESS.md
│   ├── archive/
│   └── knowledge/
├── Makefile
└── Project_Manager.sh
```

## Quick Start

```bash
./Project_Manager.sh gen_model
./Project_Manager.sh run_hw
./Project_Manager.sh precheck
bash scripts/run_sdk_fullsoc_regression.sh
bash scripts/run_preboard_verification.sh
```

## Documentation Guide

| Need | Document |
|------|----------|
| Documentation entry | `docs/PROJECT_INDEX.md` |
| Current truth | `docs/CURRENT_STATE.md` |
| A7-100T board bring-up truth | `docs/DAVINCI_A7_100T_BRINGUP_V2_0.md` |
| Delivery summary | `docs/SUMMARY.md` |
| Phase-organized history | `docs/PHASE_HISTORY.md` |
| Standing collaboration rules | `docs/PROJECT_RULES.md` |
| Chronological progress | `docs/PROGRESS.md` |
| Integration boundary | `docs/E203_FORMAL_INTEGRATION.md` |
| Recovery flow | `docs/PHASE4_RECOVERY.md` |
| Board preparation | `docs/PHASE5_BOARD_PREP.md` |
| FPGA handoff | `docs/VIVADO_FPGA_HANDOFF.md` |

## Version And Baseline

- Branch: `bringup_v1`
- Unified document version: `V2.0`
- Historical software-driven SoC closure: `RSTAT=320`
- Current minimal CNN v1 baseline: `expected_rstat = 19`
- E203 baseline: `riscv-mcu/e203_hbirdv2`

## Current Status

- Phase 1 to Phase 4 are closed.
- Phase 5 A7-100T functional bring-up is the active stage.
- Remaining gaps are board-facing: UART log capture, LED/ILA evidence, and the
  later `PTD04 + BSCANE2` debug-chain research track.
