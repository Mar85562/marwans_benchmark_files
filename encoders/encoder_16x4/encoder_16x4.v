module encoder_16x4 (
    input  wire [15:0] in,   // 16-bit one-hot input
    output reg  [3:0]  out   // 4-bit binary encoded output
);

    always @(*) begin
        case (in)
            16'b0000_0000_0000_0001: out = 4'd0;
            16'b0000_0000_0000_0010: out = 4'd1;
            16'b0000_0000_0000_0100: out = 4'd2;
            16'b0000_0000_0000_1000: out = 4'd3;
            16'b0000_0000_0001_0000: out = 4'd4;
            16'b0000_0000_0010_0000: out = 4'd5;
            16'b0000_0000_0100_0000: out = 4'd6;
            16'b0000_0000_1000_0000: out = 4'd7;
            16'b0000_0001_0000_0000: out = 4'd8;
            16'b0000_0010_0000_0000: out = 4'd9;
            16'b0000_0100_0000_0000: out = 4'd10;
            16'b0000_1000_0000_0000: out = 4'd11;
            16'b0001_0000_0000_0000: out = 4'd12;
            16'b0010_0000_0000_0000: out = 4'd13;
            16'b0100_0000_0000_0000: out = 4'd14;
            16'b1000_0000_0000_0000: out = 4'd15;
            default:                  out = 4'bxxxx; // undefined for invalid input
        endcase
    end

endmodule