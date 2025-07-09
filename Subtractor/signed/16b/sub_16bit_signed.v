module sub_16bit_signed (
    input  signed [15:0] A,        // First 16-bit signed operand
    input  signed [15:0] B,        // Second 16-bit signed operand
    output signed [15:0] result,   // Result of A - B
    output overflow                // Overflow flag
);

    wire signed [15:0] B_neg;      // Two's complement of B
    wire signed [15:0] diff;       // Intermediate result

    assign B_neg  = -B;            // Negate B to perform A - B
    assign diff   = A + B_neg;     // Subtraction via addition
    assign result = diff;

    // Overflow occurs when A and -B have the same sign, but result has a different sign
    assign overflow = (A[15] == B_neg[15]) && (result[15] != A[15]);

endmodule
