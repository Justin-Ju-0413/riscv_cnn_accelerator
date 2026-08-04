# 仿真运行指南

> 版本: 1.0 | 更新: 2026-03-26

---

## 7.1 快速开始

```bash
# 进入项目目录
cd <repo-root>

# 1. 生成参考模型（如果需要重新生成测试向量）
./Project_Manager.sh gen_model

# 2. 运行 RTL 仿真
./Project_Manager.sh run_hw

# 3. 查看波形
make wave
```

---

## 7.2 仿真输出说明

仿真成功后关键输出：

```
=== CNN NICE Core Verification ===
CLEAR   ... PASS
WLOAD   ... PASS (cycle 5)
DLOAD   ... PASS (cycle 9)
COMP    ... PASS (cycle 10)
RSTAT   ... PASS (result=320)
```

**RSTAT=320** 是参考模型的正确输出，表示 4×4 矩阵乘法结果。

---

## 7.3 目录结构

```
hw/
├── rtl/          # 设计源码
│   ├── acc/      # CNN 加速器模块
│   └── soc_wrapper/  # SoC 顶层
├── tb/           # Testbench
└── sim/          # 仿真工作目录 (work/)

sw/
├── firmware/     # 固件源码
├── inc/          # 头文件
└── build/        # 编译输出

scripts/
├── run_preboard_verification.sh
└── run_sdk_fullsoc_regression.sh
```

---

## 7.4 波形的查看

```bash
# 用 gtkwave 查看
gtkwave hw/sim/vcd_dump.vcd &
```

**关键信号**:

| 信号 | 说明 |
|------|------|
| `nice_req_valid` | 请求有效 |
| `nice_req_instr[31:0]` | 指令编码 |
| `nice_req_rs1/rs2` | 操作数 |
| `nice_rsp_valid` | 响应有效 |
| `nice_rsp_data` | 计算结果 |

---

## 7.5 常见仿真问题

| 问题 | 解决 |
|------|------|
| `iverilog: command not found` | 安装: `apt install iverilog` |
| `vvp: command not found` | 安装: `apt install vvp` |
| 编译错误 | 检查 `iverilog` 版本，需 12.0+ |
| 无波形 | 检查 VCD dump 是否启用 |

---

*相关文档: `06_VERIFICATION.md`*
