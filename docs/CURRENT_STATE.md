# Current State

> **Version**: V2.0 | **Updated**: 2026-07-27 | **Owner**: Justin JU

## Purpose

This is the engineering session-recovery file. It records the validated FYP
baseline, the current development environment, and the next gate before new
research work begins.

## Current Snapshot

| Item | Value |
|------|-------|
| Engineering branch | `codex/a7-bringup-v2-main` |
| Paired SoC branch | `codex/a7-bringup-v2-soc` |
| Lifecycle | FYP engineering and defense closed |
| Validated platform | Hummingbird E203 + NICE + Davinci Pro A7-100T |
| Immediate task | Clean-environment baseline reproduction |
| Later research | E203/NICE Attention/MatMul prototype, then Vision Mamba |

The default `main` branches remain historical/default lines. They are not being
merged with the active engineering branches in this maintenance cycle.

## Repository Locations

| Role | Current clean WSL2 path |
|------|-------------------------|
| Accelerator | `/home/gstar/workspaces/riscv/riscv_cnn_accelerator` |
| SoC | `/home/gstar/workspaces/riscv/e203_hbirdv2` |

The older `/home/gstar/Desktop` repositories are retained as recovery copies.
Do not reset or delete them until the clean clones and GitHub PRs have been
verified.

## Closed Technical Baseline

- E203/NICE request-response integration is locked.
- The software-visible command path is `CFG/CLEAR/WLOAD/DLOAD/COMP/RSTAT`.
- The accelerator uses INT8 weights/activations, INT32 accumulation, and a 4x4
  output-stationary PE array.
- RTL and software-driven FullSoC regressions have recorded passing evidence.
- A7-100T programming, UART output, and ILA capture were completed.
- The NICE `rs2` index-capture bug was fixed in the E203 decoder and
  board-regressed on 2026-05-09.

## Recorded Evidence

| Evidence | Recorded result |
|----------|-----------------|
| RTL regression | `16/16` passed |
| FullSoC regression | `7/7` passed |
| Historical dot-product closure | `RSTAT=320` |
| Minimal CNN v1 FullSoC result | `expected_rstat = 19` |
| 3x3 convolution-kernel cycle test | `1516 / 287 = 5.282x` |
| FPGA sample demonstration | `10/10` samples |
| FPGA timing after NICE fix | WNS `13.512 ns`, WHS `0.056 ns` |
| Board result | UART reported `CNN v1 DEMO PASSED`; ILA captured |

The `5.282x` result is limited to the recorded 3x3 convolution-kernel cycle
test. The `10/10` result is limited to the recorded FPGA sample demonstration.
Neither value proves full LeNet-5 acceleration or full MNIST accuracy.

## Current Host Environment

| Tool | Current state |
|------|---------------|
| Ubuntu | 24.04 on WSL2 |
| RISC-V GCC | 14.2.1 under `/home/gstar/Desktop/gcc/bin` |
| RISC-V debugger | `gdb-multiarch` 15.1 |
| OpenOCD | 0.12.0 |
| Icarus Verilog | 12.0 |
| GNU Make | 4.3 |
| Python | 3.12 |
| Vivado | Not discovered on the current Windows host |
| Board serial/JTAG | Not connected during the 2026-07-27 audit |

Run `bash scripts/check_dev_env.sh` before starting a regression. The legacy
toolchain GDB is not used because it requires `libtinfo.so.5`, which Ubuntu
24.04 no longer provides.

## Immediate Gate

1. Run the read-only environment check.
2. Re-run the RTL regression.
3. Re-run the software-driven FullSoC regression.
4. Run the pre-board verification sweep.
5. Add a benchmark record with exact commits, tool versions, results, and claim
   boundaries.

Vivado programming and a physical board rerun are optional for this gate. If
they are not run, record them as `not run`, not as failures.

## Remaining Research Gaps

- No complete LeNet-5 end-to-end accelerator timing result.
- No full board-side MNIST accuracy run.
- No line buffer, local SRAM buffer, DMA-like path, or NICE memory channel.
- No automatic compiler mapping or RVV comparison baseline.
- No Attention/MatMul prototype or Vision Mamba/SSM scan accelerator yet.

## Reading Order

1. `docs/roadmap/NEXT_WORK_PLAN_2026_07_27.md`
2. `docs/design_history/source_baselines/ENGINEERING_BASELINES.md`
3. `docs/design_history/board_bringup/2026-05-09_nice_rs2_fix_verification/BOARD_VERIFICATION.md`
4. `docs/benchmarks/README.md`
5. `docs/roadmap/FUTURE_RND_PLAN.md`

Update this file whenever the active baseline, blocker, or next gate changes.
