# Technical Architecture & ISA Specification

## 1. Custom Instruction Set (ISA Extension)
The accelerator utilizes the RISC-V `custom0` (opcode: `0x0b`) space.

| Instruction | Funct3 | Description | Operands |
| :--- | :--- | :--- | :--- |
| **WLOAD** | `000` | Load 32-bit weight data into PE buffer | `rs1`: data, `rs2`: index |
| **COMP** | `010` | Trigger 4x4 PE parallel computation | N/A |
| **RSTAT** | `011` | Retrieve 32-bit accumulation result | `rd`: destination |

## 2. Hardware Microarchitecture
- **PE Unit**: Implements `Acc = Acc + (W * D)` with signed INT8 arithmetic and 32-bit accumulator.
- **4x4 Array**: 16 PEs operating in parallel.
- **Serial-to-Parallel Loading**: Since NICE provides 32-bit bus but the array requires 128-bit weights, we implement a 4-cycle sequential loading strategy.
- **Output Stationary (OS)**: Partial sums are kept within the PEs to minimize data movement energy.

## 3. Communication Protocol (NICE)
- **Handshake**: `nice_req_valid` / `nice_req_ready` for commands.
- **Response**: `nice_rsp_valid` / `nice_rsp_ready` for data retrieval.
