`timescale 1ns/1ps

module tb_encoder_16x4;
    integer i;
    integer failures = 0;
    integer result_file;
    integer trials;
    reg [15:0] rand_input;
    reg [15:0] in;
    wire [3:0]  out;

    // Instantiate DUT
    encoder_16x4 uut (
        .in(in),
        .out(out)
    );

    // Task for valid input test
    task test_input;
        input [15:0] test_vector;
        input [3:0] expected_output;
        begin
            in = test_vector;
            #1;
            if (out !== expected_output) begin
                $display("ERROR: Input = %016b | Expected = %04b | Got = %04b", test_vector, expected_output, out);
                failures = failures + 1;
            end else begin
                $display("PASS : Input = %016b | Output = %04b", test_vector, out);
            end
        end
    endtask

    // Task for invalid input test
    task test_invalid_input;
        input [15:0] test_vector;
        begin
            in = test_vector;
            #1;
            if (out !== 4'bxxxx) begin
                $display("FAIL : Invalid Input = %016b | Expected = xxxx | Got = %04b", test_vector, out);
                failures = failures + 1;
            end else begin
                $display("PASS : Invalid Input = %016b | Correctly got xxxx", test_vector);
            end
        end
    endtask

    // Function to count number of 1's in input
    function integer count_ones;
        input [15:0] value;
        integer j;
        begin
            count_ones = 0;
            for (j = 0; j < 16; j = j + 1)
                if (value[j])
                    count_ones = count_ones + 1;
        end
    endfunction

    initial begin
        $display("==== Begin 16x4 Encoder Testbench ====");

        // Test all valid one-hot inputs
        for (i = 0; i < 16; i = i + 1) begin
            test_input(16'b1 << i, i[3:0]);
        end

        $display("==== Valid one-hot tests passed. Beginning invalid input tests... ====");

        // Random invalid test cases
      
        trials = 0;
       
        while (trials < 100) begin
            rand_input = $random; // 16-bit random value
            rand_input = rand_input & 16'hFFFF; // mask to 16-bit

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
