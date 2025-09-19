module sub_16bit_unsigned (
    input  wire [15:0] A,       // first input (subtract from)
    input  wire [15:0] B,       // number to subtract
    output wire [15:0] result,  // A - B (mod 2^16)
    output wire        borrow   // 1 when A < B
);
    assign result = A - B;
    assign borrow = (A < B);
endmodule