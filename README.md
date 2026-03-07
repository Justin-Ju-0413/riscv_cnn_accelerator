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
\`\`\`bash
chmod +x Project_Manager.sh
./Project_Manager.sh setup
./Project_Manager.sh run_hw
\`\`\`

## Design Milestones
- [x] Week 1: INT8 Software Golden Model (Python/C).
- [x] Week 2: RTL Design of PE and 4x4 Array.
- [x] Week 3: NICE Controller FSM and Instruction Decoding.
- [x] Week 4: Interface-level Verification (Mock CPU).
