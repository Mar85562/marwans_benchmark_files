module register_8bit (
    input  wire       clk,  // Clock input
    input  wire       rst,  // Active-high synchronous reset
    input  wire [7:0] d,    // 8-bit data input
    output reg  [7:0] q     // 8-bit data output
);

    // Sequential logic: synchronous reset and data capture
    always @(posedge clk) begin
        if (rst)
            q <= 8'b00000000;  // Clear on reset
        else
            q <= d;            // Capture input
    end

endmodule