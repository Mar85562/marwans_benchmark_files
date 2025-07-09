module sub_32bit_signed (
    input  signed [31:0] A,         // First 32-bit signed operand
    input  signed [31:0] B,         // Second 32-bit signed operand
    output signed [31:0] result,    // Result of A - B
    output overflow                 // Overflow flag
);

    wire signed [31:0] B_neg;       // Two's complement of B
    wire signed [31:0] diff;        // Intermediate result

    assign B_neg  = -B;             // Negate B to perform A - B
    assign diff   = A + B_neg;      // Subtraction via addition
    assign result = diff;

    // Overflow occurs when A and -B have the same sign,
    // but result has a different sign from A
    assign overflow = (A[31] == B_neg[31]) && (result[31] != A[31]);

endmodule
