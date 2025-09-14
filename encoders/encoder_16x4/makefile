# File: Makefile

# File names
SRC = encoder_16x4.v # Change this to your design file.
TB  = testbench.v
OUT = test_result.txt
BIN = sim.out
SYNTH_OUT = synthesized.v
YOSYS_SCRIPT = synth.ys

# Default target
all: simulate synthesize

# 1. Compile and run testbench
simulate:
	@echo "Running simulation..."
	iverilog -o $(BIN) $(SRC) $(TB)
	@vvp $(BIN)

# 2. Check for PASS in test_result.txt and synthesize
# Change your design name in the Yosys script below 
synthesize:
	@if [ -f $(OUT) ] && grep -q PASS $(OUT); then \
		echo "PASS detected — synthesizing with Yosys..."; \
		echo "read_verilog $(SRC)" > $(YOSYS_SCRIPT); \
		echo "proc; opt; fsm; memory; opt; techmap; opt" >> $(YOSYS_SCRIPT); \
		echo "synth -top encoder_16x4" >> $(YOSYS_SCRIPT); \
		echo "write_verilog $(SYNTH_OUT)" >> $(YOSYS_SCRIPT); \
		yosys -s $(YOSYS_SCRIPT); \
	else \
		echo "FAIL detected or no test result — skipping synthesis."; \
	fi

# Clean everything
clean:
	rm -f $(BIN) $(OUT) $(SYNTH_OUT) $(YOSYS_SCRIPT)

