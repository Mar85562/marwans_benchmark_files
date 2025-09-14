`timescale 1ns / 1ps

module testbench;

  // Signed inputs and output
  reg  signed [15:0] A;          // Input A
  reg  signed [15:0] B;          // Input B
  wire signed [31:0] product;    // Output product

  integer i;                     // Loop variable
  integer result_file;
  integer error = 0;             // Error counter
  reg signed [31:0] expected;    // Expected result

  // Instantiate the DUT (Device Under Test)
  mult_signed_16bit uut (
    .a(A),
    .b(B),
    .product(product)
  );

  initial begin
    $display("=========== Begin 16-bit Signed Multiplier Testing ===========");

    // -----------------------------------------
    // Positive x Positive
    // -----------------------------------------
    $display("\n-- Testing Positive x Positive --");
    for (i = 0; i < 25; i = i + 1) begin
      A = $urandom_range(1, 32767);
      B = $urandom_range(1, 32767);
      expected = A * B;
      #1;
      if (product !== expected) begin
        error = error + 1;
        $display("FAILED (++): A = %0d, B = %0d | Expected = %0d, Got = %0d", A, B, expected, product);
      end else begin
        $display("PASSED (++): A = %0d, B = %0d | Product = %0d", A, B, product);
      end
    end

    // -----------------------------------------
    // Positive x Negative
    // -----------------------------------------
    $display("\n-- Testing Positive x Negative --");
    for (i = 0; i < 25; i = i + 1) begin
      A = $urandom_range(1, 32767);
      B = -$urandom_range(1, 32768);
      expected = A * B;
      #1;
      if (product !== expected) begin
        error = error + 1;
        $display("FAILED (+-): A = %0d, B = %0d | Expected = %0d, Got = %0d", A, B, expected, product);
      end else begin
        $display("PASSED (+-): A = %0d, B = %0d | Product = %0d", A, B, product);
      end
    end

    // -----------------------------------------
    // Negative x Negative
    // -----------------------------------------
    $display("\n-- Testing Negative x Negative --");
    for (i = 0; i < 25; i = i + 1) begin
      A = -$urandom_range(1, 32768);
      B = -$urandom_range(1, 32768);
      expected = A * B;
      #1;
      if (product !== expected) begin
        error = error + 1;
        $display("FAILED (--): A = %0d, B = %0d | Expected = %0d, Got = %0d", A, B, expected, product);
      end else begin
        $display("PASSED (--): A = %0d, B = %0d | Product = %0d", A, B, product);
      end
    end

    // -----------------------------------------
    // Negative x Positive
    // -----------------------------------------
    $display("\n-- Testing Negative x Positive --");
    for (i = 0; i < 25; i = i + 1) begin
      A = -$urandom_range(1, 32768);
      B = $urandom_range(1, 32767);
      expected = A * B;
      #1;
      if (product !== expected) begin
        error = error + 1;
        $display("FAILED (-+): A = %0d, B = %0d | Expected = %0d, Got = %0d", A, B, expected, product);
      end else begin
        $display("PASSED (-+): A = %0d, B = %0d | Product = %0d", A, B, product);
      end
    end

    // -----------------------------------------
    // Final Summary
    // -----------------------------------------
        result_file = $fopen("test_result.txt", "w");
    if (error == 0) begin
      $display("\n=========== All Tests Passed Successfully ===========");
      $fdisplay(result_file, "PASS");
    end else begin
      $display("\n=========== Test completed with %0d / 100 failures ===========", error);
      $fdisplay(result_file, "FAIL");
  end
      $fclose(result_file);
      $finish;
  end


endmodule
