module sub_16bit_unsigned (
    input  wire [15:0] A,       // Unsigned 16-bit minuend
    input  wire [15:0] B,       // Unsigned 16-bit subtrahend
    output wire [15:0] result,  // Result of A - B
    output wire        borrow   // Borrow-out flag
);

    // Perform unsigned subtraction
    assign result = A - B;

    // Borrow-out detection:
    // If A < B, then subtraction underflows → borrow = 1
    assign borrow = (A < B) ? 1'b1 : 1'b0;

endmodule