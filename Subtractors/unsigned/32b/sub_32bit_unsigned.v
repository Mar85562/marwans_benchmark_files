module sub_32bit_unsigned (
    input  wire [31:0] A,       // Unsigned 32-bit minuend
    input  wire [31:0] B,       // Unsigned 32-bit subtrahend
    output wire [31:0] result,  // Subtraction result: A - B
    output wire        borrow   // Borrow-out flag: 1 if A < B
);

    // Subtraction operation
    assign result = A - B;

    // Borrow detection logic
    assign borrow = (A < B) ? 1'b1 : 1'b0;

endmodule