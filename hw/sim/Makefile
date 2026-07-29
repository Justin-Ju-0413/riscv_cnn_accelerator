# 目录定义
RTL_DIR = ../rtl/acc
TB_DIR  = ../tb

# 源文件定义
RTL_SRC = $(RTL_DIR)/pe.v $(RTL_DIR)/pe_array.v $(RTL_DIR)/cnn_nice_core.v $(RTL_DIR)/nice_controller.v
TB_SRC  = $(TB_DIR)/e203_nice_harness.v $(TB_DIR)/tb_cpu_mock.v
TB_V2_SRC = $(TB_DIR)/e203_nice_memory_harness.v $(TB_DIR)/tb_nice_v2_memory.v

# 仿真目标文件
TARGET  = sim.out
TARGET_V2 = sim_v2.out
VCD_FILE= demo.vcd
VCD_V2_FILE = nice_v2_memory.vcd

all: clean compile run

compile:
	@echo ">>> 正在编译 Verilog 源码..."
	iverilog -o $(TARGET) $(RTL_SRC) $(TB_SRC)

run: compile
	@echo ">>> 正在运行仿真..."
	vvp $(TARGET)

compile_v2:
	@echo ">>> 正在编译 NICE v2 memory-path 仿真..."
	iverilog -o $(TARGET_V2) $(RTL_SRC) $(TB_V2_SRC)

run_v2: compile_v2
	@echo ">>> 正在运行 NICE v2 memory-path 仿真..."
	vvp $(TARGET_V2)

wave:
	@echo ">>> 正在打开波形图..."
	gtkwave $(VCD_FILE) &

wave_v2:
	@echo ">>> 正在打开 NICE v2 memory-path 波形图..."
	gtkwave $(VCD_V2_FILE) &

clean:
	@echo ">>> 清理历史构建文件..."
	rm -f *.out *.vcd
