# SoC 集成指南

> 版本: 1.0 | 更新: 2026-03-26

---

## 5.1 集成层次

```
┌─────────────────────────────────────────┐
│           top.v (FPGA Top)              │
│  ┌───────────────────────────────────┐  │
│  │        soc_wrapper.v              │  │
│  │  ┌─────────────┐  ┌────────────┐ │  │
│  │  │ e203_core    │  │ cnn_nice   │ │  │
│  │  │ .v           │  │ _core.v    │ │  │
│  │  └─────────────┘  └────────────┘ │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## 5.2 NICE 接口连接

```verilog
// soc_wrapper.v (关键信号连接)

wire        nice_req_valid;
wire        nice_req_ready;
wire [31:0] nice_req_instr;
wire [31:0] nice_req_rs1;
wire [31:0] nice_req_rs2;

wire        nice_rsp_valid;
wire        nice_rsp_ready;
wire [31:0] nice_rsp_data;

// E203 → CNN
assign nice_req_valid  = dut.u_e203.u_e203_cpu.nice_req_valid;
assign nice_req_instr  = dut.u_e203.u_e203_cpu.nice_req_instr;
assign nice_req_rs1   = dut.u_e203.u_e203_cpu.nice_req_rs1;
assign nice_req_rs2   = dut.u_e203.u_e203_cpu.nice_req_rs2;
assign nice_req_ready = u_cnn_accel.nice_req_ready;

// CNN → E203
assign u_cnn_accel.nice_rsp_valid = nice_rsp_valid;
assign u_cnn_accel.nice_rsp_data  = nice_rsp_data;
assign nice_rsp_ready = dut.u_e203.u_e203_cpu.nice_rsp_ready;

// 实例化 CNN 加速器
cnn_nice_core u_cnn_accel (
    .clk            (clk),
    .rst_n          (rst_n),
    .nice_req_valid (nice_req_valid),
    .nice_req_ready (nice_req_ready),
    .nice_req_instr (nice_req_instr),
    .nice_req_rs1   (nice_req_rs1),
    .nice_req_rs2   (nice_req_rs2),
    .nice_rsp_valid (nice_rsp_valid),
    .nice_rsp_ready (nice_rsp_ready),
    .nice_rsp_data  (nice_rsp_data)
);
```

---

## 5.3 关键配置

| 配置项 | 值 | 说明 |
|--------|---|------|
| `E203_CFG_HAS_NICE` | defined | 启用 NICE 接口 |
| `E203_CFG_HAS_ITCM` | defined | 指令存储 |
| `E203_CFG_HAS_DTCM` | defined | 数据存储 |
| NICE 内存请求 | disabled | 本项目不用存储通道 |

---

## 5.4 地址空间

| 外设 | 地址范围 | 说明 |
|------|---------|------|
| ITCM | 0x8000_0000 | 指令存储 |
| DTCM | 0x9000_0000 | 数据存储 |
| CLINT | 0x0200_0000 | 中断控制器 |
| PLIC | 0x0C00_0000 | 中断路由 |
| CNN Accel | NICE 接口调用 | 无独立地址 |

---

## 5.5 集成检查清单

- [ ] NICE 接口信号连接正确
- [ ] `E203_CFG_HAS_NICE` 已定义
- [ ] CNN 模块时钟门控正确
- [ ] 复位信号同步
- [ ] `nice_req_ready` 在 busy 时拉低
- [ ] `nice_rsp_valid` 保持到握手完成

---

## 5.6 常见集成问题

| 问题 | 原因 | 解决 |
|------|------|------|
| 无 NICE 请求 | `E203_CFG_HAS_NICE` 未定义 | 确认 config.v |
| 复位后死机 | CNN 模块未正确复位 | 检查 rst_n 信号 |
| 响应无回应 | `rsp_valid` 未连接 | 检查信号连接 |

---

*相关文档: `01_ARCHITECTURE.md`, `02_NICE_PROTOCOL.md`*
