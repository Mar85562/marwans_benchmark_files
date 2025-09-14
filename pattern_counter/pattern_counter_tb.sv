```systemverilog
`timescale 1ns / 1ps

module pattern_counter_tb;

    // Inputs
    logic clk;
    logic rst;
    logic bit_in;
    logic [3:0] pattern;
    logic enable;

    // Outputs
    logic [15:0] match_count;
    logic pattern_match;
    logic ready;

    // Instantiate DUT
    pattern_counter dut (
        .clk(clk),
        .rst(rst),
        .bit_in(bit_in),
        .pattern(pattern),
        .enable(enable),
        .match_count(match_count),
        .pattern_match(pattern_match),
        .ready(ready)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Task to apply reset
    task apply_reset();
        rst = 1;
        enable = 0;
        bit_in = 0;
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        @(posedge clk);
    endtask

    // Task to feed bits one by one
    task feed_stream(input logic [31:0] stream, input int length);
        for (int i = length - 1; i >= 0; i--) begin
            bit_in = stream[i];
            enable = 1;
            @(posedge clk);
        end
        enable = 0;
        @(posedge clk);
    endtask

    // Test different behaviors
    initial begin
        // Initialize
        rst = 0;
        enable = 0;
        bit_in = 0;

        // Apply reset
        apply_reset();

        // === Test Case 1: Basic match ===
        pattern = 4'b1010;
        $display("Test 1: Pattern = 1010, Input = 1101010101 (Expected Matches = 3)");
        feed_stream(32'b0000000000000000000000001101010101, 10);
        $display("Match Count: %0d", match_count);

        apply_reset();

        // === Test Case 2: No match ===
        pattern = 4'b1111;
        $display("Test 2: Pattern = 1111, Input = 1010101010 (Expected Matches = 0)");
        feed_stream(32'b0000000000000000000000001010101010, 10);
        $display("Match Count: %0d", match_count);

        apply_reset();

        // === Test Case 3: All zeros ===
        pattern = 4'b0000;
        $display("Test 3: Pattern = 0000, Input = 0000000000 (Expected Matches = 7)");
        feed_stream(32'b0000000000000000000000000000000000, 10);
        $display("Match Count: %0d", match_count);

        apply_reset();

        // === Test Case 4: Match at end ===
        pattern = 4'b1001;
        $display("Test 4: Pattern = 1001, Input = 00001001 (Expected Matches = 1)");
        feed_stream(32'b00000000000000000000000000001001, 8);
        $display("Match Count: %0d", match_count);

        apply_reset();

        // === Test Case 5: Short input, less than 4 bits ===
        pattern = 4'b1010;
        $display("Test 5: Pattern = 1010, Input = 101 (Expected Matches = 0)");
        feed_stream(32'b00000000000000000000000000000101, 3);
        $display("Match Count: %0d", match_count);

        apply_reset();

        // === Test Case 6: Multiple consecutive matches with overlap ===
        pattern = 4'b1111;
        $display("Test 6: Pattern = 1111, Input = 1111111111 (Expected Matches = 7)");
        feed_stream(32'b0000000000000000000000001111111111, 10);
        $display("Match Count: %0d", match_count);

        apply_reset();

        // === Test Case 7: Pattern = 0001, Input = 0000000001 (Expected Matches = 1) ===
        pattern = 4'b0001;
        $display("Test 7: Pattern = 0001, Input = 0000000001 (Expected Matches = 1)");
        feed_stream(32'b0000000000000000000000000000000001, 10);
        $display("Match Count: %0d", match_count);

        apply_reset();

        $display("All test cases completed.");
        $finish;
    end

endmodule
```
