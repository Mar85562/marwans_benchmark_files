`timescale 1ns / 1ps

module tb_decoder_4x16;
    integer i;
    integer failures = 0;
    integer result_file;
    reg [3:0] rand_in;
    reg [15:0] expected;

    // Inputs to the DUT
    reg  [3:0] in;

    // Outputs from the DUT
    wire [15:0] out;

    // Instantiate the DUT
    decoder_4x16 dut (
        .in(in),
        .out(out)
    );

    // Task to check output correctness
    task check_output;
        input [3:0] in_val;
        input [15:0] expected_out;

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
        $display("==== Starting testbench for decoder_4x16 ====");

        // Test all valid input combinations (sanity check)
        check_output(4'b0000, 16'b0000_0000_0000_0001);
        check_output(4'b0001, 16'b0000_0000_0000_0010);
        check_output(4'b0010, 16'b0000_0000_0000_0100);
        check_output(4'b0011, 16'b0000_0000_0000_1000);
        check_output(4'b0100, 16'b0000_0000_0001_0000);
        check_output(4'b0101, 16'b0000_0000_0010_0000);
        check_output(4'b0110, 16'b0000_0000_0100_0000);
        check_output(4'b0111, 16'b0000_0000_1000_0000);
        check_output(4'b1000, 16'b0000_0001_0000_0000);
        check_output(4'b1001, 16'b0000_0010_0000_0000);
        check_output(4'b1010, 16'b0000_0100_0000_0000);
        check_output(4'b1011, 16'b0000_1000_0000_0000);
        check_output(4'b1100, 16'b0001_0000_0000_0000);
        check_output(4'b1101, 16'b0010_0000_0000_0000);
        check_output(4'b1110, 16'b0100_0000_0000_0000);
        check_output(4'b1111, 16'b1000_0000_0000_0000);

        // Randomized test loop (30 runs)
        for (i = 0; i < 30; i = i + 1) begin
            rand_in = $random % 16;  // Generates value from 0 to 15 (4-bit)
            case (rand_in)
                4'b0000: expected = 16'b0000_0000_0000_0001;
                4'b0001: expected = 16'b0000_0000_0000_0010;
                4'b0010: expected = 16'b0000_0000_0000_0100;
                4'b0011: expected = 16'b0000_0000_0000_1000;
                4'b0100: expected = 16'b0000_0000_0001_0000;
                4'b0101: expected = 16'b0000_0000_0010_0000;
                4'b0110: expected = 16'b0000_0000_0100_0000;
                4'b0111: expected = 16'b0000_0000_1000_0000;
                4'b1000: expected = 16'b0000_0001_0000_0000;
                4'b1001: expected = 16'b0000_0010_0000_0000;
                4'b1010: expected = 16'b0000_0100_0000_0000;
                4'b1011: expected = 16'b0000_1000_0000_0000;
                4'b1100: expected = 16'b0001_0000_0000_0000;
                4'b1101: expected = 16'b0010_0000_0000_0000;
                4'b1110: expected = 16'b0100_0000_0000_0000;
                4'b1111: expected = 16'b1000_0000_0000_0000;
            endcase
            check_output(rand_in, expected);
        end

        // Try some invalid inputs
        $display("==== Testing invalid inputs ====");
        check_output(4'bx001, 16'bxxxxxxxxxxxxxxxx);
        check_output(4'bxxxx, 16'bxxxxxxxxxxxxxxxx);
        check_output(4'bz010, 16'bxxxxxxxxxxxxxxxx);
        check_output(4'bzzzz, 16'bxxxxxxxxxxxxxxxx);
       result_file = $fopen("test_result.txt", "w");
   
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
