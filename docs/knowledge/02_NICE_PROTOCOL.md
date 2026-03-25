# NICE 协议详解

> 版本: 1.0 | 更新: 2026-03-26
> 参考: doc.nucleisys.com/hbirdv2/core/core.html

---

## 2.1 什么是 NICE

NICE (Nuclei Instruction Co-unit Extension) 是 E203 官方提供的**协处理器扩展接口**，允许用户自定义硬件加速单元并通过指令调用的方式集成到 E203 核上。

**与直接内存映射 (AXI/APB) 对比**:

| 特性 | NICE | AXI/APB 内存映射 |
|------|------|------------------|
| 调用方式 | 指令 | 内存读写 |
| 参数传递 | 寄存器 | 内存地址 |
| 集成复杂度 | 低 | 中 |
| 适合场景 | 计算密集 | 数据密集 |

---

## 2.2 4 条通道

```
┌──────────────────────────────────────────────────────┐
│                    E203 Core                         │
│                                                      │
│  Request Channel ──────────────────────────────────→ │
│       nice_req_valid                                 │
│       nice_req_ready                                 │
│       nice_req_instr[31:0]     ─────────────────→   │
│       nice_req_rs1[31:0]        ─────────────────→  │  NICE Core
│       nice_req_rs2[31:0]        ─────────────────→  │  (CNN Accel)
│                                                      │
│  Response Channel ←───────────────────────────────── │
│       nice_rsp_valid                                │
│       nice_rsp_ready                                │
│       nice_rsp_data[31:0]    ←──────────────────    │
│                                                      │
│  Memory Request Channel (optional) ───────────────→ │
│       nice_mem_req_valid                            │
│       nice_mem_req_ready                            │
│       nice_mem_req_addr                             │
│       ...                                           │
│                                                      │
│  Memory Response Channel ←─────────────────────────  │
│       nice_mem_rsp_valid                            │
│       nice_mem_rsp_data                             │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### 通道 1: 请求通道 (Request)

| 信号 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `nice_req_valid` | Core → NICE | 1 | 请求有效 |
| `nice_req_ready` | Core ← NICE | 1 | NICE 准备好了 |
| `nice_req_instr` | Core → NICE | 32 | 指令编码 |
| `nice_req_rs1` | Core → NICE | 32 | 源操作数1 |
| `nice_req_rs2` | Core → NICE | 32 | 源操作数2 |

### 通道 2: 响应通道 (Response)

| 信号 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `nice_rsp_valid` | Core ← NICE | 1 | 响应有效 |
| `nice_rsp_ready` | Core → NICE | 1 | Core 准备好了 |
| `nice_rsp_data` | Core ← NICE | 32 | 结果数据 |

### 通道 3/4: 存储通道 (Memory, 可选)

本项目**未启用**，采用寄存器传参方式。

---

## 2.3 NICE 指令格式

RISC-V 32位指令中，bits `[1:0] = 2'b11` 表示是标准 32 位格式。

```
  31          25  24  20  19  15  14  12  11     7  6      0
┌───────────────┬──────┬──────┬───────┬────────┬─────────┬───────┐
│   funct7     │ rs2  │ rs1  │ xs2   │  rd    │ funct3  │opcode │
│    (7)       │ (5)  │ (5)  │ (1)   │  (5)   │  (3)    │ (7)   │
└───────────────┴──────┴──────┴───────┴────────┴─────────┴───────┘
```

**E203 NICE 关键约定**:
- bits `[14:12]` = `xd / xs1 / xs2` (不是 funct3!)
- `funct7` 用于选择协处理器具体操作

| 控制位 | 含义 |
|--------|------|
| `xd=1` | 结果写回 rd |
| `xs1=1` | 读取 rs1 |
| `xs2=1` | 读取 rs2 |

---

## 2.4 握手时序

```
  Clock  │  nice_req_valid  nice_req_ready  nice_rsp_valid  nice_rsp_ready
 ────────┼────────────────────────────────────────────────────────────────
    T0   │       0               1               0               0
    T1   │       1               1               0               0    ← req
    T2   │       0               0               0               0    ← 等待计算
    T3   │       0               0               1               0
    T4   │       0               0               1               1    ← rsp
    T5   │       0               1               0               0    ← 完成
```

**关键点**:
- `req_valid` 只持续 **1 cycle**（脉冲式）
- `req_ready` 在忙时拉低，阻止新请求
- `rsp_valid` 保持到 `rsp_ready` 握手完成

---

## 2.5 本项目 NICE 指令

| 指令 | funct7 | xd | xs1 | xs2 | 说明 |
|------|--------|-----|-----|-----|------|
| **CLEAR** | 4 | 0 | 0 | 0 | 清零累加器 |
| **WLOAD** | 0 | 0 | 1 | 1 | 加载权重 (rs1=数据, rs2=索引) |
| **DLOAD** | 1 | 0 | 1 | 1 | 加载激活值 (rs1=数据, rs2=索引) |
| **COMP** | 2 | 0 | 0 | 0 | 触发计算 |
| **RSTAT** | 3 | 1 | 0 | 0 | 读取结果 (rd=目标寄存器) |

### 编码示例

```verilog
// WLOAD: .insn r 0x0b, 0, 0, x0, rs1, rs2
//   opcode=0x0b (custom0), funct7=0, xs1=1, xs2=1, xd=0

// DLOAD: funct7=1

// COMP: funct7=2

// RSTAT: funct7=3, xd=1, rd=目标寄存器

// CLEAR: funct7=4
```

---

## 2.6 E203 集成位置

官方 NICE 集成文件:
- `e203_hbirdv2/rtl/e203/core/e203_cpu.v` — CPU 顶层
- `e203_hbirdv2/rtl/e203/subsys/e203_subsys_nice_core.v` — NICE 集成层

**本项目集成方式**: SoC wrapper 级别，把 CNN NICE Core 作为外设挂载。

---

## 2.7 踩坑记录

| 问题 | 原因 | 解决 |
|------|------|------|
| `WLOAD` 不生效 | ISA 编码错误 | 使用 bits `[14:12]` 而不是 funct3 |
| `req_ready` 一直高 | 未设置 busy 信号 | 当计算进行时拉低 req_ready |
| RSTAT 返回 0 | 未等待计算完成 | COMP 后需等 rsp_valid |

---

*相关文档: `01_ARCHITECTURE.md`, `04_ISA_EXTENSION.md`, `03_PE_ARRAY.md`*
