# CNN 加速器毕设 - 一个月 OKR 规划

**制定日期**: 2026-03-21  
**目标**: 一个月内完成具有创新点的 CNN 加速器毕设  
**总目标**: 完成支持可配置 kernel size 的简化 CNN 加速器，实现完整 conv forward 流程

---

## 🎯 OBJECTIVE 1: 完成硬件架构扩展

**目标**: 在现有 4×4 PE Array 基础上，扩展为支持多种 kernel size 的 CNN 加速器

### Key Results

| KR | 描述 | 目标 | 状态 |
|----|------|------|------|
| **KR1.1** | 添加 ReLU 激活模块 | TB 验证通过 | 🔲 |
| **KR1.2** | 扩展 PE Array 支持 3×3/5×5/7×7 | 可配置参数 | 🔲 |
| **KR1.3** | 添加 Layer Controller FSM | 支持多层切换 | 🔲 |
| **KR1.4** | 实现 Input Buffer (ping-pong) | 模块仿真通过 | 🔲 |
| **KR1.5** | 实现 Weight Buffer + Prefetch | 模块仿真通过 | 🔲 |

---

## 🎯 OBJECTIVE 2: 完成软件栈和驱动

**目标**: 实现完整的 CNN 软件驱动，支持从高层调用加速器

### Key Results

| KR | 描述 | 目标 | 状态 |
|----|------|------|------|
| **KR2.1** | 设计 NICE 新指令集 | 更新 ARCHITECTURE.md | 🔲 |
| **KR2.2** | 编写 CNN 软件驱动 | cnn_driver.c | 🔲 |
| **KR2.3** | 实现 3 层卷积 forward | 端到端测试通过 | 🔲 |
| **KR2.4** | 与 Python model 对比验证 | 结果误差 < 1% | 🔲 |

---

## 🎯 OBJECTIVE 3: 完成验证和测试

**目标**: 建立完整的验证体系，确保加速器功能正确

### Key Results

| KR | 描述 | 目标 | 状态 |
|----|------|------|------|
| **KR3.1** | Module-level TB | 各模块独立验证 | 🔲 |
| **KR3.2** | Integration TB | 整体数据流验证 | 🔲 |
| **KR3.3** | 资源利用率分析 | LUT/RAM 报告 | 🔲 |
| **KR3.4** | 性能分析 | GOPS vs 理论峰值 | 🔲 |

---

## 🎯 OBJECTIVE 4: 完成论文和答辩

**目标**: 产出完整的毕设论文和答辩 PPT

### Key Results

| KR | 描述 | 目标 | 状态 |
|----|------|------|------|
| **KR4.1** | 论文框架 + 图表 | 初稿完成 | 🔲 |
| **KR4.2** | 实验数据整理 | 对比表格 | 🔲 |
| **KR4.3** | PPT 制作 | 答辩版 | 🔲 |
| **KR4.4** | 最终版本 | 查漏补缺 | 🔲 |

---

## 📅 Weekly Breakdown

### Week 1 (03/21 - 03/27): 硬件基础模块

| Week | Focus | Tasks |
|------|-------|-------|
| **Day 1** | ReLU 设计 | 1. 分析现有 pe_array.v <br>2. 设计 relu.v <br>3. 编写 relu_tb.v |
| **Day 2** | ReLU 集成 | 1. 集成 ReLU 到数据流 <br>2. 验证正负数处理 <br>3. 更新模块连接 |
| **Day 3** | 可配置 PE Array | 1. 设计参数化 PE Array <br>2. 支持 K=3/5/7 <br>3. 更新时序逻辑 |
| **Day 4** | 可配置 PE Array | 1. 完善配置接口 <br>2. 编写 pe_array_config_tb.v |
| **Day 5** | Layer Controller | 1. 设计状态机 <br>2. 定义 layer 切换信号 |
| **Day 6** | Layer Controller | 1. 实现 layer_cfg 寄存器 <br>2. 编写 layer_ctrl_tb.v |
| **Day 7** | **Week 1 回顾** | 1. 检查 KR1.1-1.3 进度 <br>2. 更新 OKR 状态 <br>3. 调整 Week 2 计划 |

**Week 1 Deliverables**: ReLU + 可配置 PE Array + Layer Controller 源码 + TB

---

### Week 2 (03/28 - 04/03): 数据流模块

| Week | Focus | Tasks |
|------|-------|-------|
| **Day 8** | SPEC 更新 | 1. 更新 ARCHITECTURE.md <br>2. 定义新 NICE 指令集 |
| **Day 9** | Input Buffer | 1. 设计双缓冲架构 <br>2. 实现 ping-pong 切换 |
| **Day 10** | Input Buffer | 1. 编写 input_buffer_tb.v <br>2. 验证数据连续性 |
| **Day 11** | Weight Buffer | 1. 设计 weight 预取机制 <br>2. 实现 buffer 管理 |
| **Day 12** | Weight Buffer | 1. 编写 weight_buffer_tb.v <br>2. 验证 prefetch 时序 |
| **Day 13** | 模块集成 | 1. 设计 cnn_accel_top.v <br>2. 连接各子模块 |
| **Day 14** | **Week 2 回顾** | 1. 检查 KR1.4-1.5 进度 <br>2. 更新 OKR 状态 <br>3. 调整 Week 3 计划 |

**Week 2 Deliverables**: 新 SPEC + Input/Weight Buffer + Top 模块

---

### Week 3 (04/04 - 04/10): 集成和驱动

| Week | Focus | Tasks |
|------|-------|-------|
| **Day 15** | 集成调试 | 1. 运行整体 TB <br>2. 修复接口问题 |
| **Day 16** | 集成调试 | 1. 数据流验证 <br>2. 时序问题修复 |
| **Day 17** | CNN 驱动 | 1. 设计驱动 API <br>2. 实现 layer 配置函数 |
| **Day 18** | CNN 驱动 | 1. 实现 conv 执行函数 <br>2. 结果读取函数 |
| **Day 19** | 端到端测试 | 1. 3-layer conv 测试 <br>2. 与 C model 对比 |
| **Day 20** | 端到端调试 | 1. 修复对比误差 <br>2. 优化数据路径 |
| **Day 21** | **Week 3 回顾** | 1. 检查 KR2.1-2.4 进度 <br>2. 更新 OKR 状态 |

**Week 3 Deliverables**: 可运行的 CNN 加速器 + 驱动 + 3-layer 测试

---

### Week 4 (04/11 - 04/17): 验证和论文

| Week | Focus | Tasks |
|------|-------|-------|
| **Day 22** | 资源分析 | 1. 综合生成报告 <br>2. LUT/RAM 统计 |
| **Day 23** | 性能分析 | 1. 计算理论峰值 <br>2. 实测 GOPS |
| **Day 24** | 论文框架 | 1. 搭建论文结构 <br>2. 绘制架构图 |
| **Day 25** | 论文撰写 | 1. 完成相关工作章节 <br>2. 完成设计章节 |
| **Day 26** | 论文撰写 | 1. 完成实验章节 <br>2. 整理数据图表 |
| **Day 27** | PPT 制作 | 1. 制作答辩 PPT <br>2. 准备演示 |
| **Day 28** | **最终检查** | 1. 论文终稿 <br>2. PPT 定稿 <br>3. 代码整理 |

**Week 4 Deliverables**: 综合报告 + 论文 + PPT

---

## 📊 Weekly Review Template

每周日填写：

```markdown
### Week X Review (YYYY-MM-DD)

**KR 进度**:
- KR1.1: [状态] - [备注]
- KR1.2: [状态] - [备注]
...

**完成度**: X/Y tasks completed

**下周调整**:
- [调整 1]
- [调整 2]
```

---

## 🚨 风险和对策

| 风险 | 影响 | 对策 |
|------|------|------|
| NICE 接口限制 | 数据带宽不足 | 优化传输效率，预取策略 |
| 时序收敛问题 | 最高频率受限 | 流水线化，关键路径优化 |
| 仿真时间过长 | 开发迭代慢 | 使用 verilator，简化 TB |
| 论文时间不够 | 无法完成 | 优先保证核心章节 |

---

## 🎁 创新点清单

1. **NICE 接口的 CNN 扩展方案**
   - 新的指令编码
   - Layer 切换协议

2. **可配置 PE Array**
   - 软件定义 kernel size
   - 资源利用率优化

3. **简化的 CNN 数据流**
   - 单周期 layer 切换
   - weight preload 机制

---

*每周更新此文件，记录进度和调整*
