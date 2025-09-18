module mult_signed_16bit (
    input  signed [15:0] a,
    input  signed [15:0] b,
    output signed [31:0] product
);
    // absolute magnitudes
    wire [15:0] abs_a = a[15] ? -a : a;
    wire [15:0] abs_b = b[15] ? -b : b;

    // partial products (array)
    wire [31:0] pp [15:0];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_pp
            assign pp[i] = abs_b[i] ? ({{16{1'b0}}, abs_a} << i) : 32'b0;
        end
    endgenerate

    // sum of partial products
    wire [31:0] unsigned_product =
        pp[0]  + pp[1]  + pp[2]  + pp[3]  +
        pp[4]  + pp[5]  + pp[6]  + pp[7]  +
        pp[8]  + pp[9]  + pp[10] + pp[11] +
        pp[12] + pp[13] + pp[14] + pp[15];

    // sign correction
    assign product = (a[15] ^ b[15]) ? -unsigned_product : unsigned_product;
endmodule