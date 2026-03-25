# RISC-V CNN 加速器 Week 5-6 工作汇报

> **Version**: V1.9 | **Updated**: 2026-03-26 | **Owner**: Justin JU

**汇报时长：约5-6分钟**

---

## 开场 (约30秒)

大家好，我是Justin。今天汇报Week 5-6阶段的工作进展。

这个阶段的核心任务是：将CNN加速器集成到官方Hummingbird E203 SoC中，完成全系统仿真验证。

---

## 一、本阶段工作内容 (约2分钟)

**第一，E203 NICE接口集成。**

我们将加速器集成到官方e203_hbirdv2 SoC代码库。过程中修正了一个关键问题：E203的NICE接口使用funct7而非funct3来区分自定义指令。修正后版本从V1.4升级到V1.5。

**第二，Nuclei工具链配置。**

安装了GNU toolchain 2024.06，成功编译SDK应用程序cnn_accel_demo，生成ITCM和DTCM内存镜像。

**第三，全SoC仿真验证。**

这是最关键的验证：让软件在真实E203处理器上，通过SDK驱动执行完整指令序列——CLEAR、WLOAD、DLOAD、COMP、RSTAT。仿真结果RSTAT=320，完美通过。

**第四，Phase 4工程恢复。**

导出SDK delta补丁，编写一键回归脚本，确保后续协作和环境恢复。

**第五，Phase 5板级准备。**

锁定FPGA目标板为evalsoc+nuclei_fpga_eval，安装OpenOCD，编写板级环境检查脚本。

---

## 二、核心成果 (约1分钟)

关键指标：

- **RSTAT=320**：E203全SoC仿真中，accelerator执行16个INT8 MAC的最终结果
- **版本V1.7**：接口安全验证全部完成
- **5个Phase闭环**：Phase 1-5全部完成
- **Pre-board 100%验证通过**

已通过的验证项：
- 接口安全：非法Opcode、非法Funct7、无效索引、复位清除状态
- 协议合规：Busy时阻塞、重复RSTAT、partial load后COMP
- 软件验证：CLEAR到RSTAT全流程
- 三层仿真覆盖：Local RTL、Official lightweight、Full-SoC

---

## 三、系统架构 (约1分钟)

系统分为四层：
1. **E203 RISC-V**：Hummingbird开源处理器核，NICE接口连接协处理器
2. **NICE Interface**：自定义指令扩展，Opcode 0x0b，funct7编码
3. **CNN Accelerator**：4x4 PE阵列，INT8量化，Output Stationary
4. **Software SDK**：Nuclei SDK提供完整软件驱动

---

## 四、当前状态 (约1分钟)

**已完成：**
- 全SoC仿真 RSTAT=320 ✓
- 接口安全验证 ✓
- SDK软件路径 ✓
- Pre-board预验证 ✓

**待确定：**
- FPGA目标板选择：mcu200t还是ddr200t
- JTAG/FTDI硬件连接
- UART串口路径

确定FPGA目标板后，即可进入硬件验证阶段。

---

## 结束 (约30秒)

以上是Week 5-6的工作汇报。所有软件仿真验证已完成，理论上加速器可在真实硬件上工作。

下一步重点：硬件板级验证。

谢谢大家，欢迎提问。

---

## 附录：关键文件

- 集成文档：E203_FORMAL_INTEGRATION.md
- FPGA交付：VIVADO_FPGA_HANDOFF.md
- 工程恢复：PHASE4_RECOVERY.md
- 板级准备：PHASE5_BOARD_PREP.md
- 验证脚本：run_preboard_verification.sh