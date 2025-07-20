# File: Makefile

# File names
SRC = sub_8bit_signed.v # Change this to your design file.
TB  = testbench.sv
OUT = test_result.txt
BIN = sim.out
SYNTH_OUT = synthesized.v
YOSYS_SCRIPT = yosys_script.ys

# Default target
all: simulate synthesize

# 1. Compile and run testbench
simulate:
	@echo "Running simulation..."
	iverilog -o $(BIN) $(SRC) $(TB)
	@vvp $(BIN)

# 2. Check for PASS in test_result.txt and synthesize
synthesize:
	@if [ -f $(OUT) ] && grep -q PASS $(OUT); then \
		echo "PASS detected — synthesizing with Yosys..."; \
		echo "read_verilog $(SRC)" > $(YOSYS_SCRIPT); \
		echo "proc; opt; fsm; memory; opt; techmap; opt" >> $(YOSYS_SCRIPT); \
		echo "synth -top sub_8bit_signed" >> $(YOSYS_SCRIPT); \
		echo "write_verilog $(SYNTH_OUT)" >> $(YOSYS_SCRIPT); \
		yosys -s $(YOSYS_SCRIPT); \
	else \
		echo "FAIL detected or no test result — skipping synthesis."; \
	fi

# Clean everything
clean:
	rm -f $(BIN) $(OUT) $(SYNTH_OUT) $(YOSYS_SCRIPT)

