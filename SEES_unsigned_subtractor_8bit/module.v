module sub_8bit_unsigned (
    input  wire [7:0] A,       // first input (subtract from)
    input  wire [7:0] B,       // number to subtract
    output wire [7:0] result,  // A - B (mod 2^8)
    output wire       borrow   // 1 when A < B
);
    assign result = A - B;
    assign borrow = (A < B);
endmodule