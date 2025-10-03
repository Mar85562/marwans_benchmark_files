`timescale 1ns / 1ps

module tb_decoder_3x8;
    integer i;
    integer result_file;
    integer failures = 0;
    reg [2:0] rand_in;
    reg [7:0] expected;

    // Inputs to the DUT
    reg  [2:0] in;

    // Outputs from the DUT
    wire [7:0] out;

    // Instantiate the DUT
    decoder_3x8 dut (
        .in(in),
        .out(out)
    );

    // Task to check output correctness
    task check_output;
        input [2:0] in_val;
        input [7:0] expected_out;

        begin
            in = in_val;
            #1; // small delay to allow output to settle

            if (out !== expected_out) begin
                $display("ERROR: Input = %b | Expected = %b | Got = %b", in, expected_out, out);
                failures = failures + 1; 
            end else begin
                $display("PASS: Input = %b | Output = %b", in, out);
            end
        end
    endtask

    initial begin
        $display("==== Starting testbench for decoder_3x8 ====");

        // Test all valid input combinations (sanity check)
        check_output(3'b000, 8'b0000_0001);
        check_output(3'b001, 8'b0000_0010);
        check_output(3'b010, 8'b0000_0100);
        check_output(3'b011, 8'b0000_1000);
        check_output(3'b100, 8'b0001_0000);
        check_output(3'b101, 8'b0010_0000);
        check_output(3'b110, 8'b0100_0000);
        check_output(3'b111, 8'b1000_0000);

        // Randomized test loop (15 runs)
        for (i = 0; i < 30; i = i + 1) begin
            rand_in = $random % 8;  // Generates value from 0 to 7 (3-bit)
            case (rand_in)
                3'b000: expected = 8'b0000_0001;
                3'b001: expected = 8'b0000_0010;
                3'b010: expected = 8'b0000_0100;
                3'b011: expected = 8'b0000_1000;
                3'b100: expected = 8'b0001_0000;
                3'b101: expected = 8'b0010_0000;
                3'b110: expected = 8'b0100_0000;
                3'b111: expected = 8'b1000_0000;
            endcase
            check_output(rand_in, expected);
        end

        // Try some invalid inputs
        $display("==== Testing invalid inputs ====");
        check_output(3'bx00, 8'bxxxxxxxx);
        check_output(3'bxxx, 8'bxxxxxxxx);
        check_output(3'bz01, 8'bxxxxxxxx);
        check_output(3'bzzz, 8'bxxxxxxxx);

        result_file = $fopen("test_result.txt", "w");
    if (failures == 0) begin
        $display("==== All tests passed! ====");
        $fdisplay(result_file, "PASS");
    end else begin
        $display("==== Some tests failed! Total failures: %0d ====", failures);
        $fdisplay(result_file, "FAIL");
    end
    $fclose(result_file);
    $finish;
    end

endmodule
