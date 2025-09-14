module decoder_2x4 (
    input  wire [1:0] in,    // 2-bit binary input
    output reg  [3:0] out    // 4-bit one-hot output
);

    always @(*) begin
        case (in)
            2'b00: out = 4'b0001;
            2'b01: out = 4'b0010;
            2'b10: out = 4'b0100;
            2'b11: out = 4'b1000;
            default: out = 4'bxxxx; // optional, can be omitted since all 2-bit values are covered
        endcase
    end

endmodule
