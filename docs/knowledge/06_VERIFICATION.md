# 验证方案

> 版本: 1.0 | 更新: 2026-03-26

---

## 6.1 验证层次

| 层次 | 验证对象 | 工具 |
|------|---------|------|
| **算法级** | Python/C 模型 | Python, C |
| **模块级** | PE, PE Array | Verilog sim |
| **集成级** | NICE 接口 | Mock CPU TB |
| **系统级** | 完整 SoC | iverilog + SDK |

---

## 6.2 模块级验证: Mock CPU TB

**目的**: 不依赖完整 E203，单独验证 CNN NICE Core 功能。

```verilog
// tb_cpu_mock.v 测试场景

// 场景 1: 正常路径
CLEAR();
// 循环加载 4 列权重
for (i=0; i<4; i++) WLOAD(weight_data[i], i);
// 循环加载 4 行激活
for (i=0; i<4; i++) DLOAD(act_data[i], i);
COMP();
RSTAT(result);  // 期望: 320

// 场景 2: 负数输入
// 测试有符号 INT8 负数乘法

// 场景 3: 边界值
// 边界 INT8: -128, 127

// 场景 4: 未加载就 COMP
// 期望: 返回 0 或错误

// 场景 5: RSTAT 在 COMP 前
// 期望: 返回 0

// 场景 6: 复位清零
// 复位后检查累加器为 0
```

---

## 6.3 仿真运行

```bash
# 生成参考模型
./Project_Manager.sh gen_model

# 运行 RTL 仿真
./Project_Manager.sh run_hw

# 预板级验证
bash scripts/run_preboard_verification.sh

# SDK 全系统回归
bash scripts/run_sdk_fullsoc_regression.sh
```

---

## 6.4 验证矩阵

| 功能 | CLEAR | WLOAD | DLOAD | COMP | RSTAT |
|------|:-----:|:-----:|:-----:|:----:|:-----:|
| 正常路径 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 负数输入 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 边界值 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 未加载 COMP | - | - | - | ✅ | - |
| COMP 前 RSTAT | - | - | - | - | ✅ |
| busy 时请求 | - | - | - | ✅ | - |
| 复位清零 | ✅ | - | - | - | - |

---

## 6.5 回归测试

**目的**: 确保每次修改不引入新 bug。

```bash
# 每次代码修改后运行
bash scripts/run_preboard_verification.sh

# 回归标准: 所有测试 PASS，RSTAT=320
```

---

## 6.6 已知限制

| 项目 | 说明 |
|------|------|
| FTDI/JTAG | 未连接硬件，仿真通过即可 |
| UART | 仿真时不验证串口输出 |
| FPGA 实测 | 待板级 bring-up |

---

*相关文档: `07_SIM_RUN.md`, `20_ISSUES.md`*
