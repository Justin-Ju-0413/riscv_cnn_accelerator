# 目录定义
RTL_DIR = ../rtl/acc
TB_DIR  = ../tb

# 源文件定义
RTL_SRC = $(RTL_DIR)/pe.v $(RTL_DIR)/pe_array.v $(RTL_DIR)/nice_controller.v
TB_SRC  = $(TB_DIR)/tb_cpu_mock.v

# 仿真目标文件
TARGET  = sim.out
VCD_FILE= demo.vcd

all: clean compile run wave

compile:
	@echo ">>> 正在编译 Verilog 源码..."
	iverilog -o $(TARGET) $(RTL_SRC) $(TB_SRC)

run:
	@echo ">>> 正在运行仿真..."
	vvp $(TARGET)

wave:
	@echo ">>> 正在打开波形图..."
	gtkwave $(VCD_FILE) &

clean:
	@echo ">>> 清理历史构建文件..."
	rm -f *.out *.vcd
