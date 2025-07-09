`timescale 1ns / 1ps

module regfile_tb;

    // DUT inputs
    reg clk;
    reg we;
    reg [4:0] waddr;
    reg [31:0] wdata;
    reg [4:0] raddr1;
    reg [4:0] raddr2;

    // DUT outputs
    wire [31:0] rdata1;
    wire [31:0] rdata2;

    // Instantiate the DUT
    regfile uut (
        .clk(clk),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2)
    );

    // Clock generator
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period

    // Test variables
    integer i;
    integer errors = 0;

    // Task to write to a register
    task write_reg;
        input [4:0] addr;
        input [31:0] data;
        begin
            @(negedge clk);
            we = 1;
            waddr = addr;
            wdata = data;
            @(negedge clk);
            we = 0;
            waddr = 0;
            wdata = 0;
        end
    endtask

    // Task to read two registers
    task read_regs;
        input [4:0] addr1;
        input [4:0] addr2;
        begin
            raddr1 = addr1;
            raddr2 = addr2;
            #1; // let combinational logic settle
        end
    endtask

    // Task to check expected output
    task check;
        input [31:0] val1;
        input [31:0] val2;
        begin
            if (rdata1 !== val1 || rdata2 !== val2) begin
                $display("ERROR: rdata1 = %0d (expected %0d), rdata2 = %0d (expected %0d)",
                         rdata1, val1, rdata2, val2);
                errors = errors + 1;
            end
        end
    endtask

    // Test procedure
    initial begin
        $display("Starting Register File Testbench...");
        we = 0; waddr = 0; wdata = 0;
        raddr1 = 0; raddr2 = 0;

        // --- TEST 1: Writing to x0 should be ignored ---
        write_reg(5'd0, 32'hDEADBEEF);
        read_regs(5'd0, 5'd0);
        check(32'd0, 32'd0);

        // --- TEST 2: Write and read all registers 1 to 31 ---
        for (i = 1; i < 32; i = i + 1) begin
            write_reg(i[4:0], i*10);
        end

        // --- TEST 3: Read all registers and check values ---
        for (i = 1; i < 32; i = i + 1) begin
            read_regs(i[4:0], 5'd0); // test read port 1 and read x0
            check(i*10, 32'd0);

            read_regs(5'd0, i[4:0]); // test read port 2 and read x0
            check(32'd0, i*10);
        end

        // --- TEST 4: Simultaneous reads ---
        read_regs(5'd10, 5'd20);
        check(10*10, 20*10);

        // --- Summary ---
        if (errors == 0)
            $display("All tests PASSED.");
        else
            $display("%0d test(s) FAILED.", errors);

        $finish;
    end

endmodule
