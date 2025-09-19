`timescale 1ns / 1ps

module tb_decoder_2x4;
    integer i;
    integer result_file;
    integer failures = 0;
    reg [1:0] rand_in;
    reg [3:0] expected;
    // Inputs to the DUT
    reg  [1:0] in;

    // Outputs from the DUT
    wire [3:0] out;

    // Instantiate the DUT
    decoder_2x4 dut (
        .in(in),
        .out(out)
    );

    // Task to check output correctness
    task check_output;
        input [1:0] in_val;
        input [3:0] expected_out;

        begin
            in = in_val;
            #1; // small delay to allow output to settle

            if (out !== expected_out) begin
                $display("ERROR: Input = %b | Expected = %b | Got = %b", in, expected_out, out);
                 failures = failures + 1; 
            end else begin
                $display("PASS:   Input = %b | Output = %b", in, out);
            end
        end
    endtask

    initial begin
        $display("==== Starting testbench for decoder_2x4 ====");

        // Test all valid input combinations (sanity check)
        check_output(2'b00, 4'b0001);
        check_output(2'b01, 4'b0010);
        check_output(2'b10, 4'b0100);
        check_output(2'b11, 4'b1000);

        // Randomized test loop (15 runs)
        for (i = 0; i < 15; i = i + 1) begin
            rand_in = $random % 4;  // Generates value from 0 to 3 (2-bit)
            case (rand_in)
                2'b00: expected = 4'b0001;
                2'b01: expected = 4'b0010;
                2'b10: expected = 4'b0100;
                2'b11: expected = 4'b1000;
            endcase
            check_output(rand_in, expected);
        end

        //try an invalid input.
        $display("==== Testing an invalid input ====");
        check_output(2'bx0, 4'bxxxx);
        check_output(2'bxx, 4'bxxxx);
        check_output(2'bz0, 4'bxxxx);
        check_output(2'bzz, 4'bxxxx);
  


    // Write test result to file
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