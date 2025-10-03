# File: Makefile (PPA-only demo)

# --- Files ---
SRC          := sub_16bit_signed.v
TB           := testbench.v
OUT          := test_result.txt
BIN          := sim.out
SYNTH_OUT    := synthesized.v
YOSYS_SCRIPT := yosys_script.ys
PPA_TXT      := PPA_summary.txt

# --- OpenLane locations ---
OPENLANE_ROOT ?= /home/marwan/OpenLane
PDK_ROOT       ?= /home/marwan/.ciel
DESIGN         := sub_16bit_signed
OL_DESIGN_DIR  := $(OPENLANE_ROOT)/designs/$(DESIGN)

# ---------- Default ----------
.PHONY: all
all: simulate synthesize openlane_pnr ppa_summary

# 1) Simulation
.PHONY: simulate
simulate:
	@echo "==> Running simulation..."
	iverilog -o $(BIN) $(SRC) $(TB)
	@vvp $(BIN)

# 2) Synthesis (only if PASS detected)
.PHONY: synthesize
synthesize:
	@if [ -f $(OUT) ] && grep -q PASS $(OUT); then \
		echo "==> PASS detected — synthesizing with Yosys..."; \
		echo "read_verilog $(SRC)" > $(YOSYS_SCRIPT); \
		echo "synth -top $(DESIGN)" >> $(YOSYS_SCRIPT); \
		echo "write_verilog $(SYNTH_OUT)" >> $(YOSYS_SCRIPT); \
		yosys -s $(YOSYS_SCRIPT); \
	else \
		echo "==> FAIL or no $(OUT) — skipping synthesis."; \
		exit 1; \
	fi

# 3) Prepare OpenLane config.json
$(OL_DESIGN_DIR)/config.json: $(SRC)
	@mkdir -p $(OL_DESIGN_DIR)/src
	@cp -f $(SRC) $(OL_DESIGN_DIR)/src/
	@echo "==> Writing config.json"
	@printf '{\n'                                     >  $(OL_DESIGN_DIR)/config.json
	@printf '  "DESIGN_NAME": "%s",\n' $(DESIGN)     >> $(OL_DESIGN_DIR)/config.json
	@printf '  "VERILOG_FILES": "dir::src/*.v",\n'   >> $(OL_DESIGN_DIR)/config.json
	@printf '  "CLOCK_PORT": "clk",\n'               >> $(OL_DESIGN_DIR)/config.json
	@printf '  "CLOCK_PERIOD": 10.0\n'               >> $(OL_DESIGN_DIR)/config.json
	@printf '}\n'                                     >> $(OL_DESIGN_DIR)/config.json

# 4) Run OpenLane flow (always via Docker)
.PHONY: openlane_pnr
openlane_pnr: $(OL_DESIGN_DIR)/config.json
	@echo "==> Running OpenLane flow (via Docker)..."
	docker run --rm \
	  -v $(OPENLANE_ROOT):/openlane \
	  -v $(PDK_ROOT):/pdks \
	  -e PDK_ROOT=/pdks -e PDK=sky130A \
	  --user $$(id -u):$$(id -g) \
	  -ti ghcr.io/the-openroad-project/openlane:latest \
	  ./flow.tcl -design $(DESIGN) -overwrite

# 5) Summarize PPA results into text file
.PHONY: ppa_summary
ppa_summary:
	@echo "==> Collecting PPA into $(PPA_TXT) ..."
	@LAST_RUN=$$(ls -td $(OL_DESIGN_DIR)/runs/* 2>/dev/null | head -1); \
	if [ -z "$$LAST_RUN" ]; then echo "No OpenLane run found." && exit 3; fi; \
	echo "OpenLane run: $$LAST_RUN" > $(PPA_TXT); \
	echo "\n[AREA]"              >> $(PPA_TXT); \
	grep -E "Chip area|Number of cells" "$$LAST_RUN/reports/synthesis/"*AREA*.rpt >> $(PPA_TXT) || true; \
	echo "\n[TIMING]"            >> $(PPA_TXT); \
	grep -iE "WNS|TNS|setup|hold|slack" "$$LAST_RUN/reports/signoff/31-rcx_sta.summary.rpt" >> $(PPA_TXT) || true; \
	echo "\n[POWER]"             >> $(PPA_TXT); \
	grep -E "Group|Total"        "$$LAST_RUN/reports/signoff/31-rcx_sta.power.rpt" >> $(PPA_TXT) || true; \
	echo "\n[SKEW]"              >> $(PPA_TXT); \
	cat "$$LAST_RUN/reports/signoff/31-rcx_sta.skew.rpt" >> $(PPA_TXT) || true; \
	echo "\n[metrics.csv]"       >> $(PPA_TXT); \
	tail -n +1 "$$LAST_RUN/reports/metrics.csv" >> $(PPA_TXT) || true; \
	echo "==> Wrote $(PPA_TXT)"

# Cleanup
.PHONY: clean
clean:
	rm -f $(BIN) $(OUT) $(SYNTH_OUT) $(YOSYS_SCRIPT) $(PPA_TXT) lec.log
