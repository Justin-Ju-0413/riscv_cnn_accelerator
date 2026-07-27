# Next Work Plan — 2026-07-27

## Objective

Reproduce the validated RISC-V/E203 NICE CNN baseline in a clean Ubuntu 24.04
WSL2 environment before starting new accelerator research.

## Gate 1: Environment

- Work as the non-root `gstar` user.
- Use clean clones under `/home/gstar/workspaces/riscv/`.
- Load `/home/gstar/Desktop/gcc/bin` through `~/.profile`.
- Use `gdb-multiarch` on Ubuntu 24.04; do not depend on the legacy
  `libtinfo.so.5` GDB binary.
- Run `bash scripts/check_dev_env.sh`.

Acceptance: the checker reports `RESULT=PASS`. Vivado may be reported as
optional/not found.

## Gate 2: Simulation Baseline

Run, in order:

```bash
./Project_Manager.sh run_hw
bash scripts/run_sdk_fullsoc_regression.sh
bash scripts/run_preboard_verification.sh
```

Acceptance:

- RTL regression completes without a functional mismatch.
- FullSoC regression reaches the recorded expected result.
- The pre-board sweep passes all non-board gates.

If a command fails, preserve its log and record the exact failing layer instead
of changing RTL immediately.

## Gate 3: Benchmark Record

After successful reproduction:

```bash
./Project_Manager.sh new_benchmark_record wsl2-baseline-20260727
```

Record:

- accelerator and SoC commits;
- Ubuntu and tool versions;
- commands executed;
- RTL and FullSoC results;
- whether Vivado and physical hardware were run;
- exact claim boundaries.

Do not copy historical board numbers into a new measurement field. Historical
evidence may be cited separately.

## Existing Claim Boundaries

- `5.282x` is the recorded 3x3 convolution-kernel cycle result only.
- `10/10` is the recorded FPGA sample demonstration only.
- The project has not demonstrated complete LeNet-5 end-to-end acceleration or
  full MNIST board accuracy.

## Research Sequence After Reproduction

1. Close the clean-environment benchmark record.
2. Define a small E203/NICE Attention/MatMul reference workload.
3. Validate software data layout and a CPU baseline before changing hardware.
4. Use that prototype to inform the longer Vision Mamba/parallel SSM scan
   research direction.

The existing CNN RTL/NICE interface remains unchanged during the environment
and benchmark gates.
