
module multi_16bit (
    input  wire [15:0] A,       // Multiplicand
    input  wire [15:0] B,       // Multiplier
    output reg  [31:0] product  // 32-bit Product (A * B)
);

    integer i;                  // Loop variable
    reg [31:0] multiplicand;    // Extended multiplicand for shifting

    always @(*) begin
        product = 32'b0;        // Initialize product to 0
        multiplicand = {16'b0, A}; // Extend A to 32 bits (left-aligned)

        for (i = 0; i < 16; i = i + 1) begin
            if (B[i]) begin
                product = product + (multiplicand << i);
            end
        end
    end

endmodule
