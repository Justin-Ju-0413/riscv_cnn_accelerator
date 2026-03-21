# Lightweight CNN Accelerator for RISC-V (Hummingbird E203)

## Project Overview
This project focuses on the hardware/software co-design of a lightweight CNN accelerator integrated with the **Hummingbird E203 RISC-V core** via the **NICE (Nuclei Instruction Co-Unit Extension)** interface.

### Key Features
- **Host Core**: Hummingbird E203 (RISC-V 32IMAC).
- **Interface**: NICE Protocol (Valid/Ready Handshake).
- **Data Precision**: INT8 for weights/activations, INT32 for accumulation.
- **Architecture**: 4x4 Processing Element (PE) Array with Output Stationary (OS) dataflow.

## Quick Start
To initialize the environment and run the hardware simulation:
```bash
chmod +x Project_Manager.sh
./Project_Manager.sh run_hw
```

To regenerate the C-model reference vectors:
```bash
./Project_Manager.sh gen_model
```

To run the SDK-installation precheck:
```bash
./Project_Manager.sh precheck
```

To rebuild the SDK app and run the official full-SoC software-driven regression:
```bash
bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh
```

See [PRE_SDK_CHECKLIST.md](PRE_SDK_CHECKLIST.md) for the ordered preparation list before installing Nuclei SDK.
See [sw/sdk_project/README.md](sw/sdk_project/README.md) for the SDK project skeleton that is ready to be wired up after installation.
Use [INTEGRATION_DECISIONS.md](INTEGRATION_DECISIONS.md) to freeze integration choices before touching the real E203 codebase.
Use [POST_SDK_PLAYBOOK.md](POST_SDK_PLAYBOOK.md) after the SDK is installed.
See [SDK_INSTALL.md](SDK_INSTALL.md) for the current local SDK installation status.
See [docs/PHASE4_RECOVERY.md](docs/PHASE4_RECOVERY.md) for the current collaborator recovery and regression flow.
See [docs/PHASE5_BOARD_PREP.md](docs/PHASE5_BOARD_PREP.md) for the current board bring-up preparation baseline.

## Design Milestones
- [x] Week 1: INT8 Software Golden Model (Python/C).
- [x] Week 2: RTL Design of PE and 4x4 Array.
- [x] Week 3: NICE Controller FSM and Instruction Decoding.
- [x] Week 4: Interface-level Verification (Mock CPU).
