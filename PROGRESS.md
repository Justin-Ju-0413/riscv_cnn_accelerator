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
| 2026-03-20 | Cleaned repository readability issues: README links made relative, invalid tool archives removed, and `Project_Manager.sh status` output changed to relative paths. | ✅ Done |
| 2026-03-20 | Pushed current bring-up branch to GitHub as `origin/bringup_v1`. | ✅ Done |
| 2026-03-20 | Froze the external SoC baseline to official `riscv-mcu/e203_hbirdv2` and cloned a local inspection copy at `/home/gstar/Desktop/e203_hbirdv2`. | ✅ Done |
| 2026-03-20 | Located the real NICE integration layers in official code: `rtl/e203/core/e203_cpu.v` and `rtl/e203/subsys/e203_subsys_nice_core.v`. | ✅ Done |
| 2026-03-20 | Confirmed the first SoC bring-up strategy stays on request/response only, with `nice_mem_holdup=0`, `nice_icb_cmd_valid=0`, and `nice_icb_rsp_ready=1` as the initial stub policy. | ✅ Done |
| 2026-03-20 | Confirmed illegal NICE handling should stay conservative for bring-up: unsupported opcode/funct3 continues to return `nice_rsp_err=1`. | ✅ Done |
| 2026-03-20 | Built a local official-E203 proof workspace under `/home/gstar/Desktop/e203_hbirdv2`, swapped in the minimal CNN NICE co-unit, added a tiny NICE instruction overlay program, and added early-stop/monitor hooks in `tb_top.v`. | ✅ Local only |
| 2026-03-20 | Found two environment blockers for official full-SoC iverilog verification: `$readmemh` fails on non-ASCII testcase paths, and the official `vsim/install` tree must be cleaned before every rebuild to avoid duplicate-module compile errors. | ✅ Identified |
| 2026-03-20 | Upgraded local `iverilog` to official-required `12.0` and confirmed the official full-SoC `vvp.exec` path now advances into the injected NICE patch window. | ✅ Done |
| 2026-03-20 | Added a lightweight official NICE smoke test and wrapper scripts; confirmed official request path, busy-time `req_ready` low, and `RSTAT=320` all pass in the reduced official chain. | ✅ Done |
| 2026-03-20 | Traced the full-SoC `WLOAD rs2` issue to an ISA mismatch: official E203 NICE uses bits `[14:12]` as `xd/xs1/xs2`, so the CNN custom-op selector was moved from `funct3` into `funct7`. | ✅ Done |
| 2026-03-20 | Re-encoded the CNN NICE instructions in RTL, software macros, light official TB, and full-SoC patch overlay; official full-SoC `vvp.exec` now reproduces `NICE_REQ`, `req_ready` low, and `RSTAT=320`. | ✅ Done |
| 2026-03-20 | Promoted the corrected NICE encoding baseline to version `V1.5` and added unified `VERSION.md` / `CHANGELOG.md` project versioning. | ✅ Done |
| 2026-03-20 | Updated `tb_cpu_mock.v` to the official NICE `xspec + funct7` encoding and passed Phase 2 safety cases: invalid index, partial-load `COMP`, `RSTAT` before and after compute, busy-time request blocking, illegal `funct7`, illegal opcode, and reset-clears-state. | ✅ Done |
| 2026-03-20 | Extended the official lightweight E203 NICE testbench with selected Phase 2 cases and confirmed repeated `RSTAT`, invalid index, partial-load `COMP`, illegal `funct7`, illegal opcode, and reset-clears-state all pass. | ✅ Done |
| 2026-03-20 | Closed Phase 2 and promoted the validated interface-safety baseline to version `V1.6`. | ✅ Done |
| 2026-03-20 | Installed distro `riscv64-unknown-elf-gcc` and confirmed it is insufficient for Nuclei SDK because it fails on `-mtune=nuclei-300-series`; official SDK FAQ matches this behavior. | ✅ Identified |
| 2026-03-20 | Downloaded official Nuclei GNU toolchain `2024.06`, compiled `third_party/nuclei-sdk/application/baremetal/cnn_accel_demo`, and confirmed the resulting ELF contains the CNN NICE custom instructions. | ✅ Done |
| 2026-03-20 | Corrected `sw/sdk_project` to match the current Nuclei SDK layout (`Build/Makefile.base`) and fixed its `ARCH_EXT` misuse; the project-local SDK entry now also builds `cnn_accel_demo.elf`. | ✅ Done |
| 2026-03-21 | Tested the official toolchain's `riscv64-unknown-elf-run`; it can load the SDK ELF but is not a valid closure environment for the current `n300 + rv32imac + NICE` target, stopping first on unmapped ILM/DLM addresses and then on illegal instruction after minimal memory is added. | ✅ Identified |
| 2026-03-21 | Trimmed the SDK app startup path to an E203-safe subset, regenerated ITCM/DTCM images from the rebuilt ELF, and confirmed software-driven `CLEAR/WLOAD/DLOAD/COMP/RSTAT` executes successfully in official full-SoC E203 simulation with `RSTAT=320`. | ✅ Phase 3 closed |

## Current Status

- Main project checks pass:
  - `./Project_Manager.sh gen_model`
  - `./Project_Manager.sh run_hw`
  - `./Project_Manager.sh precheck`
- Current detailed Phase 1 status:
  - see [CURRENT_STATE.md](/home/gstar/Desktop/riscv_cnn_accelerator/CURRENT_STATE.md)
- Phase 2 status:
  - completed at `V1.6`
  - mock harness safety suite passes
  - official lightweight safety suite passes
- Phase 3 status:
  - closed on the current request/response-only NICE scope
  - official toolchain-based software build path is working
  - software-driven full-SoC execution is validated in official E203 RTL simulation

## Next Recommended Steps

- Keep appending new entries to this file with `Date / Item / Result`
- Keep detailed execution state in
  [CURRENT_STATE.md](/home/gstar/Desktop/riscv_cnn_accelerator/CURRENT_STATE.md)
- Keep long-range planning in
  [INTEGRATION_ROADMAP.md](/home/gstar/Desktop/riscv_cnn_accelerator/INTEGRATION_ROADMAP.md)
