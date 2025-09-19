`timescale 1ns / 1ps

// Testbench for the sub_32bit_unsigned module
module testbench;

    // Declare signals for connecting to the Unit Under Test (UUT)
    reg  [31:0] A;       // Test input for minuend (32-bit)
    reg  [31:0] B;       // Test input for subtrahend (32-bit)
    wire [31:0] result;  // Output from UUT: A - B (32-bit)
    wire        borrow;  // Output from UUT: borrow-out flag

    // Internal variables for test control and verification
    integer i, j;        // Loop counters for systematic testing
    integer error_count; // Counter for failed test cases
    integer f;           // File handle for writing test results

    // Variables to store expected outputs for comparison
    reg  [31:0] expected_result;
    reg         expected_borrow;

    // Instantiate the Unit Under Test (UUT)
    sub_32bit_unsigned uut (
        .A(A),
        .B(B),
        .result(result),
        .borrow(borrow)
    );

    // Define maximum 32-bit unsigned value using 'parameter' for pure Verilog
    parameter MAX_32BIT_UNSIGNED = 32'hFFFF_FFFF; // 2^32 - 1
    // Initial block for test stimulus generation and verification
    initial begin
        $display("---------------------------------------------------");
        $display("Starting comprehensive testbench for sub_32bit_unsigned...");
        $display("---------------------------------------------------");

        error_count = 0; // Initialize error counter


        // --- Test Case 1: Corner Cases and Specific Values ---
        $display("\n--- Running specific test cases ---");

        // Test Case 1.1: A = B (result = 0, borrow = 0)
        A = 32'd123456789; // This is line 38
        B = 32'd123456789;
        #5; // Wait for propagation delay
        expected_result = 32'd0;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.2: A > B (no borrow)
        A = 32'd3000000000;
        B = 32'd1000000000;
        #5;
        expected_result = 32'd2000000000;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.3: A < B (borrow occurs)
        A = 32'd1000000000;
        B = 32'd3000000000;
        #5;
        // For unsigned, A - B when A < B wraps around.
        expected_result = A - B; // Verilog handles unsigned wrap-around
        expected_borrow = 1'b1;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.4: Zero values
        A = 32'd0;
        B = 32'd0;
        #5;
        expected_result = 32'd0;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.5: Max values
        A = MAX_32BIT_UNSIGNED;
        B = MAX_32BIT_UNSIGNED;
        #5;
        expected_result = 32'd0;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.6: A = 0, B = 1 (smallest borrow case)
        A = 32'd0;
        B = 32'd1;
        #5;
        expected_result = MAX_32BIT_UNSIGNED; // 0 - 1 = -1, unsigned 32-bit is 2^32 - 1
        expected_borrow = 1'b1;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.7: A = 1, B = 0
        A = 32'd1;
        B = 32'd0;
        #5;
        expected_result = 32'd1;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.8: A = MAX, B = 0
        A = MAX_32BIT_UNSIGNED;
        B = 32'd0;
        #5;
        expected_result = MAX_32BIT_UNSIGNED;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.9: A = 0, B = MAX (largest borrow case)
        A = 32'd0;
        B = MAX_32BIT_UNSIGNED;
        #5;
        expected_result = 32'd1; // 0 - (2^32 - 1) = -(2^32 - 1), unsigned 32-bit is 1
        expected_borrow = 1'b1;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end


        // --- Test Case 2: Systematic Testing (0-255 for both A and B) ---
        // This tests a smaller range exhaustively to catch patterns
        // Full 32-bit exhaustive testing is computationally infeasible.
        $display("\n--- Running systematic test cases (0-255) ---");
        for (i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 256; j = j + 1) begin
                A = i;
                B = j;
                #5; // Wait for propagation

                // Calculate expected values
                expected_result = A - B;
                expected_borrow = (A < B) ? 1'b1 : 1'b0;

                // Compare and report
                if (result !== expected_result || borrow !== expected_borrow) begin
                    $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                             A, B, expected_result, result, expected_borrow, borrow);
                    error_count = error_count + 1;
                end
                // No 'PASS' display for exhaustive loops to keep output concise
            end
        end


        // --- Test Case 3: Random Value Testing ---
        // Test a larger number of random combinations to ensure robustness
        $display("\n--- Running random test cases (20000 iterations) ---");
        for (i = 0; i < 20000; i = i + 1) begin // Increased iterations for 32-bit
            // Generate random 32-bit unsigned values using $random
            // $random generates a signed 32-bit integer. We cast it to unsigned and mask.
            A = {$random} % (MAX_32BIT_UNSIGNED + 1);
            B = {$random} % (MAX_32BIT_UNSIGNED + 1);
            #5; // Wait for propagation

            // Calculate expected values
            expected_result = A - B;
            expected_borrow = (A < B) ? 1'b1 : 1'b0;

            // Compare and report
            if (result !== expected_result || borrow !== expected_borrow) begin
                $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                         A, B, expected_result, result, expected_borrow, borrow);
                error_count = error_count + 1;
            end
            // No 'PASS' display for random loops to keep output concise
        end

        // --- Final Report ---
        $display("\n---------------------------------------------------");
        $display("Testbench finished.");

        // Open file to write the final result (PASS/FAIL)
        f = $fopen("test_result.txt", "w");
        if (f == 0) begin
            $display("Error: Could not open test_result.txt for writing.");
        end else begin
            if (error_count == 0) begin
                $display("All tests passed successfully!");
                $fdisplay(f, "PASS");
            end else begin
                $display("%d test cases failed.", error_count);
                $fdisplay(f, "FAIL");
            end
            $fclose(f); // Close the file
        end

        $display("---------------------------------------------------");
        $finish; // End simulation
    end

endmodule
