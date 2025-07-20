`timescale 1ns / 1ps

module uart_top #(
    parameter CLK_HZ = 50_000_000,
    parameter BIT_RATE = 9600,
    parameter PAYLOAD_BITS = 8,
    parameter STOP_BITS = 1
)(
    input  wire                   clk,
    input  wire                   resetn,
    input  wire                   uart_rxd,
    output wire                   uart_txd,
    output wire [7:0]             led_out
);
    wire [PAYLOAD_BITS-1:0] rx_data;
    wire rx_valid, rx_break;
    wire tx_busy;

    reg tx_en;
    reg [PAYLOAD_BITS-1:0] tx_data;

    // Echo control logic
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            tx_en <= 0;
            tx_data <= 0;
        end else begin
            if (rx_valid && !tx_busy) begin
                tx_data <= rx_data;
                tx_en <= 1;
            end else begin
                tx_en <= 0;
            end
        end
    end

    assign led_out = rx_data;

    uart_rx #(
        .CLK_HZ(CLK_HZ),
        .BIT_RATE(BIT_RATE),
        .PAYLOAD_BITS(PAYLOAD_BITS),
        .STOP_BITS(STOP_BITS)
    ) uart_rx_inst (
        .clk(clk),
        .resetn(resetn),
        .uart_rxd(uart_rxd),
        .uart_rx_en(1'b1),
        .uart_rx_data(rx_data),
        .uart_rx_valid(rx_valid),
        .uart_rx_break(rx_break)
    );

    uart_tx #(
        .CLK_HZ(CLK_HZ),
        .BIT_RATE(BIT_RATE),
        .PAYLOAD_BITS(PAYLOAD_BITS),
        .STOP_BITS(STOP_BITS)
    ) uart_tx_inst (
        .clk(clk),
        .resetn(resetn),
        .uart_tx_en(tx_en),
        .uart_tx_data(tx_data),
        .uart_txd(uart_txd),
        .uart_tx_busy(tx_busy)
    );
endmodule
