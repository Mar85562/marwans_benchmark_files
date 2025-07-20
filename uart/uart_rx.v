
module uart_rx #(
    parameter CLK_HZ = 50_000_000,
    parameter BIT_RATE = 9600,
    parameter PAYLOAD_BITS = 8,
    parameter STOP_BITS = 1
)(
    input  wire                    clk,
    input  wire                    resetn,
    input  wire                    uart_rxd,
    input  wire                    uart_rx_en,
    output reg  [PAYLOAD_BITS-1:0] uart_rx_data,
    output reg                     uart_rx_valid,
    output reg                     uart_rx_break
);
    localparam BAUD_TICKS = CLK_HZ / BIT_RATE;
    localparam HALF_BAUD  = BAUD_TICKS / 2;

    parameter IDLE    = 2'b00;
    parameter START   = 2'b01;
    parameter RECEIVE = 2'b10;
    parameter STOP    = 2'b11;

    reg [1:0] state;
    integer baud_cnt;
    integer bit_cnt;
    reg [PAYLOAD_BITS-1:0] data_shift;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= IDLE;
            baud_cnt <= 0;
            bit_cnt <= 0;
            uart_rx_data <= 0;
            uart_rx_valid <= 0;
            uart_rx_break <= 0;
        end else begin
            uart_rx_valid <= 0;

            case (state)
                IDLE: begin
                    if (uart_rx_en && !uart_rxd) begin  // Start bit detected (falling edge)
                        state <= START;
                        baud_cnt <= HALF_BAUD;
                    end
                end

                START: begin
                    if (baud_cnt == 0) begin
                        if (!uart_rxd) begin
                            state <= RECEIVE;
                            bit_cnt <= 0;
                            baud_cnt <= BAUD_TICKS - 1;
                        end else begin
                            state <= IDLE;  // False start
                        end
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                RECEIVE: begin
                    if (baud_cnt == 0) begin
                        data_shift[bit_cnt] <= uart_rxd;
                        bit_cnt <= bit_cnt + 1;

                        if (bit_cnt == PAYLOAD_BITS - 1) begin
                            state <= STOP;
                        end
                        baud_cnt <= BAUD_TICKS - 1;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                STOP: begin
                    if (baud_cnt == 0) begin
                        uart_rx_data <= data_shift;
                        uart_rx_valid <= 1;
                        uart_rx_break <= (data_shift == 0);
                        state <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end
            endcase
        end
    end
endmodule
