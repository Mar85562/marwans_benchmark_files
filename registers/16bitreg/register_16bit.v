module register_16bit (
    input  wire        clk,  // Clock input
    input  wire        rst,  // Active-high synchronous reset
    input  wire [15:0] d,    // 16-bit data input
    output reg  [15:0] q     // 16-bit data output
);

  always @(posedge clk) begin
    if (rst)
      q <= 16'b0000000000000000;  // Clear register on reset
    else
      q <= d;                     // Store input on clock edge
  end

endmodule