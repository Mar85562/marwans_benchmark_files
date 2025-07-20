
module uart_tx #(
    parameter CLK_HZ = 50_000_000,
    parameter BIT_RATE = 9600,
    parameter PAYLOAD_BITS = 8,
    parameter STOP_BITS = 1
)(
    input  wire                    clk,
    input  wire                    resetn,
    input  wire                    uart_tx_en,
    input  wire [PAYLOAD_BITS-1:0] uart_tx_data,
    output reg                     uart_txd,
    output reg                     uart_tx_busy
);
    localparam BAUD_TICKS = CLK_HZ / BIT_RATE;

    parameter IDLE    = 2'b00;
    parameter START   = 2'b01;
    parameter SEND    = 2'b10;
    parameter STOP    = 2'b11;

    reg [1:0] state;
    integer baud_cnt;
    integer bit_cnt;
    reg [PAYLOAD_BITS-1:0] shift_reg;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= IDLE;
            baud_cnt <= 0;
            bit_cnt <= 0;
            uart_tx_busy <= 0;
            uart_txd <= 1'b1;  // Idle is high
        end else begin
            case (state)
                IDLE: begin
                    uart_txd <= 1'b1;
                    uart_tx_busy <= 0;
                    if (uart_tx_en) begin
                        state <= START;
                        shift_reg <= uart_tx_data;
                        baud_cnt <= BAUD_TICKS - 1;
                        uart_tx_busy <= 1;
                    end
                end

                START: begin
                    uart_txd <= 0;  // Start bit
                    if (baud_cnt == 0) begin
                        state <= SEND;
                        bit_cnt <= 0;
                        baud_cnt <= BAUD_TICKS - 1;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end

                SEND: begin
                    uart_txd <= shift_reg[bit_cnt];
                    if (baud_cnt == 0) begin
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
                    uart_txd <= 1;  // Stop bit
                    if (baud_cnt == 0) begin
                        state <= IDLE;
                    end else begin
                        baud_cnt <= baud_cnt - 1;
                    end
                end
            endcase
        end
    end
endmodule
