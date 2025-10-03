module sub_8bit_signed (
    input  signed [7:0] A,
    input  signed [7:0] B,
    output signed [7:0] result,
    output              overflow
);
    wire signed [7:0] B_neg = -B;
    wire signed [7:0] diff  = A + B_neg;

    assign result   = diff;
    // overflow if A and -B share sign and result flips relative to A
    assign overflow = (A[7] == B_neg[7]) && (result[7] != A[7]);
endmodule