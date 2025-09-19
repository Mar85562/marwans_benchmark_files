module sub_16bit_signed (
    input  signed [15:0] A,
    input  signed [15:0] B,
    output signed [15:0] result,
    output               overflow
);
    wire signed [15:0] B_neg = -B;
    wire signed [15:0] diff  = A + B_neg;

    assign result   = diff;
    // overflow if A and -B share sign and result flips relative to A
    assign overflow = (A[15] == B_neg[15]) && (result[15] != A[15]);
endmodule