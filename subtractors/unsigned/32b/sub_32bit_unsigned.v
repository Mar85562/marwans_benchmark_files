module sub_32bit_unsigned (
    input  wire [31:0] A,       // first input (subtract from)
    input  wire [31:0] B,       // number to subtract
    output wire [31:0] result,  // A - B (mod 2^32)
    output wire        borrow   // 1 when A < B
);
    assign result = A - B;
    assign borrow = (A < B);
endmodule