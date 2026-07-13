# Frontier Research Survey 2026: RISC-V Edge-AI Acceleration

> Project fit: RISC-V/E203 NICE CNN accelerator
> Purpose: identify newer frontier directions suitable for MPhil continuation
> Date: 2026-06-14

## Executive View

The strongest continuation direction is not simply a larger PE array. The
frontier has moved toward system-level co-design: ISA extension, memory/data
movement, compiler/runtime mapping, quantization, sparsity, and reproducible
evaluation must be considered together.

For this project, the best MPhil-level positioning is:

> Data-movement-aware RISC-V custom-instruction acceleration for resource-constrained edge AI.

This keeps the work close to the current E203/NICE prototype while allowing a
real research contribution: explaining when custom instructions help, when data
movement dominates, and how small edge-AI workloads should be mapped onto a
resource-limited RISC-V SoC.

## Direction 1: Data-Movement-Aware Custom RISC-V Acceleration

### Why It Is Frontier

Modern AI accelerators are often limited less by MAC count and more by data
movement, memory hierarchy, and software mapping. This is especially true for
small FPGA/edge SoC platforms where BRAM, timing margin, and instruction issue
overhead quickly dominate.

### Fit To This Project

The current design already has:

- E203/NICE custom instruction access.
- Register-operand data path.
- 4x4 INT8 PE array.
- Current 3x3 convolution-kernel speedup result.
- Clear evidence boundary showing that full-network acceleration is not yet proven.

That makes the next research question natural: whether line buffer, local SRAM,
double buffering, software tiling, or a limited memory-channel path gives the
best real improvement per resource cost.

### Research Questions

- How much of the current cycle cost comes from data loading vs compute?
- Is line buffering more efficient than expanding the PE array?
- Can software-managed tiling deliver most of the benefit without complex DMA?
- How do LUT/FF/BRAM/DSP and WNS/WHS change after buffering?

### Recommended Priority

High. This is the most project-aligned and research-defensible direction.

## Direction 2: RVV / Standard Extension Baseline Vs Custom NICE Extension

### Why It Is Frontier

RISC-V AI work is increasingly influenced by standard extensions and profiles.
The vector extension has become a major baseline for data-parallel workloads,
while matrix/tensor-style extensions and vendor custom extensions are active
areas for AI acceleration.

### Fit To This Project

Your current design uses a NICE custom instruction path. An MPhil can compare:

- scalar CPU baseline;
- custom NICE accelerator baseline;
- RVV-style vector baseline, if a suitable simulator/toolchain is available;
- hybrid software mapping where scalar/vector code handles unsupported layers.

The contribution does not need to implement a full RVV core. It can be a
methodological comparison using available simulators, published baselines, or a
small subset implementation.

### Research Questions

- For tiny CNN operators, when is a custom accelerator better than vector code?
- Which layers benefit from custom PE arrays, and which are better kept in software?
- How should a small edge SoC choose between custom instruction, vector, and
  software fallback?

### Recommended Priority

Medium-high. Strong research value, but toolchain and platform complexity are
higher than the pure NICE-buffering path.

## Direction 3: TinyML Workload Expansion And Quantization-Aware Evaluation

### Why It Is Frontier

Edge-AI evaluation is moving away from isolated kernels toward small but
end-to-end workloads. TinyML models, quantization, and layer-by-layer accuracy
tracking matter because a fast kernel is not enough to prove useful inference.

### Fit To This Project

The FYP already has LeNet-style demo material, but the current board claim is
sample-scoped. MPhil work can extend this into:

- fixed-point/INT8 quantization analysis;
- layer-level correctness;
- reduced network or full small-network execution;
- comparison between kernel speedup and end-to-end speedup.

### Research Questions

- Does kernel-level speedup translate into network-level speedup?
- Which layers dominate execution after convolution acceleration?
- How much accuracy loss is introduced by the selected INT8 flow?
- What is the smallest credible benchmark suite beyond LeNet-5?

### Recommended Priority

High as an evaluation track. It should support the main data-movement topic
rather than replace it.

## Direction 4: Compiler/Runtime Mapping For Custom Instructions

### Why It Is Frontier

Open AI hardware is increasingly paired with software stacks such as TVM,
MLIR-based flows, or accelerator-specific code generation. The research trend
is moving from hand-written demo calls to repeatable mapping from models to
hardware-supported operators.

### Fit To This Project

The current software path is small and hand-controlled, which is good for an
undergraduate prototype but limited for MPhil-scale research. A modest next step
is not a full compiler, but a structured mapping layer:

- operator descriptor;
- generated or templated C driver calls;
- benchmark metadata;
- reference-model comparison.

### Research Questions

- Can a simple operator description generate consistent driver calls and
  benchmark records?
- How much manual code is needed to map a small CNN to custom instructions?
- What information must a compiler know about buffer size and data layout?

### Recommended Priority

Medium. Useful if the hardware path stabilizes early; risky if attempted too
soon.

## Direction 5: Sparse And Mixed-Precision Edge-AI Acceleration

### Why It Is Frontier

Sparsity and low precision are major themes in efficient AI. For edge devices,
lower precision and skipping zero or low-value work can reduce memory traffic
and compute energy.

### Fit To This Project

The current design already uses INT8 and INT32 accumulation. A realistic MPhil
extension could examine:

- structured sparsity in weights;
- zero-skipping for activations;
- INT4 or mixed INT8/INT4 exploration in the reference model before RTL;
- accuracy/cycle/resource tradeoff.

### Research Questions

- Is sparsity worth the control overhead on a small PE array?
- Does lower precision reduce resource cost or only complicate verification?
- Which sparse pattern is easiest to map onto the current NICE interface?

### Recommended Priority

Medium-low as a main direction, medium as a later extension. It is interesting,
but can easily distract from the core data-movement problem.

## Direction 6: Open-Source Artifact And Reproducible Evaluation

### Why It Is Frontier

RISC-V research benefits from reproducible artifacts because hardware results
are often difficult to compare. A clean artifact with scripts, benchmark records,
claim boundaries, and source/evidence separation can itself be a strength.

### Fit To This Project

This project already has a strong verification chain and submission package
discipline. MPhil can extend that into a publishable artifact:

- one-command or documented regressions;
- benchmark record templates;
- source/evidence split;
- exact toolchain notes;
- archival logs for non-reproducible board runs.

### Research Questions

- What is the minimum artifact package needed to reproduce key RISC-V AI results?
- How should simulation, FPGA board sample, and full-dataset claims be separated?
- Can benchmark records prevent overclaiming and improve auditability?

### Recommended Priority

High as a supporting contribution. It strengthens every other direction.

## Direction Comparison

| Direction | Novelty | Project Fit | Risk | Best Role |
| --- | --- | --- | --- | --- |
| Data movement and buffering | High | Very high | Medium | Main thesis topic |
| RVV vs custom NICE comparison | High | Medium-high | High | Comparative chapter or stretch goal |
| TinyML/network-level evaluation | Medium-high | High | Medium | Main evaluation track |
| Compiler/runtime mapping | Medium-high | Medium | Medium-high | Year-2 extension |
| Sparse/mixed precision | Medium | Medium | Medium-high | Optional extension |
| Reproducible artifact | Medium | Very high | Low | Supporting contribution |

## Recommended MPhil Topic

Recommended title:

> Data-Movement-Aware RISC-V Custom Instruction Acceleration for Resource-Constrained Edge AI SoCs

Recommended Chinese title:

> 面向资源受限边缘 AI SoC 的数据搬运感知 RISC-V 自定义指令加速研究

Core contribution:

- Analyze the current custom-instruction CNN accelerator bottleneck.
- Add and compare data-movement improvements such as line buffer, local SRAM
  buffer, or software-managed tiling.
- Evaluate kernel-level and small-network-level performance.
- Report speedup together with resource, timing, correctness, and claim boundary.
- Provide a reproducible benchmark and artifact methodology.

## Suggested Reading And Source Anchors

- RISC-V Vector Extension specification and ratified vector baseline:
  `https://github.com/riscvarchive/riscv-v-spec/releases`
- RISC-V specifications and profile direction:
  `https://riscv.org/technical/specifications/`
- TVM/VTA hardware-software stack:
  `https://tvm.apache.org/2018/07/12/vta-release-announcement`
- VTA paper:
  `https://arxiv.org/abs/1807.04188`
- PULP open-source RISC-V SoC and AI acceleration ecosystem:
  `https://pulp-platform.org/`
- Gemmini systolic-array accelerator generator:
  `https://github.com/ucb-bar/gemmini`
- Chipyard/Gemmini integration:
  `https://chipyard.readthedocs.io/`

## Near-Term Action Plan

1. Keep the existing FYP result as the baseline, not as the final MPhil claim.
2. Build a literature matrix around data movement, custom instruction,
   vector/standard extension, and TinyML evaluation.
3. Measure the current design's load/compute/result-read cycle breakdown.
4. Implement the smallest useful buffering improvement.
5. Compare baseline vs buffered design using the same benchmark record format.
6. Extend evaluation from one 3x3 kernel to at least one multi-operator or
   small-network case.

## Claim Boundary

- Do not claim full LeNet-5 acceleration until end-to-end network timing exists.
- Do not claim full MNIST board accuracy until full board-side dataset evidence exists.
- Do not claim DMA, line buffer, or memory-channel support until implemented and measured.
- Keep simulation, board sample, and dataset-level evidence separate.

