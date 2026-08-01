# Project showcase and evidence boundary

This is the public, de-identified entry to the research line. Administrative forms, thesis submission files, signatures, grades, and personal records remain in private archives.

## Research lineage

| Layer | Accelerator branch | Paired SoC branch | Scope |
|---|---|---|---|
| Stable FYP | `codex/a7-bringup-v2-main` | `codex/a7-bringup-v2-soc` | Recorded CNN/NICE and A7-100T engineering evidence |
| Reproducible baseline | `codex/env-baseline-20260727` | `codex/env-baseline-20260727-soc` | Environment and regression reproducibility, no RTL/API change |
| MPhil PoC | `codex/mphil-tensor-scan-20260729` | `codex/mphil-tensor-scan-20260729-soc` | Experimental NICE v2 capability and ICB scratchpad path |

`main` remains the stable navigation and release entry. Experimental RTL is kept on the research branches above.

## Evidence

| Scope | Recorded result | Boundary |
|---|---:|---|
| Legacy local RTL harness | 19 named checks passed in the 2026-08-02 clean checkout | Module-level NICE protocol and arithmetic regression |
| NICE v2 directed harness | 16 checks passed in the 2026-08-02 clean checkout | Standalone CAP/MLOAD/MSTAT memory-path PoC |
| MPhil Python golden models | 7 unit tests passed in the 2026-08-02 clean checkout | Reference GEMM/convolution/depthwise/SSM functions only |
| Historical 3x3 kernel benchmark | 1516 CPU cycles vs 287 accelerator cycles, 5.282x | One kernel benchmark, not end-to-end LeNet-5 speedup |
| Historical FPGA sample demonstration | 10/10 selected samples | Demonstration set, not dataset-level MNIST accuracy |

The 2026-08-02 environment did not contain the RISC-V cross compiler and paired Full-SoC setup. A Full-SoC `CAP -> MLOAD -> MSTAT` SDK microbenchmark remains unrun; standalone RTL results do not replace it. Vivado, UART, JTAG, ILA, and the physical board were also not rerun.

## Not implemented

Tiled GEMM, DMA, MEXEC, MSTORE, complete Vision Mamba, and complete MNIST acceleration are not release claims. Legacy funct7 `0-5` and the existing C API remain compatibility requirements.
