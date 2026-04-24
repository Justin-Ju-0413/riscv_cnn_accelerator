# Notion Sync Plan: Thesis and Final Defense

## Target Page

`毕业设计管理中心`

## Add Section 1: 论文撰写 / Thesis Writing

Description:

用于统一管理论文大纲、章节草稿、参考文献、图表证据和导师修改意见。论文口径必须和当前项目真实状态一致：RTL/NICE 和 full-SoC 仿真已经闭环，Davinci Pro A7-100T 的 soft-core debug path 仍在推进。

Suggested table name:

`论文撰写 / Thesis Writing`

Columns:

- 名称
- 状态
- 截止日期
- 优先级
- 任务类型
- 描述

Rows:

| 名称 | 状态 | 截止日期 | 优先级 | 任务类型 | 描述 |
| --- | --- | --- | --- | --- | --- |
| Build Thesis Outline | 未开始 | 2026年4月27日 | 高 | 论文结构 | 确定 Chapter 1-7 的论文结构，和当前项目证据链对齐 |
| Collect Core References | 未开始 | 2026年4月28日 | 高 | 文献整理 | 收集 RISC-V、E203/NICE、CNN accelerator、FPGA、OpenOCD/GDB 文献 |
| Draft Introduction and Related Work | 未开始 | 2026年5月1日 | 中 | 章节草稿 | 先写背景、相关工作和项目目标 |
| Draft Architecture and RTL Chapters | 未开始 | 2026年5月5日 | 高 | 章节草稿 | 解释 E203、NICE、CNN accelerator、RTL regression |
| Draft Full-SoC and Board Debug Chapters | 未开始 | 2026年5月9日 | 高 | 章节草稿 | 解释 SDK/full-SoC、expected_rstat=19、soft-core debug blocker |
| Prepare Thesis Figures | 未开始 | 2026年5月10日 | 中 | 图表证据 | 整理架构图、NICE 流程图、RTL/full-SoC 截图 |

## Add Section 2: 最终答辩 / Final Defense

Description:

用于准备最终答辩 PPT、演讲稿、证据包和问答。答辩主线要和论文一致，不夸大板级进度，重点说明已经闭环的仿真和集成工作，以及当前软核调试卡点。

Suggested table name:

`最终答辩 / Final Defense`

Columns:

- 名称
- 状态
- 截止日期
- 优先级
- 任务类型
- 描述

Rows:

| 名称 | 状态 | 截止日期 | 优先级 | 任务类型 | 描述 |
| --- | --- | --- | --- | --- | --- |
| Lock Final Defense Storyline | 未开始 | 2026年5月3日 | 高 | 汇报结构 | 固定最终答辩叙事：RTL/full-SoC 闭环，board debug 推进中 |
| Build Final Slide Deck | 未开始 | 2026年5月8日 | 高 | PPT | 制作最终答辩 PPT，包含架构、RTL、full-SoC、板级调试 |
| Prepare Evidence Package | 未开始 | 2026年5月8日 | 高 | 证据整理 | 整理 TB_PASS、expected_rstat=19、branch/commit、截图和日志 |
| Prepare Defense QA | 未开始 | 2026年5月10日 | 中 | QA | 准备中英文问答，覆盖 NICE、RTL、full-SoC、调试器问题 |
| Rehearse 8-12 Minute Version | 未开始 | 2026年5月12日 | 中 | 演讲准备 | 练习正式答辩版本，控制时间和口头表达 |
| Prepare 3 Minute Short Version | 未开始 | 2026年5月12日 | 低 | 演讲准备 | 准备老师要求快速说明时的短版本 |

## Add Quick Navigation Links

Add under `当前工作中心导航`:

- `论文撰写 / Thesis Writing`
- `最终答辩 / Final Defense`

## Add Current Rule

论文、答辩和开发现在共用同一条证据链：

`RTL_PASS -> full-SoC PASS -> board debug blocker -> next debug solution`

