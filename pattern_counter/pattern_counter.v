```verilog
module pattern_counter (
    input wire clk,
    input wire rst,
    input wire bit_in,
    input wire [3:0] pattern,
    input wire enable,
    output reg [15:0] match_count,
    output reg pattern_match,
    output wire ready
);

    reg [3:0] shift_reg;

    // Ready is high when module is enabled and not in reset
    assign ready = enable & ~rst;

    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= 4'b0000;
            match_count <= 16'd0;
            pattern_match <= 1'b0;
        end else if (enable) begin
            // Shift in the new bit from bit_in
            shift_reg <= {shift_reg[2:0], bit_in};

            // Compare shifted pattern to input pattern
            if ({shift_reg[2:0], bit_in} == pattern) begin
                pattern_match <= 1'b1;
                match_count <= match_count + 1;
            end else begin
                pattern_match <= 1'b0;
            end
        end else begin
            pattern_match <= 1'b0;
        end
    end

endmodule
```
