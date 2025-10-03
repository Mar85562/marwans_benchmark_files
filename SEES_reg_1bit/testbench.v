`timescale 1ns / 1ps

module tb_register_1bit;

    // Testbench signals
    reg clk;
    reg rst;
    reg d;
    wire q;

    // Expected output for checker
    reg expected_q;
    integer result_file;
    integer failures = 0;
    integer test_num;

    // Instantiate the register_1bit module
    register_1bit uut (
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

    // Checker task to verify output against expected_q
    task check_output;
      input integer test_num;
      input reg expected_q;
      begin
        #1; // Allow signals to settle
        if (q !== expected_q) begin
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
        d = 0;
        expected_q = 0;
        test_num = 0;
        failures = 0;

        // Open the result file
        result_file = $fopen("test_result.txt", "w");
        if (result_file == 0) begin
            $display("ERROR: Could not open file test_result.txt");
            $finish;
        end

        // Wait a little before starting
        #10;

        // Apply random values to d and rst for 20 clock cycles
        repeat (20) begin
            @(negedge clk); // Change inputs on falling edge
            
            // Randomize d and rst (rst asserted with ~10% chance)
            d = $random % 2;
            rst = ($random % 10 == 0) ? 1'b1 : 1'b0;

            // Calculate expected output based on behavior on next clock edge
            expected_q = (rst) ? 1'b0 : d;

            test_num = test_num + 1;

            @(posedge clk); // Wait for rising clock edge where q updates

            // Check output
            check_output(test_num, expected_q);
        end

        // Write summary to file
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
