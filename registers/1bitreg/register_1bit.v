module register_1bit (
    input  wire clk,  // Clock signal
    input  wire rst,  // Active-high synchronous reset
    input  wire d,    // Data input
    output reg  q     // Stored output
);

    // Sequential logic: triggered on rising edge of clk
    always @(posedge clk) begin
        if (rst)
            q <= 1'b0;   // Reset output to 0 when rst is high
        else
            q <= d;      // Otherwise, capture input d
    end

endmodule
