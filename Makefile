# RISC-V CNN Accelerator — Top-Level Makefile
# ==========================================
# Usage: make [target]
#
# Targets:
#   all          Build everything (model + RTL sim)
#   gen_model    Generate Python reference model
#   sim          Run RTL simulation
#   sim_debug    Run RTL sim with waveform
#   precheck     Run pre-SDK environment checks
#   index        Show project file tree
#   clean        Remove build artifacts

PROJECT_ROOT := $(shell pwd)

.PHONY: all gen_model sim sim_debug precheck index clean

all: gen_model sim

gen_model:
	@echo "==> Generating Python reference model..."
	@cd $(PROJECT_ROOT)/algo/python && python3 generate_model.py

sim:
	@echo "==> Running RTL simulation..."
	@cd $(PROJECT_ROOT)/hw/sim && make run

sim_debug:
	@echo "==> Running RTL simulation (with waveform)..."
	@cd $(PROJECT_ROOT)/hw/sim && make debug

precheck:
	@echo "==> Running pre-SDK checks..."
	@cd $(PROJECT_ROOT) && bash scripts/check_phase5_board_env.sh

index:
	@echo "Project Structure:"
	@find $(PROJECT_ROOT) -type f \
		-not -path '*/\.*' \
		-not -path '*/third_party/*' \
		-not -path '*/e203_hbirdv2/*' \
		-not -path '*/.git/*' \
		-not -path '*/__pycache__/*' \
		-not -name '*.o' \
		-not -name '*.vcd' \
		-not -name '*.out' \
		-not -name '*.elf' \
		-not -name '*.hex' \
		-not -name '*.srec' \
		-not -name '*.map' \
		-not -name '*.dump' \
		| sort | head -80

clean:
	@echo "==> Cleaning build artifacts..."
	@find $(PROJECT_ROOT) -type f \( \
		-name '*.o' -o -name '*.vcd' -o -name '*.out' \
		-o -name '*.d' -o -name '*.a' -o -name '*.so' \
		\) -not -path '*/.git/*' -not -path '*/third_party/*' \
		-exec rm -v {} \;
	@rm -rf $(PROJECT_ROOT)/hw/sim/build
	@rm -rf $(PROJECT_ROOT)/sw/sdk_project/build
	@echo "Done."
