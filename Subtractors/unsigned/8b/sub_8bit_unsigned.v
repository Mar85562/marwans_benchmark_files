module sub_8bit_unsigned (
    input  wire [7:0] A,       // Unsigned 8-bit minuend
    input  wire [7:0] B,       // Unsigned 8-bit subtrahend
    output wire [7:0] result,  // Result of A - B
    output wire       borrow   // Borrow-out flag
);

    // Perform subtraction
    assign result = A - B;

    // Borrow-out detection
    // If A < B, a borrow occurs → borrow = 1
    assign borrow = (A < B) ? 1'b1 : 1'b0;

endmodule