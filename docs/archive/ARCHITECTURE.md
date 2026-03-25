# Technical Architecture & ISA Specification

## 1. Custom Instruction Set (ISA Extension)
The accelerator utilizes the RISC-V `custom0` (opcode: `0x0b`) space and
follows the E203 NICE encoding convention:
- bits `[14:12]` are `xd/xs1/xs2`
- `funct7` selects the custom accelerator operation

| Instruction | `xd/xs1/xs2` | `funct7` | Description | Operands |
| :--- | :--- | :--- | :--- |
| **WLOAD** | `011` | `0` | Load 32-bit weight data into PE buffer | `rs1`: data, `rs2`: index |
| **DLOAD** | `011` | `1` | Load 32-bit activation data into PE buffer | `rs1`: data, `rs2`: index |
| **COMP** | `000` | `2` | Trigger 4x4 PE parallel computation | N/A |
| **RSTAT** | `100` | `3` | Retrieve 32-bit accumulation result | `rd`: destination |
| **CLEAR** | `000` | `4` | Clear PE accumulators before a new output tile | N/A |

## 2. Hardware Microarchitecture
- **PE Unit**: Implements `Acc = Acc + (W * D)` with signed INT8 arithmetic and 32-bit accumulator.
- **4x4 Array**: 16 PEs operating in parallel.
- **Serial-to-Parallel Loading**: Since NICE provides a 32-bit bus but the array requires 128-bit weights and 128-bit activations, both tensors are loaded over 4 sequential transactions.
- **Output Stationary (OS)**: Partial sums are kept within the PEs to minimize data movement energy.
- **Accumulator Control**: Accumulator clearing is decoupled from vector loading to avoid corrupting already loaded weights or activations.

## 3. Communication Protocol (NICE)
- **Handshake**: `nice_req_valid` / `nice_req_ready` for commands.
- **Response**: `nice_rsp_valid` remains asserted until `nice_rsp_ready` acknowledges the `RSTAT` result.
