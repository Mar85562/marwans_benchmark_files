module register_16bit (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] d,
    output reg  [15:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= 16'b0000_0000_0000_0000;
        else
            q <= d;
    end
endmodule