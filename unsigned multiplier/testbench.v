`timescale 1ns / 1ps

module testbench;

  reg [15:0] A;          // Input A (16 bits)
  reg [15:0] B;          // Input B (16 bits)
  wire [31:0] product;  // Product result (32 bits)
  integer i;            // Loop variable
  integer result_file;
  integer error = 0;    // Error count for failed tests

  multi_16bit uut (
    .A(A),
    .B(B),
    .product(product)
  );

  // Test cases
  initial begin

    for (i = 0; i < 200; i = i + 1) begin
      // Generate random 8-bit inputs
      A = $random;
      B = $random;

      // Wait for the operation to complete
      #10;

    //   $display("A = %d, B = %d, Expected Product = %d", A, B, A * B);

      // Check the result of the multiplication
      if (product !== A * B) begin
        error = error + 1;
        $display("Test failed: A = %d, B = %d, Expected Product = %d, Got = %d", A, B, A * B, product);
      end else begin
        $display("Test passed: A = %d, B = %d, Product = %d", A, B, product);
      end
    end

    // Final test result summary
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