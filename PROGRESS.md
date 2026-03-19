# Development Progress Log - Justin JU

| Week | Phase | Tasks Completed | Status |
| :--- | :--- | :--- | :--- |
| **Week 1** | Algorithm Prep | Python Golden Model, INT8 Quantization logic, C Emulation. | ✅ Pass |
| **Week 2** | RTL Design | 4x4 PE Array, Output Stationary architecture, MAC logic. | ✅ Pass |
| **Week 3** | Integration | NICE Interface FSM, Custom Opcode Mapping (0x0b). | ✅ Pass |
| **Week 4** | Verification | "Mock CPU" Testbench, NICE Handshake Timing, HW Result: 80. | ✅ Pass |

## Current Working Branch

- `bringup_v1`

## Locked Scope For This Bring-Up

- Based on E203 NICE extension
- Implement a 16-lane INT8 dot-product accelerator
- Software must execute `CLEAR/WLOAD/DLOAD/COMP/RSTAT`
- Simulation must pass
- This version is for later SoC integration and board bring-up

## Timeline

| Date | Item | Result |
| :--- | :--- | :--- |
| 2026-03-18 | Cloned private repository and configured long-term GitHub SSH access on this machine. | ✅ Done |
| 2026-03-19 | Created `bringup_v1` branch to isolate bring-up work from `main`. | ✅ Done |
| 2026-03-19 | Added `BOARD_BRINGUP_PLAN.md` to lock the scope for this version. | ✅ Done |
| 2026-03-19 | Installed local simulation tools: `git`, `iverilog`, `gtkwave`. | ✅ Done |
| 2026-03-19 | Verified Python model generation via `./Project_Manager.sh gen_model`. | ✅ Done |
| 2026-03-19 | Verified RTL simulation via `./Project_Manager.sh run_hw`. | ✅ Done |
| 2026-03-19 | Cloned public `third_party/nuclei-sdk` source and restored missing repo helper templates/scripts. | ✅ Done |
| 2026-03-19 | Fixed `precheck` path gaps so `./Project_Manager.sh precheck` passes. | ✅ Done |
| 2026-03-19 | Updated `cnn_nice_core.v` with `busy`, `result_valid`, load masks, gated `COMP`, gated `RSTAT`, and invalid `rs2` index checking. | ✅ Done |
| 2026-03-19 | Expanded `tb_cpu_mock.v` with auto-checked cases: normal path, negative values, boundary values, invalid index, partial load before `COMP`, and `RSTAT` before `COMP`. | ✅ Done |
| 2026-03-19 | Added `sw_reference_dot()` software reference path in firmware for future HW/SW comparison. | ✅ Done |

## Current Status

- `./Project_Manager.sh gen_model` passes
- `./Project_Manager.sh run_hw` passes
- `./Project_Manager.sh precheck` passes
- `cnn_nice_core.v` behavior is now constrained for bring-up
- Testbench now auto-checks pass/fail instead of relying only on waveform inspection
- Firmware now has a software reference dot-product function for future board debug

## Next Recommended Steps

- Install the Nuclei RISC-V toolchain so the SDK application can actually build
- Use `sw_reference_dot()` as the golden baseline for every new hardware test vector
- Keep appending new entries to this file with `Date / Item / Result`
