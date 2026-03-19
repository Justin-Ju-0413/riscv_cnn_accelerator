# Current State

## Purpose

Single compressed state file for session recovery and low-overhead context
loading.

## Goal

Integrate the CNN NICE accelerator into `e203_hbirdv2` completely and safely.

## Active Phase

- Phase: `Phase 1`
- Objective: close official SoC bring-up with reproducible NICE observations
- Required full-SoC observations:
  - `NICE_REQ`
  - `req_ready` low while busy
  - `RSTAT=320`

## Repositories

- Main repo:
  - path: `/home/gstar/Desktop/riscv_cnn_accelerator`
  - branch: `bringup_v1`
  - head: `2f1e9fe`
- SoC repo:
  - path: `/home/gstar/Desktop/e203_hbirdv2`
  - branch: `cnn_bringup_v1`
  - head: `2d9b346`
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
- Real integration bug fixed:
  - `cnn_nice_core` now latches `load_data_q` and `load_vec_sel_q`
  - fix mirrored to both repos

## Current Blocker

- The blocker is no longer simulator runtime.
- Official full-SoC `iverilog 12.0` now reaches the injected NICE program and
  prints real `NICE_REQ`/`NICE_RSP` activity.
- The active blocker is now narrowed to source-operand visibility on the
  official E203/NICE path:
  - `WLOAD` requests still see `nice_req_rs2=0` for all four loads
  - the register file probe shows `x11` itself is already `0/1/2/3`
  - `DLOAD` requests in the same run do see `nice_req_rs2=0/1/2/3`
  - `COMP` and `RSTAT` therefore legally return `err=1` because the weight load
    mask never reaches all four lanes
- This means the remaining issue is at the E203/NICE integration boundary, not
  in the CNN datapath or the standalone NICE smoke test

## Execution Entry Points

- Fast gate:
  - [run_nice_light.sh](/home/gstar/Desktop/e203_hbirdv2/tb/run_nice_light.sh)
  - `bash /home/gstar/Desktop/e203_hbirdv2/tb/run_nice_light.sh`
- Full-SoC wrapper:
  - [run_nice_patch.sh](/home/gstar/Desktop/e203_hbirdv2/vsim/run_nice_patch.sh)
  - `bash /home/gstar/Desktop/e203_hbirdv2/vsim/run_nice_patch.sh`
  - default testcase is now the smaller `rv32ui-p-simple`

## Key Files

- Main RTL fix:
  - [cnn_nice_core.v](/home/gstar/Desktop/riscv_cnn_accelerator/hw/rtl/acc/cnn_nice_core.v)
- SoC RTL fix:
  - [cnn_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/cnn_nice_core.v)
- SoC integration wrapper:
  - [e203_subsys_nice_core.v](/home/gstar/Desktop/e203_hbirdv2/rtl/e203/subsys/e203_subsys_nice_core.v)
- Full-SoC observability:
  - [tb_top.v](/home/gstar/Desktop/e203_hbirdv2/tb/tb_top.v)
- Overlay program:
  - [nice_dot320_patch.verilog](/home/gstar/Desktop/e203_hbirdv2/tb/nice_dot320_patch.verilog)

## Next Focus

- Keep `run_nice_light.sh` as the fast regression gate.
- Keep `run_nice_patch.sh` as the official full-SoC diagnostic entry.
- Use the current `tb_top.v` probe to trace `nice_req_rs2` against the regfile
  source registers.
- Check official NICE operand timing semantics before changing accelerator ISA
  meaning.
- Do not re-debug the accelerator datapath unless the smoke test regresses.

## Compression Rules

- Read this file first in future sessions.
- Read `INTEGRATION_ROADMAP.md` only for long-range planning.
- Read `PROGRESS.md` only for dated history.
- Avoid loading multiple large docs unless the task explicitly needs them.
