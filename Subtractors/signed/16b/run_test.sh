#!/bin/bash

# Set file names
TOP_MODULE="testbench"
OUTPUT_FILE="test_output.vvp"

# Clean previous outputs
rm -f $OUTPUT_FILE

# Compile the Verilog files using Icarus Verilog
iverilog -g2012 -o $OUTPUT_FILE -s $TOP_MODULE sub_16bit_signed.v testbench.sv

# Run the simulation
vvp $OUTPUT_FILE
