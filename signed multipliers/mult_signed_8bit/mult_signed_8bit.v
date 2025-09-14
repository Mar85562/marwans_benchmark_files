module mult_signed_8bit(
    input  signed [7:0] a,
    input  signed [7:0] b,
    output signed [15:0] product
);

    wire [7:0] abs_a = a[7] ? -a : a;
    wire [7:0] abs_b = b[7] ? -b : b;

    wire [15:0] pp0  = abs_b[0] ? {8'b0, abs_a}       : 16'b0;
    wire [15:0] pp1  = abs_b[1] ? {7'b0, abs_a, 1'b0} : 16'b0;
    wire [15:0] pp2  = abs_b[2] ? {6'b0, abs_a, 2'b0} : 16'b0;
    wire [15:0] pp3  = abs_b[3] ? {5'b0, abs_a, 3'b0} : 16'b0;
    wire [15:0] pp4  = abs_b[4] ? {4'b0, abs_a, 4'b0} : 16'b0;
    wire [15:0] pp5  = abs_b[5] ? {3'b0, abs_a, 5'b0} : 16'b0;
    wire [15:0] pp6  = abs_b[6] ? {2'b0, abs_a, 6'b0} : 16'b0;
    wire [15:0] pp7  = abs_b[7] ? {1'b0, abs_a, 7'b0} : 16'b0;

    wire [15:0] unsigned_product = pp0 + pp1 + pp2 + pp3 + pp4 + pp5 + pp6 + pp7;

    // Final sign adjustment based on original sign of a and b
    assign product = (a[7] ^ b[7]) ? -unsigned_product : unsigned_product;

endmodule
