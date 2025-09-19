`timescale 1ns / 1ps

// Testbench for the sub_16bit_unsigned module
module testbench;

    // Declare signals for connecting to the Unit Under Test (UUT)
    reg  [15:0] A;       // Test input for minuend (16-bit)
    reg  [15:0] B;       // Test input for subtrahend (16-bit)
    wire [15:0] result;  // Output from UUT: A - B (16-bit)
    wire        borrow;  // Output from UUT: borrow-out flag

    // Internal variables for test control and verification
    integer i, j;        // Loop counters for systematic testing
    integer error_count; // Counter for failed test cases
    integer f;           // File handle for writing test results

    // Variables to store expected outputs for comparison
    reg  [15:0] expected_result;
    reg         expected_borrow;

    // Instantiate the Unit Under Test (UUT)
    sub_16bit_unsigned uut (
        .A(A),
        .B(B),
        .result(result),
        .borrow(borrow)
    );

    // Initial block for test stimulus generation and verification
    initial begin
        $display("---------------------------------------------------");
        $display("Starting comprehensive testbench for sub_16bit_unsigned...");
        $display("---------------------------------------------------");

        error_count = 0; // Initialize error counter

        // --- Test Case 1: Corner Cases and Specific Values ---
        $display("\n--- Running specific test cases ---");

        // Test Case 1.1: A = B (result = 0, borrow = 0)
        A = 16'd10000; B = 16'd10000;
        #5; // Wait for propagation delay
        expected_result = 16'd0;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.2: A > B (no borrow)
        A = 16'd50000; B = 16'd15000;
        #5;
        expected_result = 16'd35000;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.3: A < B (borrow occurs)
        A = 16'd15000; B = 16'd50000;
        #5;
        // For unsigned, A - B when A < B wraps around.
        // e.g., 15000 - 50000 = -35000. In 16-bit unsigned, this is 65536 - 35000 = 30536.
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
        A = 16'd0; B = 16'd0;
        #5;
        expected_result = 16'd0;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.5: Max values
        A = 16'd65535; B = 16'd65535;
        #5;
        expected_result = 16'd0;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.6: A = 0, B = 1 (smallest borrow case)
        A = 16'd0; B = 16'd1;
        #5;
        expected_result = 16'd65535; // 0 - 1 = -1, unsigned 16-bit is 65535
        expected_borrow = 1'b1;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.7: A = 1, B = 0
        A = 16'd1; B = 16'd0;
        #5;
        expected_result = 16'd1;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.8: A = 65535, B = 0
        A = 16'd65535; B = 16'd0;
        #5;
        expected_result = 16'd65535;
        expected_borrow = 1'b0;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end

        // Test Case 1.9: A = 0, B = 65535 (largest borrow case)
        A = 16'd0; B = 16'd65535;
        #5;
        expected_result = 16'd1; // 0 - 65535 = -65535, unsigned 16-bit is 1
        expected_borrow = 1'b1;
        if (result !== expected_result || borrow !== expected_borrow) begin
            $display("FAIL: A=%d, B=%d | Expected Result=%d, Got=%d | Expected Borrow=%b, Got=%b",
                     A, B, expected_result, result, expected_borrow, borrow);
            error_count = error_count + 1;
        end else begin
            $display("PASS: A=%d, B=%d | Result=%d, Borrow=%b", A, B, result, borrow);
        end


        // --- Test Case 2: Exhaustive/Systematic Testing (0-255 for both A and B) ---
        // This tests a smaller range exhaustively to catch patterns
        // Note: Full 16-bit exhaustive testing (65536*65536 combinations) is too long for simulation.
        // We limit it to a reasonable range like 0-255 for systematic check.
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
        $display("\n--- Running random test cases (10000 iterations) ---");
        for (i = 0; i < 10000; i = i + 1) begin // Increased iterations for 16-bit
            // Generate random 16-bit unsigned values (0 to 65535)
            A = $urandom_range(0, 65535); // $urandom_range is preferred for unsigned random
            B = $urandom_range(0, 65535);
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
