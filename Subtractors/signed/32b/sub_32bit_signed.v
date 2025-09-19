module sub_32bit_signed (
    input  signed [31:0] A,
    input  signed [31:0] B,
    output signed [31:0] result,
    output               overflow
);
    wire signed [31:0] B_neg = -B;
    wire signed [31:0] diff  = A + B_neg;

    assign result   = diff;
    // overflow if A and -B share sign and result flips relative to A
    assign overflow = (A[31] == B_neg[31]) && (result[31] != A[31]);
endmodule