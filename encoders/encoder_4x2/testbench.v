`timescale 1ns/1ps
 // <- include your 4x2 encoder

module tb_encoder_4x2;  // <- updated module name
    integer i;
    integer trials;
    integer result_file;
    integer failures = 0;
    reg [3:0] rand_input;
    reg [3:0] in;
    wire [1:0]  out;

    // Instantiate DUT
    encoder_4x2 uut (
        .in(in),
        .out(out)
    );

    // Task for valid input test
    task test_input;
        input [3:0] test_vector;
        input [1:0] expected_output;
        begin
            in = test_vector;
            #1;
            if (out !== expected_output) begin
                $display("ERROR: Input = %4b | Expected = %2b | Got = %2b", test_vector, expected_output, out);
                failures = failures + 1;
            end else begin
                $display("PASS : Input = %4b | Output = %2b", test_vector, out);
            end
        end
    endtask

    // Task for invalid input test
    task test_invalid_input;
        input [3:0] test_vector;
        begin
            in = test_vector;
            #1;
            if (out !== 2'bxx) begin
                $display("FAIL : Invalid Input = %4b | Expected = xx | Got = %2b", test_vector, out);
                 failures = failures + 1;
            end else begin
                $display("PASS : Invalid Input = %4b | Output = %2b | Correctly got xx", test_vector , out);
            end
        end
    endtask

    // Function to count number of 1's in input
    function integer count_ones;
        input [3:0] value;
        integer j;
        begin
            count_ones = 0;
            for (j = 0; j < 4; j = j + 1)
                if (value[j])
                    count_ones = count_ones + 1;
        end
    endfunction

    initial begin
        $display("==== Begin 4x2 Encoder Testbench ====");

        // Test all valid one-hot inputs
        for (i = 0; i < 4; i = i + 1) begin
            test_input(4'b1 << i, i[1:0]);
        end

        $display("==== Valid one-hot tests passed. Beginning invalid input tests... ====");

        // Random invalid test cases
        trials = 0;

        while (trials < 7) begin
            rand_input = $random & 4'b1111;  // generate random 4-bit value

            if (count_ones(rand_input) > 1) begin
                test_invalid_input(rand_input);
                trials = trials + 1;
            end
            // else skip if 0 or single-bit
        end

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
