`timescale 1ns / 1ps

module tb_register_16bit;

    // Testbench signals
    reg clk;
    reg rst;
    reg [15:0] d;
    wire [15:0] q;

    // Expected output for checker
    reg [15:0] expected_q;
    integer result_file;
    integer failures = 0;
    integer test_num;

    // Instantiate the register_16bit module
    register_16bit uut (
        .clk(clk),
        .rst(rst),
        .d(d),
        .q(q)
    );

    // Clock generation: 10 ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle every 5 ns
    end

    // Checker task to verify output against expected_q with unknown bit tolerance
    task check_output;
      input integer test_num;
      input reg [15:0] expected_q;
      reg [15:0] q_masked, expected_masked;
      begin
        #1; // Allow signals to settle

        // Mask out unknown bits to avoid false failure on X/Z
        q_masked = q & 16'hFFFF;
        expected_masked = expected_q & 16'hFFFF;

        if (q_masked !== expected_masked) begin
          $display("TEST %0d FAILED: clk=%b rst=%b d=%b q=%b (expected %b) @ time %0t",
                   test_num, clk, rst, d, q, expected_q, $time);
          failures = failures + 1;
        end else begin
          $display("TEST %0d PASSED: clk=%b rst=%b d=%b q=%b @ time %0t",
                   test_num, clk, rst, d, q, $time);
        end
      end
    endtask

    // Test stimulus and result reporting
    initial begin
        // Initialize inputs and expected output
        rst = 0;
        d = 16'h0000;
        expected_q = 16'h0000;
        test_num = 0;
        failures = 0;

        // Wait a little before starting
        #10;

        // Apply random values to d and rst for 20 clock cycles
        repeat (20) begin
            @(negedge clk); // Change inputs on falling edge
            
            // Randomize d and rst (fully random reset)
            d = $random;
            rst = $random % 2;

            // Calculate expected output based on behavior on next clock edge
            expected_q = (rst) ? 16'h0000 : d;

            test_num = test_num + 1;

            @(posedge clk); // Wait for rising clock edge where q updates

            // Check output
            check_output(test_num, expected_q);
        end

        // Write summary to file
        result_file = $fopen("test_result.txt", "w");
        if (result_file == 0) begin
            $display("ERROR: Could not open file test_result.txt");
            $finish;
        end
        if (failures == 0) begin
            $display("==== All tests passed! ====");
            $fdisplay(result_file, "PASS");
        end else begin
            $display("==== Some tests failed! Total failures: %0d ====", failures);
            $fdisplay(result_file, "FAIL");
        end

        $fclose(result_file);

        // Finish simulation
        #10;
        $finish;
    end

endmodule
