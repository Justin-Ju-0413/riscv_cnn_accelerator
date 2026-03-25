# Work Delivery Summary

> **Version**: V1.8 | **Updated**: 2026-03-26 | **Owner**: Justin JU

## 当前阶段总结

**分支**: `bringup_v1`

当前项目已经从“16-lane INT8 点积 NICE demo”推进到“最小 CNN v1 可验证基线”：

- E203/NICE 正式集成闭合
- 软件侧已支持固定 `4x4 input + 3x3 kernel + 2x2 output`
- `conv + ReLU` 已可通过现有 NICE 指令序列完成
- CPU-only 与 accelerator cycle 对比链路已接入
- 板前验证与上板入口脚本已经收口

## 已完成范围

### RTL 与接口

- 16-lane INT8 NICE 计算核心稳定
- `CLEAR/WLOAD/DLOAD/COMP/RSTAT` 指令路径稳定
- 新增 `CFG` 指令，可配置硬件 ReLU
- 本地接口安全回归覆盖：复位、非法指令、非法索引、busy、重复 `RSTAT`

### 软件与 SoC

- 软件驱动已统一到最小 CNN v1 路径
- SDK app / firmware / nuclei app 三个入口已经统一
- Python golden、C reference、SoC 侧 demo 数据已对齐
- CPU-only 与 accelerator benchmark 已接入统一打印

### 板前自动化

- `pre_sdk_check` 已兼容文档归档后的新路径
- full-SoC 回归已适配更长的 CNN/benchmark 输出
- `check_phase5_board_env.sh` 已覆盖 FPGA shell、XDC、Vivado 和 JTAG/UART 前提
- 已新增首次上板命令清单脚本 `print_fpga_bringup_commands.sh`

## 当前验证结论

已实际通过：

- `./Project_Manager.sh run_hw`
- `bash scripts/run_sdk_fullsoc_regression.sh`
- `bash scripts/run_preboard_verification.sh`
- `bash scripts/check_phase5_board_env.sh`

当前 full-SoC 最小 CNN v1 结果：

- 四次 tile 计算的最终 `expected_rstat = 19`
- 软件和硬件路径均已跑通 `conv + ReLU`

## 当前剩余差距

当前不再卡在 RTL/SoC 功能，而是卡在真实 FPGA 板级条件：

- `vivado` 还未在当前机器上就绪
- FTDI/JTAG 设备尚未检测到
- `SERIAL_DEV` 尚未锁定
- 真实板卡仍未最终确认
- 尚未生成真实 bitstream 并完成 JTAG/UART 上板闭环

## 默认上板入口

当前默认收敛策略：

- 软件目标：`SOC=evalsoc BOARD=nuclei_fpga_eval CORE=n300 DOWNLOAD=ilm`
- 默认 FPGA shell：`FPGA_NAME=mcu200t`
- 首次下载路径：`OpenOCD + GDB + load ELF`

推荐入口：

- `bash scripts/check_phase5_board_env.sh`
- `bash scripts/print_fpga_bringup_commands.sh`

## 下一步

1. 锁定真实板卡与 `FPGA_NAME`
2. 准备 Vivado 环境
3. 生成第一版 bitstream
4. 通过 OpenOCD/GDB 下载 `cnn_accel_demo.elf`
5. 用 UART 观察最小 CNN v1 输出和 benchmark

*本文档应与 `CURRENT_STATE.md`、`PHASE5_BOARD_PREP.md` 和 `VIVADO_FPGA_HANDOFF.md` 配合阅读。*
