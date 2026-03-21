# Current State

## Purpose

Single compressed state file for session recovery and low-overhead context
loading.

## Goal

Integrate the CNN NICE accelerator into `e203_hbirdv2` completely and safely.

## Version

- Current version: `V1.7`

## Active Phase

- Phase: `Phase 4 complete`
- Objective: Phase 4 exit criteria are now closed with a validated one-command recovery and regression flow

## Repositories

- Main repo:
  - path: `/home/gstar/Desktop/riscv_cnn_accelerator`
  - branch: `bringup_v1`
  - head: `c1e8e11`
- SoC repo:
  - path: `/home/gstar/Desktop/e203_hbirdv2`
  - branch: `cnn_bringup_v1`
  - head: `690eec8`
  - remotes:
    - `origin` -> `git@github.com:Justin-Ju-0413/e203_hbirdv2.git`
    - `upstream` -> `https://github.com/riscv-mcu/e203_hbirdv2.git`

## Verified

- Main project checks pass:
  - `./Project_Manager.sh gen_model`
  - `./Project_Manager.sh run_hw`
  - `./Project_Manager.sh precheck`
- Official full-SoC simulator baseline is now aligned with repo guidance:
  - local `iverilog` upgraded to `12.0`
  - direct official `vvp.exec` runs now advance into the patch window
- Full-SoC environment fixes are in place:
  - stable `vsim` path handling
  - no empty `+PATCHCASE=`
  - ASCII-path-only rule for official `iverilog/vvp`
- Lightweight official-chain smoke test passes:
  - official `e203_exu_nice -> e203_subsys_nice_core -> cnn_nice_core` path
  - `req_ready` low while busy
  - `RSTAT=320`
- Phase 2 mock-harness safety checks now pass under the corrected official NICE
  encoding:
  - `normal_path`
  - `negative_values`
  - `boundary_values`
  - `invalid_index`
  - `comp_without_full_load`
  - `rstat_without_comp`
  - `busy_blocks_new_req`
  - `rstat_repeat_read`
  - `illegal_funct7`
  - `illegal_opcode`
  - `reset_clears_state`
- The official lightweight chain now also covers selected Phase 2 cases:
  - repeated `RSTAT`
  - invalid load index
  - `COMP` before full load
  - illegal `funct7`
  - illegal opcode
  - reset clears state
- Real integration bug fixed:
  - `cnn_nice_core` now latches `load_data_q` and `load_vec_sel_q`
  - fix mirrored to both repos
- Full software-driven SoC execution is validated:
  - SDK ELF exported to `.verilog`, then split into `.itcm.verilog` and `.dtcm.verilog`
  - software-issued `CLEAR/WLOAD/DLOAD/COMP/RSTAT` observed in official E203 RTL simulation
  - final `RSTAT=320` comes from the software image, not the synthetic overlay

## Phase 2 Result

- Phase 2 is complete on the current request/response-only NICE scope.
- The integration now has:
  - Phase 1 full-SoC closure
  - Phase 2 mock-harness safety coverage
  - Phase 2 official lightweight-chain safety coverage
- No new RTL blocker was found while closing Phase 2.

## Phase 3 Result

- The official Nuclei GNU toolchain requirement is confirmed in practice:
  - generic distro `riscv64-unknown-elf-gcc` fails on
    `-mtune=nuclei-300-series`
  - official Nuclei GNU toolchain `2024.06` under `/home/gstar/Desktop/gcc`
    compiles the SDK application successfully
- The SDK-native app now performs software/hardware self-check logic:
  - enables `MSTATUS.XS`
  - computes `sw_reference_dot()`
  - emits NICE `CLEAR/WLOAD/DLOAD/COMP/RSTAT`
  - compares accelerator result against the software reference
- Two software build entry points produce `cnn_accel_demo.elf`:
  - `third_party/nuclei-sdk/application/baremetal/cnn_accel_demo`
  - `sw/sdk_project` via the corrected `Makefile.template`
- The built ELF has been validated at instruction level:
  - `CLEAR/WLOAD/DLOAD/COMP/RSTAT` appear as custom `0x0b` instructions in
    the disassembly
- The official toolchain's generic runner is not enough to close Phase 3 by itself:
  - `riscv64-unknown-elf-run` can load the ELF, but without explicit memory it
    faults on unmapped `0x80000100`
  - after adding minimal ILM/DLM memory ranges, it still stops on illegal
    instruction
  - current evidence says it does not model the full `n300 + rv32imac + NICE`
    execution context needed by this project
- Two integration blockers were resolved during Phase 3 closure:
  - evalsoc startup assumptions were trimmed to an E203-safe subset for the SDK app bring-up path
  - successful non-`RSTAT` NICE operations now emit completion responses so E203 long-pipe bookkeeping can retire them

## Phase 4 Result

- The nested `third_party/nuclei-sdk` delta is now exported as a portable patch:
  - [nuclei-sdk-phase3-e203-safe.patch](/home/gstar/Desktop/riscv_cnn_accelerator/patches/nuclei-sdk-phase3-e203-safe.patch)
- A reusable patch helper is now available:
  - [apply_nuclei_sdk_phase3_patch.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/apply_nuclei_sdk_phase3_patch.sh)
- A one-command SDK-to-full-SoC regression entry is now available:
  - [run_sdk_fullsoc_regression.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh)
- Recovery and handoff instructions are now centralized in:
  - [PHASE4_RECOVERY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE4_RECOVERY.md)
- The one-command recovery path is now validated locally:
  - rebuild SDK app
  - regenerate and split ITCM/DTCM images
  - run official full-SoC E203 simulation
  - observe `RSTAT=320` and `rstat_320_seen=1`

## Execution Entry Points

- Fast gate:
  - [run_nice_light.sh](/home/gstar/Desktop/e203_hbirdv2/tb/run_nice_light.sh)
  - `bash /home/gstar/Desktop/e203_hbirdv2/tb/run_nice_light.sh`
- Full-SoC wrapper:
  - [run_nice_patch.sh](/home/gstar/Desktop/e203_hbirdv2/vsim/run_nice_patch.sh)
  - `bash /home/gstar/Desktop/e203_hbirdv2/vsim/run_nice_patch.sh`
  - default testcase is now the smaller `rv32ui-p-simple`
- Phase 4 one-command regression:
  - [run_sdk_fullsoc_regression.sh](/home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh)
  - `bash /home/gstar/Desktop/riscv_cnn_accelerator/scripts/run_sdk_fullsoc_regression.sh`

## Key Files

- Main RTL fix:
  - [cnn_nice_core.v](/home/gstar/Desktop/riscv_cnn_accelerator/hw/rtl/acc/cnn_nice_core.v)
- SoC RTL fix:
  - [cnn_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/cnn_nice_core.v)
- SoC integration wrapper:
  - [e203_subsys_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/e203_subsys_nice_core.v)
- Full-SoC observability:
  - [tb_top.v](/home/gstar/Desktop/e203_hbirdv2/tb/tb_top.v)
- SDK portability patch:
  - [nuclei-sdk-phase3-e203-safe.patch](/home/gstar/Desktop/riscv_cnn_accelerator/patches/nuclei-sdk-phase3-e203-safe.patch)
- Recovery doc:
  - [PHASE4_RECOVERY.md](/home/gstar/Desktop/riscv_cnn_accelerator/docs/PHASE4_RECOVERY.md)

## Next Focus

- Phase 4 is closed on the current software-driven simulation scope.
- Keep `run_nice_light.sh` as the fast regression gate.
- Keep `run_nice_patch.sh` as the underlying official full-SoC wrapper.
- Next focus: Phase 5 board bring-up preparation.

## Compression Rules

- Read this file first in future sessions.
- Read `INTEGRATION_ROADMAP.md` only for long-range planning.
- Read `PROGRESS.md` only for dated history.
- Avoid loading multiple large docs unless the task explicitly needs them.
