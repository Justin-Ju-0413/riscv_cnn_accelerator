# Literature and reproducibility matrix

This matrix is a screening tool for the MPhil proposal. “Reuse” means a concept or
evaluation method to adopt; “boundary” records what this project must not duplicate
or overclaim.

| Work / source | Main operator or topic | Data-movement treatment | Platform / precision | Reuse for this project | Boundary or gap |
|---|---|---|---|---|---|
| CALAS ViM-Q, FPGA 2026 | quantized Vision Mamba and dedicated SSM pipeline | model- and pipeline-specific buffering | FPGA, dynamic quantization | ViM block as a downstream workload | do not repeat its quantization or full specialized pipeline |
| CALAS FastViT work | efficient vision transformer | accelerator-oriented mapping | FPGA/edge AI | attention/MatMul workload framing | project contribution remains RISC-V integration |
| CALAS sparse-convolution work | sparse CNN | exploits zero structure | FPGA/AI hardware | sparse traffic as a later ablation | not a sparse accelerator in phase one |
| CALAS S-RISC-V | secure RISC-V processor | protection-oriented SoC integration | RISC-V | optional isolation/integrity extension | security is not the primary thesis |
| RISC-V 2025 annual report | IME, VME, AME matrix proposals | architectural state and software mapping | draft ecosystem | instruction-semantics comparison and standards context | NICE v2 is a custom research ABI, not standards-compliant matrix ISA |
| RVV 1.0 | vector computation | register/vector memory operations | standard RISC-V vector ISA | semantic baseline in simulation | no raw-cycle comparison across unequal cores |
| Gemmini | generator for systolic accelerators | explicit scratchpad/accumulator and DMA | RISC-V/RoCC, configurable | design-space and reproducibility reference | current project targets E203/NICE and much smaller resource budgets |
| VTA | programmable tensor accelerator | virtual-threaded load/compute/store model | FPGA, INT8 | decoupled command and tiling concepts | avoid recreating a full compiler stack |
| PULP / XpulpNN | tightly coupled edge inference | TCDM and DSP/SIMD extensions | RISC-V MCU | edge-AI baseline and memory-efficiency metrics | different core/memory system requires normalized comparison |
| NVDLA small configurations | tensor engine | convolution buffer and DMA | ASIC/FPGA model | dataflow terminology and utilization metrics | far larger system scope |
| Google Coral NPU / open edge NPU work | edge tensor execution | compiler-managed on-chip memory | edge inference | operator coverage reference | not a product-NPU replication |
| Mamba | selective state-space model | recurrent/selective scan | GPU/model research | definition of SSM workload | full model is outside A7 phase-one scope |
| Mamba-2 / state-space duality | structured state-space and attention relation | chunked/parallel formulation | model/software | motivates shared tensor + scan primitives | do not claim a new model architecture |
| Vision Mamba | visual sequence modeling | 2-D image-to-sequence mapping | vision model | front-end workload connection | only a block is evaluated on the current board |
| Linear attention accelerators | matrix and recurrence-like operators | reuse and tiling across sequence dimension | FPGA/ASIC | shared tensor/scan comparison | contribution must be storage/interface co-design |
| MLPerf Tiny v1.3 | architecture-neutral tiny inference | end-to-end benchmark rules | MCU/edge devices | workload quality targets and reporting discipline | implementation is “MLPerf Tiny-style” unless submitted under official rules |
| DS-CNN keyword spotting | depthwise separable convolution | compact activation/weight traffic | TinyML | depthwise block and network-level benchmark | accuracy requires a named dataset/training recipe |
| ResNet-8/CIFAR-10 | compact residual CNN | 1×1/3×3 and residual traffic | TinyML-style | representative tiled convolution workload | no accuracy claim before complete software/model flow |
| Current E203/NICE accelerator | 4×4 INT8 kernel | repeated register loads; memory path tied off | Artix-7 historical evidence | verified backward-compatible baseline | `5.282×` is kernel-only and `10/10` is sample-only |

## Reproducibility fields required for every evaluated work

For each paper selected for direct comparison, record:

- exact paper and artifact version;
- public code, model, dataset, and license availability;
- operator shapes, batch size, sequence length, and padding;
- precision, scale/zero-point handling, accumulation, saturation, and rounding;
- core, memory hierarchy, clock, tool version, and FPGA/ASIC technology;
- latency definition, warm-up, transfer inclusion, and measurement method;
- LUT/FF/BRAM/DSP, timing constraints, Fmax, WNS, and WHS;
- whether results were reproduced, reimplemented, estimated, or cited.

## Immediate reading order

1. Current project benchmark records and RTL interface.
2. CALAS ViM-Q and adjacent CALAS AI-hardware work.
3. Gemmini, VTA, PULP/XpulpNN, and MLPerf Tiny methodology.
4. RISC-V RVV plus IME/VME/AME proposal material.
5. Mamba-2, Vision Mamba, and linear-attention operator mappings.

The first literature deliverable is complete only when each selected comparison has a
filled reproducibility row. A bibliography alone is insufficient.
