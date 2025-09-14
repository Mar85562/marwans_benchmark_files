module encoder_8x3 (
    input  wire [7:0] in,   // 8-bit one-hot input
    output reg  [2:0] out   // 3-bit binary encoded output
);

    always @(*) begin
        case (in)
            8'b0000_0001: out = 3'd0;
            8'b0000_0010: out = 3'd1;
            8'b0000_0100: out = 3'd2;
            8'b0000_1000: out = 3'd3;
            8'b0001_0000: out = 3'd4;
            8'b0010_0000: out = 3'd5;
            8'b0100_0000: out = 3'd6;
            8'b1000_0000: out = 3'd7;
            default:      out = 3'bxxx; // undefined for invalid input
        endcase
    end

endmodule