# 最终答辩故事线（Final Storyline）

> 版本: V1.0  日期: 2026-05-22  作者: Justin JU
> 目的: 为终期答辩 PPT、讲稿、QA 提供同一条主线与同一份贡献清单。

## 一句话定位

本毕设在 RISC-V E203 软核之上, 通过 NICE 自定义指令接口集成了一颗轻量级 INT8 CNN 加速器, 完成了 RTL 与全 SoC 软件仿真闭环, 并完成 A7-100T FPGA 烧录环境验证；剩余工作集中在板级运行证据与软核调试通路。

## 答辩主线（一页讲述）

1. **背景与动机**: 边缘 AI 推理需要低功耗高效率；通用 RISC-V 软核易于裁剪与扩展, NICE 接口为自定义协处理器提供了标准化的指令级挂载方式。本课题选择"软核 + NICE + 轻量加速器"作为最小可验证的端到端路径。

2. **课题目标与范围**: 在 Hummingbird E203 SoC 上, 设计并集成一颗 INT8 CNN 加速器, 打通"SDK 应用 → 固件 → NICE 指令 → 加速器 → 结果回读"的完整指令链, 完成从 RTL 到全 SoC 仿真再到 FPGA 板上烧录的逐级验证。

3. **系统架构**: 四层分工——RISC-V E203 核心、NICE 自定义指令接口（Opcode 0x0b, funct7 编码）、CNN 加速器（INT8 16 lane MAC + 硬件 ReLU 可选）、Nuclei SDK 软件栈。软件可见命令集锁定为 `CLEAR / WLOAD / DLOAD / COMP / RSTAT`。

4. **加速器 RTL 设计**: 以 Output Stationary 为核心数据流, 实现权重/数据双缓冲, 控制 FSM 覆盖 busy 阻塞、非法 opcode / funct7 / index、复位清状态、重复 RSTAT 等安全场景。

5. **RTL 与全 SoC 仿真证据**: 历史阶段在软件驱动 SoC 上闭环至 `RSTAT=320`；当前最小 CNN v1 全 SoC 流程闭环至 `expected_rstat=19`, 显示日志 `[PHASE4_PASS]` 与 `[TB_PASS]`。三层仿真覆盖 Local RTL、官方轻量 SoC、全 SoC SDK。

6. **预板级与脚本闭环**: `Project_Manager.sh gen_model / run_hw / precheck`、`run_sdk_fullsoc_regression.sh`、`run_preboard_verification.sh`、`check_phase5_board_env.sh` 全部通过, 形成上板前最后一道自动化关卡。

7. **FPGA 板级 Bring-up（Route A）**: 选定达芬奇 Pro A7-100T 为目标板, PTD04 + Vivado 烧录链路在真实硬件上跑通；CNN v1 demo 已有 UART 输出与 ILA 捕获证据, 后续可继续补强 LED 阶段观测、更多样本与更完整的 Route A 运行证据。

8. **当前阻塞与诚实声明**: PTD04 通路尚不能直接做 CPU 软件级调试, BSCANE2 软核调试链路作为后续研究项, 不阻塞答辩交付主线。

9. **贡献小结**: 见下节"最终贡献清单"。

10. **未来工作**: 完成 Route A 板级证据三件套；补齐 BSCANE2 软核调试通路；将加速器从单层 INT8 MAC 扩展到多层流水以承载更大网络。

## 最终贡献清单

| # | 贡献 | 证据位置 |
|---|------|----------|
| C1 | 在官方 Hummingbird E203 SoC 上完成 CNN 加速器的 NICE 接口集成, 修正 funct7 vs funct3 关键问题 | `E203_FORMAL_INTEGRATION.md`, V1.5+ 集成日志 |
| C2 | 设计 16 lane INT8 NICE 计算通路, 实现稳定的 `CLEAR / WLOAD / DLOAD / COMP / RSTAT` 命令集与硬件 ReLU `CFG` | `CURRENT_STATE.md` 已锁定基线 |
| C3 | 完成接口安全验证全集: 复位、非法命令、非法索引、busy 阻塞、重复 RSTAT、partial load 后 COMP | `run_hw` 与 `run_preboard_verification.sh` 通过记录 |
| C4 | 打通三层仿真覆盖: Local RTL、官方轻量 SoC、全 SoC SDK, 软件可见结果 `RSTAT=320` 与 `expected_rstat=19` 闭环 | 仿真截图 `[TB_PASS]`, `[PHASE4_PASS]` |
| C5 | 建立 Pre-board 自动化关卡与板级环境检查脚本, 形成上板前可重复验证流程 | `scripts/run_preboard_verification.sh`, `scripts/check_phase5_board_env.sh` |
| C6 | 在达芬奇 Pro A7-100T 上完成 PTD04 + Vivado 烧录链路, 实现 A7-100T Route A bitstream 重建 | `DAVINCI_A7_100T_BRINGUP_V2_0.md`, PTD04 烧录记录 |
| C7 | 形成可交接的工程文档体系（CURRENT_STATE / PHASE_HISTORY / PROJECT_INDEX / PROJECT_RULES）支持长期协作 | `docs/` 目录全集 |

## 完成 / 未完成工作声明

**已完成（Closed）**

- E203/NICE 集成正式锁定
- 16 lane INT8 NICE 计算通路与命令集稳定
- 接口安全验证全集通过
- 三层仿真覆盖与 `RSTAT=320` / `expected_rstat=19` 软件可见结果
- Pre-board 自动化脚本 4 项全部通过
- A7-100T Vivado + PTD04 烧录链路在真实硬件验证通过
- 工程文档体系与 AI 协作交接体系建立

**仍开放（Open, 诚实声明）**

- UART/ILA 已支持当前 CNN v1 demo 与 hello_e203 证据, 但更完整、更稳定的板级运行记录仍可补强
- Route A 板级证据仍可补充: LED 阶段观测、更多 UART 里程碑截图、更多 ILA CPU/NICE 握手截图
- PTD04 暂不支持 CPU 软件级调试；BSCANE2 软核调试链路列为后续研究, 不阻塞答辩

## 用语口径（与论文/工程统一）

- 加速器称谓: "轻量级 INT8 CNN 加速器" / "NICE 协处理器", 不使用 "NPU"
- 接口称谓: "NICE 自定义指令接口", funct7 编码
- 板卡称谓: "达芬奇 Pro A7-100T"（`davinci_a7_100t`）
- 路线称谓: "Route A = UART + LED + ILA 证据优先", "Route B = 软核调试链路"
- 结果指标: 历史基线 `RSTAT=320`；当前基线 `expected_rstat=19`

## 用法

- PPT（Task 2）按"答辩主线"10 节展开, 每节对应 1 至 2 页
- 证据包（Task 3）按"最终贡献清单"逐行收集截图与日志
- QA（Task 4）围绕"仍开放"三条与"用语口径"做诚实回答
- 排练（Task 5）用本页作为 8 至 12 分钟脚本的骨架, 3 分钟版本只讲一句话定位 + 主线 1 / 5 / 7 / 8 / 9
