module sub_8bit_signed(
    input signed [7:0] A,
    input signed [7:0] B,
    output signed [7:0] result,
    output overflow
);

    wire signed [7:0] B_neg;
    wire signed [7:0] diff;
    
    assign B_neg = -B; // Negate B to perform subtraction
    assign diff = A + B_neg;
    assign result = diff;

    //Oveflow detection: occurs if signs of A and -B are the same, but the result has a different sign.
    assign overflow = (A[7] == B_neg[7]) && (A[7] != result[7]);

endmodule