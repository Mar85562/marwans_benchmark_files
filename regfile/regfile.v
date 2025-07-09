//------------------------------------------------------------------------------
// Module: regfile
// Description: 32-register file with two asynchronous read ports and one 
//              synchronous write port. Register x0 is hardwired to 0.
// Suitable for: CPU datapaths (e.g., RISC-V, MIPS)
//------------------------------------------------------------------------------

module regfile (
    input  wire        clk,        // Clock for synchronous write
    input  wire        we,         // Write enable
    input  wire [4:0]  waddr,      // Write address
    input  wire [31:0] wdata,      // Write data
    input  wire [4:0]  raddr1,     // Read address 1
    input  wire [4:0]  raddr2,     // Read address 2
    output wire [31:0] rdata1,     // Read data 1
    output wire [31:0] rdata2      // Read data 2
);

    // Register file: 32 registers, 32 bits each
    reg [31:0] regs [0:31];

    // Synchronous write on positive clock edge
    always @(posedge clk) begin
        if (we && (waddr != 5'd0)) begin
            regs[waddr] <= wdata;
        end
    end

    // Asynchronous read logic
    assign rdata1 = (raddr1 == 5'd0) ? 32'd0 : regs[raddr1];
    assign rdata2 = (raddr2 == 5'd0) ? 32'd0 : regs[raddr2];

endmodule
