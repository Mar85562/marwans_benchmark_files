module encoder_4x2 (
    input  wire [3:0] in,
    output reg  [1:0] out
);
    always @(*) begin
        case (in)
            4'b0001: out = 2'd0;
            4'b0010: out = 2'd1;
            4'b0100: out = 2'd2;
            4'b1000: out = 2'd3;
            default: out = 2'bxx; // invalid input
        endcase
    end
endmodule