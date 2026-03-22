# Lightweight CNN Accelerator for RISC-V (Hummingbird E203)

## Project Overview
This project focuses on the hardware/software co-design of a lightweight CNN accelerator integrated with the **Hummingbird E203 RISC-V core** via the **NICE (Nuclei Instruction Co-Unit Extension)** interface.

### Key Features
- **Host Core**: Hummingbird E203 (RISC-V 32IMAC)
- **Interface**: NICE Protocol (Valid/Ready Handshake)
- **Data Precision**: INT8 for weights/activations, INT32 for accumulation
- **Architecture**: 4×4 Processing Element (PE) Array with Output Stationary (OS) dataflow

---

## 📁 Project Structure

```
riscv_cnn_accelerator/
├── algo/                    # Algorithm reference models
│   ├── python/              # Python golden model
│   └── c_model/             # C reference model
├── hw/                      # Hardware
│   ├── rtl/                 # RTL source code
│   │   ├── acc/             # CNN accelerator (PE, PE Array, NICE controller)
│   │   └── soc_wrapper/     # SoC wrapper (E203 + CNN integration)
│   ├── tb/                  # Testbenches
│   └── sim/                 # Simulation work directory
├── sw/                      # Software
│   ├── firmware/            # Baremetal firmware (C)
│   ├── inc/                 # Firmware headers
│   ├── sdk_project/         # Nuclei SDK project skeleton
│   └── build/               # Build scripts
├── fpga/                    # FPGA / board bring-up
├── scripts/                 # Automation scripts
├── patches/                 # Third-party patches (e.g. Nuclei SDK)
├── docs/                    # All project documentation
│   ├── PROJECT_INDEX.md     # ← Start here: document index
│   ├── SUMMARY.md           # 交付总结
│   ├── PROGRESS.md          # 开发进度
│   ├── ARCHITECTURE.md      # 系统架构
│   ├── VERIFICATION.md      # 验证方案
│   ├── E203_FORMAL_INTEGRATION.md
│   ├── PHASE4_RECOVERY.md
│   ├── PHASE5_BOARD_PREP.md
│   ├── VIVADO_FPGA_HANDOFF.md
│   └── presentation.html    # 汇报用演示稿
├── Makefile                 # Top-level build commands
└── Project_Manager.sh       # Project management utility
```

---

## 🚀 Quick Start

```bash
# 1. Generate Python reference model
make gen_model

# 2. Run RTL simulation
make sim

# 3. Run pre-SDK environment checks
make precheck
```

Or use the management script:

```bash
./Project_Manager.sh gen_model   # Regenerate reference vectors
./Project_Manager.sh run_hw      # Run RTL simulation
./Project_Manager.sh precheck     # Pre-SDK environment check
```

---

## 📖 Documentation Guide

| What you need | Where to look |
|---------------|---------------|
| 文档总入口 | `docs/PROJECT_INDEX.md` |
| 项目交付总结 | `docs/SUMMARY.md` |
| 开发进度 | `docs/PROGRESS.md` |
| 系统架构 | `docs/ARCHITECTURE.md` |
| SoC 集成边界 | `docs/E203_FORMAL_INTEGRATION.md` |
| 验证方案 | `docs/VERIFICATION.md` |
| SDK 安装 | `docs/SDK_INSTALL.md` |
| Phase 4 恢复 | `docs/PHASE4_RECOVERY.md` |
| Phase 5 板级准备 | `docs/PHASE5_BOARD_PREP.md` |
| FPGA 交接 | `docs/VIVADO_FPGA_HANDOFF.md` |
| 汇报演示稿 | `docs/presentation.html` |

---

## 🗂️ Version & Release

- **Current Version**: `bringup_v1` branch, V1.8
- **Changelog**: see `CHANGELOG.md`
- **E203 Baseline**: `riscv-mcu/e203_hbirdv2` (official)

---

## Design Milestones

- [x] Week 1: INT8 Software Golden Model (Python/C)
- [x] Week 2: RTL Design of PE and 4×4 Array
- [x] Week 3: NICE Controller FSM and Instruction Decoding
- [x] Week 4: Interface-level Verification (Mock CPU)
- [x] SoC Bring-Up: Phase 1–5 closed (software stack validated)
