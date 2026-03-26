# Lightweight CNN Accelerator for RISC-V (Hummingbird E203)

Lightweight CNN accelerator integrated into the Hummingbird E203 SoC through
the NICE interface.

## Core Facts

- Host core: Hummingbird E203 (`RV32IMAC`)
- Interface: NICE valid/ready request-response flow
- Data precision: INT8 weights and activations, INT32 accumulation
- Architecture: 4x4 PE array with output-stationary dataflow
- Current delivery baseline: minimal CNN v1 + board-prep automation

## Project Structure

```text
riscv_cnn_accelerator/
├── algo/                    # Algorithm reference models
├── hw/                      # RTL, testbenches, and simulation assets
├── sw/                      # Firmware and software-side support
├── scripts/                 # Automation and regression entry scripts
├── patches/                 # Third-party patch exports
├── docs/                    # Project docs
│   ├── QUICKSTART.md
│   ├── CURRENT_STATE.md
│   ├── SUMMARY.md
│   ├── PHASE_HISTORY.md
│   ├── PROGRESS.md
│   ├── PROJECT_INDEX.md
│   ├── PROJECT_RULES.md
│   ├── archive/
│   └── knowledge/
├── Makefile
└── Project_Manager.sh
```

## Common Entry Commands

```bash
./Project_Manager.sh gen_model
./Project_Manager.sh run_hw
./Project_Manager.sh precheck
bash scripts/run_sdk_fullsoc_regression.sh
bash scripts/run_preboard_verification.sh
```

## Read Next

- Fast resume: `docs/QUICKSTART.md`
- Current truth: `docs/CURRENT_STATE.md`
- Full history: `docs/PHASE_HISTORY.md`
- Doc navigation: `docs/PROJECT_INDEX.md`
