# 深度研究方案：面向边缘 AI 的 RISC-V 自定义指令 CNN 加速器

> 适用对象：研究助理 / MPhil 前期调研与方案论证
> 项目基础：E203 + NICE + 4x4 INT8 PE 阵列 + RTL/FullSoC/FPGA 样例验证
> 主线方向：数据搬运感知的 RISC-V 自定义指令边缘 AI 加速
> 输出目标：形成可支撑 MPhil proposal、实验路线、论文选题和后续实现的研究材料

## 1. 研究定位

当前本科项目已经完成了一个可验证原型：E203 通过 NICE 接口接入轻量 CNN 协处理器，支持
`CFG/CLEAR/WLOAD/DLOAD/COMP/RSTAT` 六类软件可见操作，具备 4x4 INT8 PE 阵列，并已有
RTL、FullSoC 和 FPGA 样例验证证据。

继续研究时，不能只把题目写成“扩大 CNN 加速器规模”。更有研究价值的方向是：

> 在资源受限的 RISC-V 边缘 AI SoC 中，自定义指令、数据搬运、片上缓存、软件映射和可复现评测如何共同决定端到端 CNN 加速效果？

这个问题直接连接现有成果，也符合领域走向：RISC-V AI 研究正在从单点 accelerator
implementation 转向 ISA、memory hierarchy、compiler/runtime、TinyML workload 和 reproducible artifact 的协同设计。

## 2. 已有成果边界

研究助理必须先理解并保持以下边界：

- 已完成：
  - E203/NICE request-response 集成路径；
  - `CFG/CLEAR/WLOAD/DLOAD/COMP/RSTAT` 指令级控制；
  - 4x4 INT8 PE array，INT32 accumulation；
  - RTL testbench、FullSoC simulation、FPGA UART/ILA 样例验证；
  - 3x3 convolution kernel 中 `1516 vs 287 cycles`，约 `5.282x` 的样例 speedup；
  - FPGA 板级 10 张 MNIST/LeNet-style 样例演示 `10/10`。

- 不能当作已完成：
  - 完整 LeNet-5 端到端 FPGA 加速；
  - 完整 MNIST board-side accuracy；
  - DMA 或 NICE memory channel 主存搬运；
  - line buffer / ping-pong buffer；
  - 更大 PE array；
  - RVV/vector baseline；
  - compiler 自动映射。

RA 所有调研和报告都必须区分：仿真证据、板级样例证据、完整数据集证据。

## 3. 核心研究假设

### H1: 当前瓶颈不一定是算力，而是数据搬运与软件映射。

4x4 PE array 已能产生 kernel-level speedup，但要实现 network-level speedup，需要减少软件显式 load、数据重复搬运和层间组织开销。

### H2: 小型 RISC-V SoC 上，line buffer / local SRAM / software tiling 可能比盲目扩大 PE array 更有效。

扩大 PE array 会增加资源和时序压力；而数据复用结构可能以更低成本提高实际利用率。

### H3: MPhil 的贡献应是“定量比较和可复现方法”，不是单一 demo。

最终需要比较 baseline、buffered design、operator-expanded design 等多个版本，并统一报告 correctness、cycles、speedup、resources、timing、claim boundary。

## 4. RA 调研任务包

### Task A: 领域前沿扫描

目标：建立该方向近年前沿地图，明确哪些路线值得跟、哪些不适合本项目。

需要调研的方向：

- RISC-V custom instruction AI accelerator；
- RISC-V Vector Extension / matrix or tensor-style extension；
- TinyML accelerator and edge inference；
- dataflow and memory hierarchy for CNN accelerators；
- line buffer、double buffering、software tiling；
- quantization and mixed precision；
- sparse acceleration；
- open-source accelerator frameworks such as Gemmini, VTA, PULP, Chipyard；
- reproducible hardware artifact and benchmark methodology。

输出物：

- `literature_matrix.xlsx` 或 Markdown 表格；
- 每篇论文/项目至少记录：
  - title, year, venue/source；
  - target workload；
  - ISA/interface approach；
  - compute architecture；
  - memory/data movement method；
  - precision；
  - evaluation platform；
  - reported metrics；
  - what can be reused by this project；
  - why it is or is not comparable。

验收标准：

- 至少 30 个文献/项目条目；
- 近 3 年材料不少于 12 个；
- 至少覆盖 5 个开源或可复现系统；
- 输出一页“领域趋势总结”。

### Task B: 与现有项目的差距分析

目标：明确当前 FYP 原型距离 MPhil 研究型系统还差什么。

分析维度：

- ISA/interface：NICE custom instruction 与 RVV/标准扩展的关系；
- data movement：当前 register-operand path 的开销；
- memory hierarchy：当前是否缺少 line buffer / local SRAM / tiling；
- workload：当前 3x3 kernel 与完整 TinyML workload 的差距；
- verification：RTL/FullSoC/FPGA evidence 的可复现程度；
- evaluation：是否同时报告 speedup、resource、timing 和 correctness。

输出物：

- gap analysis report；
- current-vs-frontier comparison table；
- top 5 research gaps ranked by feasibility and novelty。

验收标准：

- 每个 gap 必须对应现有项目中的具体证据或缺口；
- 不允许只写泛泛的“性能还可以优化”。

### Task C: Benchmark 与 workload 设计

目标：为后续研究定义可信评测集合。

必须包含：

- micro-benchmarks：
  - 3x3 convolution；
  - 1x1 convolution；
  - multi-channel 3x3 convolution；
  - stride/padding case；
  - activation or pooling fallback case。

- network-level workloads：
  - LeNet-style baseline；
  - one TinyML-style small CNN；
  - optional DS-CNN / keyword spotting subset or MobileNet-like reduced block。

每个 benchmark 需要定义：

- input shape；
- weight shape；
- precision；
- expected output；
- CPU-only implementation；
- accelerator-assisted implementation；
- metrics；
- evidence level required。

输出物：

- benchmark specification；
- Python reference model plan；
- data format and golden output format；
- claim boundary table。

验收标准：

- 所有 benchmark 都能映射到“为什么对研究问题有用”；
- 至少一个 benchmark 能体现 data reuse；
- 至少一个 benchmark 能体现 kernel speedup 与 network speedup 的差距。

### Task D: 数据搬运优化方案设计

目标：提出 2-3 个可实现的优化路线，并比较其研究价值。

候选方案：

1. Software-managed tiling：
   - 保持硬件改动最小；
   - 通过软件组织数据复用；
   - 适合作为低风险 baseline。

2. Line buffer：
   - 面向 sliding window convolution；
   - 目标是减少重复输入加载；
   - 需要处理 padding、stride、边界条件。

3. Local activation/weight SRAM buffer：
   - 在 PE 附近缓存输入或权重；
   - 可能增加 BRAM 使用；
   - 适合比较 resource vs cycle tradeoff。

4. NICE memory-channel / DMA-like path：
   - 研究价值高；
   - 侵入性和风险高；
   - 建议作为 Year-2 stretch goal，不作为第一阶段必需实现。

输出物：

- design alternative report；
- architecture sketches；
- expected command/API impact；
- risk and resource estimate；
- recommended first implementation target。

验收标准：

- 明确推荐一个 first implementation；
- 说明为什么不优先扩大 PE array；
- 每个方案都给出可能的验证路径。

### Task E: RVV / 标准扩展对比路线

目标：判断是否需要把 RVV 或标准扩展作为 thesis 中的比较章节。

调研内容：

- RVV 对 INT8/卷积/TinyML workload 的适配方式；
- 是否有可用 simulator、toolchain 或 published baseline；
- custom NICE accelerator 与 vector baseline 的公平比较方式；
- RISC-V profiles 和未来 AI/matrix 方向对选题表述的影响。

输出物：

- RVV/custom comparison feasibility note；
- recommended comparison level：
  - full implementation；
  - simulator-level comparison；
  - literature-based baseline；
  - background-only discussion。

验收标准：

- 给出清晰建议：做、弱做、还是不做；
- 若不做，说明原因和论文中如何处理审稿人可能的问题。

### Task F: 可复现 artifact 设计

目标：把现有项目优势转化成研究贡献的一部分。

需要设计：

- source/evidence/report 分离结构；
- benchmark record format；
- command log policy；
- board evidence archival policy；
- result claim checklist；
- artifact README structure。

输出物：

- artifact plan；
- result audit checklist；
- reproducibility risk list。

验收标准：

- 能防止 `5.282x` 被误写成 full-network speedup；
- 能防止 `10/10` 被误写成 full MNIST accuracy；
- 每个结果都能追溯到 benchmark record 或 evidence file。

## 5. 实验矩阵建议

| Experiment | Baseline | Variant | Metrics | Evidence |
| --- | --- | --- | --- | --- |
| 3x3 conv kernel | Current NICE design | software tiling / buffer | cycles, speedup, load count, resources | RTL + FullSoC + optional board |
| multi-channel conv | CPU-only | accelerator-assisted | correctness, cycles, utilization | Python + RTL + FullSoC |
| line buffer benefit | no line buffer | line buffer | cycles, BRAM, WNS/WHS | RTL + synthesis |
| local SRAM buffer | register path | SRAM buffer | load count, cycles, BRAM | RTL + FullSoC |
| TinyML layer mapping | CPU-only | hybrid mapping | layer cycles, correctness | Python + software |
| board sample | previous board demo | optimized demo | UART output, ILA summary | board evidence |
| artifact reproducibility | manual run | scripted/recorded run | setup steps, pass/fail | documentation + logs |

## 6. 推荐研究路线

### 主线

Data-movement-aware RISC-V custom-instruction CNN acceleration.

### 第一阶段

- 文献和系统调研；
- 当前项目 gap analysis；
- benchmark/workload 定义；
- 当前 baseline 重新记录；
- 数据搬运瓶颈分析。

### 第二阶段

- software tiling 或 line buffer 作为 first implementation；
- 保持 NICE command path 尽量兼容；
- 完成 Python -> RTL -> FullSoC 验证；
- 报告 cycle/resource/timing tradeoff。

### 第三阶段

- 扩展到 multi-channel 或 reduced TinyML network；
- 比较 kernel-level speedup 与 network-level speedup；
- 加入 RVV/custom 或 literature baseline 对比；
- 整理 paper/proposal。

## 7. RA 工作节奏

### 每周输出

- 1 页 weekly memo：
  - 本周读了什么；
  - 得到什么结论；
  - 和本项目有什么关系；
  - 下周要验证什么。

### 每两周输出

- 1 个表格或图：
  - literature matrix 更新；
  - architecture comparison；
  - benchmark definition；
  - experimental result table。

### 每月输出

- 1 份 milestone report：
  - research progress；
  - engineering progress；
  - risks；
  - decision request。

## 8. 8 周启动计划

| Week | Focus | RA Output |
| --- | --- | --- |
| 1 | 熟悉当前项目和证据边界 | baseline reading memo |
| 2 | RISC-V AI accelerator 文献扫描 | 15-entry literature matrix |
| 3 | TinyML / data movement / memory hierarchy 扫描 | 30-entry literature matrix |
| 4 | gap analysis | current-vs-frontier report |
| 5 | benchmark/workload 草案 | benchmark spec v0.1 |
| 6 | data movement 方案比较 | design alternative report |
| 7 | RVV/custom feasibility | comparison feasibility note |
| 8 | 汇总成 MPhil proposal skeleton | research proposal draft |

## 9. 最终产出格式

RA 最终需要交付：

- `01_literature_matrix`
- `02_gap_analysis_report`
- `03_benchmark_specification`
- `04_data_movement_design_alternatives`
- `05_rvv_custom_comparison_note`
- `06_artifact_reproducibility_plan`
- `07_mphil_proposal_skeleton`

其中 proposal skeleton 应包含：

- title；
- abstract；
- background；
- research gap；
- research questions；
- methodology；
- experiment plan；
- expected contributions；
- risk plan；
- 12-24 month timeline。

## 10. 推荐题目

英文：

> Data-Movement-Aware RISC-V Custom Instruction Acceleration for Resource-Constrained Edge AI SoCs

中文：

> 面向资源受限边缘 AI SoC 的数据搬运感知 RISC-V 自定义指令加速研究

## 11. 判断一个方向是否值得继续的标准

一个方向值得继续，必须同时满足：

- 和当前 E203/NICE 项目有自然连接；
- 能产生可测量差异，而不是只换说法；
- 能同时报告 performance 和 hardware cost；
- 能从 kernel-level 走向至少 reduced-network-level evaluation；
- 不依赖无法控制的大型工具链或不可获得硬件；
- 能形成论文中的 research question，而不是单纯工程修补。

## 12. 不推荐作为主线的方向

- 单纯扩大 PE array：容易变成资源堆叠，研究问题弱。
- 直接做完整 NPU：工作量过大，和现有 NICE 原型断裂。
- 只做 sparsity：有前沿性，但控制逻辑复杂，容易偏离主线。
- 一开始就做完整 compiler：风险高，容易消耗时间但缺少硬件结果。
- 只追求 board demo：对论文贡献不够，需要方法论和系统比较。

## 13. 资料入口

项目内阅读顺序：

1. `docs/roadmap/FRONTIER_RESEARCH_SURVEY_2026.md`
2. `docs/roadmap/FUTURE_RND_PLAN.md`
3. `docs/roadmap/MPHIL_YEAR_MONTH_PLAN.md`
4. `docs/benchmarks/README.md`
5. `docs/CURRENT_STATE.md`

外部资料锚点：

- RISC-V specifications and profiles: `https://riscv.org/technical/specifications/`
- RISC-V Vector spec: `https://github.com/riscvarchive/riscv-v-spec/releases`
- TVM/VTA: `https://tvm.apache.org/2018/07/12/vta-release-announcement`
- VTA paper: `https://arxiv.org/abs/1807.04188`
- PULP Platform: `https://pulp-platform.org/`
- Gemmini: `https://github.com/ucb-bar/gemmini`
- Chipyard/Gemmini docs: `https://chipyard.readthedocs.io/`

