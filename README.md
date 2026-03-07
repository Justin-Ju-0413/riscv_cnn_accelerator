# Lightweight CNN Accelerator Based on RISC-V Custom Instructions
基于 RISC-V (Hummingbird E203) 自定义指令的轻量级 CNN 加速器软硬协同设计。

## 目录结构说明
* `algo/`: 算法模型与 INT8 量化脚本 (Python & C)
* `hw/`: 硬件设计 (Verilog RTL) 与 Testbench 测试激励
* `sw/`: RISC-V C语言固件与内联汇编自定义指令
* `fpga/`: Vivado 工程、管脚约束与上板脚本
* `doc/`: 项目相关文档与汇报 PPT

## 快速仿真指南
进入 `hw/sim/` 目录，执行 `make` 即可一键编译并查看波形。
