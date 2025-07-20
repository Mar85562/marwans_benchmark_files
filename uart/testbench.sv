`timescale 1ns / 1ps

module uart_top_tb;

    // Parameters (must match the DUT's default parameters for consistent testing)
    localparam CLK_HZ       = 50_000_000; // Clock frequency in Hz
    localparam BIT_RATE     = 9600;       // UART Baud Rate
    localparam PAYLOAD_BITS = 8;          // Number of data bits per frame
    localparam STOP_BITS    = 1;          // Number of stop bits per frame

    // Calculated timing constants based on parameters
    // CLK_PERIOD_NS: Clock period in nanoseconds (1ns / 1ps timescale)
    localparam CLK_PERIOD_NS = 1_000_000_000 / CLK_HZ; // 20 ns for 50 MHz clock

    // BAUD_TICKS: Number of clock cycles per baud period (integer division)
    localparam BAUD_TICKS    = CLK_HZ / BIT_RATE;      // 50,000,000 / 9600 = 5208

    // BIT_PERIOD_NS: Duration of one baud period in nanoseconds
    localparam BIT_PERIOD_NS = (BAUD_TICKS * CLK_PERIOD_NS); // 5208 * 20 ns = 104160 ns

    // HALF_BIT_PERIOD_NS: Half the duration of one baud period in nanoseconds
    localparam HALF_BIT_PERIOD_NS = BIT_PERIOD_NS / 2; // 104160 ns / 2 = 52080 ns

    // DUT inputs
    reg clk;        // System clock
    reg resetn;     // Asynchronous active-low reset
    reg uart_rxd;   // UART Receive Data input (driven by testbench)

    // DUT outputs
    wire uart_txd;  // UART Transmit Data output (monitored by testbench)
    wire [7:0] led_out; // LED output, reflects received data

    // Test variables
    integer errors = 0; // Counter for test failures
    integer f;          // File handle for test_result.txt

    // Instantiate the UART Top module (Device Under Test)
    uart_top #(
        .CLK_HZ(CLK_HZ),
        .BIT_RATE(BIT_RATE),
        .PAYLOAD_BITS(PAYLOAD_BITS),
        .STOP_BITS(STOP_BITS)
    ) uut (
        .clk(clk),
        .resetn(resetn),
        .uart_rxd(uart_rxd),
        .uart_txd(uart_txd),
        .led_out(led_out)
    );

    // Clock generator: Creates a clock with CLK_PERIOD_NS period
    initial clk = 0;
    always #(CLK_PERIOD_NS / 2) clk = ~clk; // Toggle every half period (e.g., #10 for 20ns period)

    // Task to apply an asynchronous reset
    task apply_reset;
        begin
            $display("TB: Applying reset...");
            resetn = 1'b0; // Assert reset
            @(posedge clk); // Wait for a clock edge
            @(posedge clk); // Wait for another clock edge to ensure reset is stable
            resetn = 1'b1; // De-assert reset
            $display("TB: Reset de-asserted.");
            # (CLK_PERIOD_NS * 5); // Wait a few cycles for stability after reset
        end
    endtask

    // Task to simulate sending a byte over UART (from testbench to DUT's uart_rxd)
    task send_byte;
        input [PAYLOAD_BITS-1:0] data_to_send;
        integer i;
        begin
            $display("TB: Sending byte 0x%h ('%0c') on uart_rxd...", data_to_send, data_to_send);

            // Start bit (logic 0)
            uart_rxd = 1'b0;
            #(BIT_PERIOD_NS); // Hold for one bit period
            
            // Data bits (LSB first)
            for (i = 0; i < PAYLOAD_BITS; i = i + 1) begin
                uart_rxd = data_to_send[i];
                #(BIT_PERIOD_NS);
            end

            // Stop bit(s) (logic 1)
            for (i = 0; i < STOP_BITS; i = i + 1) begin
                uart_rxd = 1'b1;
                #(BIT_PERIOD_NS);
            end

            // Ensure idle state (high) after transmission
            uart_rxd = 1'b1;
            $display("TB: Finished sending byte 0x%h.", data_to_send);
        end
    endtask

    // Task to expect and verify an echoed byte on uart_txd (from DUT to testbench)
    task expect_echoed_byte;
        input [PAYLOAD_BITS-1:0] expected_data;
        reg [PAYLOAD_BITS-1:0] received_data;
        integer i;
        integer timeout_clks; // Timeout counter in clock cycles
        reg reception_successful; // Flag to indicate if reception was successful

        begin
            $display("TB: Waiting for echoed byte (expected 0x%h) on uart_txd...", expected_data);
            received_data = 0;
            timeout_clks = 0;
            reception_successful = 1'b1; // Assume success initially

            // Wait for the start bit (falling edge) on uart_txd
            // Max wait: 2 full frames + some buffer (in clock cycles)
            // A frame is 1 (start) + PAYLOAD_BITS + STOP_BITS bits.
            // (1 + PAYLOAD_BITS + STOP_BITS + 2) * BAUD_TICKS * 2
            // For default: (1+8+1+2)*5208*2 = 12*5208*2 = 125000 approx
            while (uart_txd === 1'b1 && timeout_clks < (BAUD_TICKS * (PAYLOAD_BITS + STOP_BITS + 2) * 2)) begin
                @(posedge clk);
                timeout_clks = timeout_clks + 1;
            end

            if (uart_txd === 1'b1) begin
                $display("ERROR: Timeout waiting for start bit on uart_txd for expected 0x%h.", expected_data);
                errors = errors + 1;
                reception_successful = 1'b0; // Mark as failed
            end else begin // Only proceed if start bit was detected
                // Wait for half a bit period to sample the middle of the start bit
                #(HALF_BIT_PERIOD_NS);
                if (uart_txd !== 1'b0) begin
                    $display("ERROR: uart_txd not low at start bit sample point for expected 0x%h.", expected_data);
                    errors = errors + 1;
                    reception_successful = 1'b0; // Mark as failed
                end

                // Only proceed with data sampling if start bit was valid
                if (reception_successful) begin
                    // Wait for the remaining half of the start bit period
                    #(HALF_BIT_PERIOD_NS);

                    // Sample data bits (LSB first)
                    for (i = 0; i < PAYLOAD_BITS; i = i + 1) begin
                        #(BIT_PERIOD_NS);
                        received_data[i] = uart_txd;
                    end

                    // Wait for stop bit(s) and verify they are high
                    for (i = 0; i < STOP_BITS; i = i + 1) begin
                        #(BIT_PERIOD_NS);
                        if (uart_txd !== 1'b1) begin
                            $display("ERROR: uart_txd not high at stop bit sample point for expected 0x%h.", expected_data);
                            errors = errors + 1;
                            reception_successful = 1'b0; // Mark as failed
                        end
                    end
                end
            end

            // Final check and display based on reception success
            if (reception_successful) begin
                $display("TB: Received echoed byte 0x%h ('%0c').", received_data, received_data);
                if (received_data !== expected_data) begin
                    $display("ERROR: Echoed data mismatch! Expected 0x%h, Got 0x%h.", expected_data, received_data);
                    errors = errors + 1;
                end else begin
                    $display("TB: Echoed data matched expected 0x%h.", expected_data);
                end
            end else begin
                // If reception was not successful, ensure we still advance time to avoid blocking
                // This might happen if start bit was missed or invalid, but we need to move on.
                #(BIT_PERIOD_NS * (PAYLOAD_BITS + STOP_BITS + 2)); // Advance time for a full frame + buffer
            end
        end
    endtask

    // Task to check the led_out value
    task check_led_out;
        input [PAYLOAD_BITS-1:0] expected_led_data;
        begin
            // led_out is directly assigned rx_data, which is registered.
            // It should be stable after the uart_rx_valid signal is asserted and a clock cycle passes.
            // The expect_echoed_byte task already ensures the reception is complete.
            @(posedge clk); // Wait one clock cycle for potential register update
            if (led_out !== expected_led_data) begin
                $display("ERROR: LED output mismatch! Expected 0x%h, Got 0x%h.", expected_led_data, led_out);
                errors = errors + 1;
            end else begin
                $display("TB: LED output matched expected 0x%h.", expected_led_data);
            end
        end
    endtask

    integer k;
    reg [PAYLOAD_BITS-1:0] test_byte;

    // Main test procedure
    initial begin
        $display("Starting UART Top Testbench...");
        f = $fopen("test_result.txt", "w"); // Open file for test results

        // Initial conditions
        uart_rxd = 1'b1; // UART RX line idle high
        apply_reset;     // Apply initial reset

        // --- TEST 1: Basic Echo Functionality ---
        $display("\n--- TEST 1: Basic Echo Functionality (ASCII characters) ---");
        send_byte(8'h41); // Send 'A'
        expect_echoed_byte(8'h41);
        check_led_out(8'h41);

        send_byte(8'h5A); // Send 'Z'
        expect_echoed_byte(8'h5A);
        check_led_out(8'h5A);

        send_byte(8'h30); // Send '0'
        expect_echoed_byte(8'h30);
        check_led_out(8'h30);

        send_byte(8'hFF); // Send all ones (0xFF)
        expect_echoed_byte(8'hFF);
        check_led_out(8'hFF);

        send_byte(8'h01); // Send 0x01
        expect_echoed_byte(8'h01);
        check_led_out(8'h01);

        // --- TEST 2: False Start Detection ---
        // A brief low pulse on uart_rxd that is shorter than a half-baud period
        // The receiver should ignore this and remain in IDLE.
        $display("\n--- TEST 2: False Start Detection ---");
        $display("TB: Simulating false start (brief low pulse on uart_rxd)...");
        uart_rxd = 1'b0; // Pull low for a short duration
        #(HALF_BIT_PERIOD_NS / 2); // Less than half a baud period
        uart_rxd = 1'b1; // Return to high
        #(BIT_PERIOD_NS * 2); // Wait to ensure the RX is idle and no reception occurred

        // Verify that the UART is still idle by sending a known byte and checking its echo
        send_byte(8'hAA); // Send a new byte to confirm system is responsive
        expect_echoed_byte(8'hAA);
        check_led_out(8'hAA);


        // --- TEST 3: Break Condition Detection (all zeros payload) ---
        // A break condition is typically a start bit followed by all data bits and stop bits being low.
        // In this module, uart_rx_break is asserted if the received data is all zeros.
        $display("\n--- TEST 3: Break Condition Detection (sending 0x00) ---");
        send_byte(8'h00); // Send all zeros
        expect_echoed_byte(8'h00); // Expect 0x00 echoed back
        check_led_out(8'h00);      // Expect LED to show 0x00
        // Note: Direct verification of uart_rx_break signal is not possible as it's internal to uart_top.
        // We infer its correct behavior by the data being echoed and displayed on LEDs.

        // --- TEST 4: Consecutive Bytes (Stress Test) ---
        // Send multiple bytes back-to-back without significant idle time between them
        $display("\n--- TEST 4: Consecutive Bytes (Stress Test) ---");
        for (k = 0; k < 20; k = k + 1) begin
            test_byte = $urandom_range(0, 255); // Send random bytes
            send_byte(test_byte);
            expect_echoed_byte(test_byte);
            check_led_out(test_byte);
            // Add a very small delay to ensure the TX is ready for the next byte, but keep it tight
            #(BIT_PERIOD_NS / 4);
        end

        // Send specific patterns to stress bit transitions
        $display("TB: Sending alternating bit patterns...");
        send_byte(8'b01010101); // Alternating bits
        expect_echoed_byte(8'b01010101);
        check_led_out(8'b01010101);
        #(BIT_PERIOD_NS / 4);

        send_byte(8'b10101010); // Alternating bits
        expect_echoed_byte(8'b10101010);
        check_led_out(8'b10101010);
        #(BIT_PERIOD_NS / 4);

        // --- TEST 5: Reset during transmission/reception ---
        // Test system resilience by asserting reset in the middle of a transaction
        $display("\n--- TEST 5: Reset during transmission/reception ---");
        send_byte(8'hDE); // Start sending a byte
        // Apply reset after a few data bits have been sent
        #(BIT_PERIOD_NS * (1 + PAYLOAD_BITS / 2)); // After start bit and half the data bits
        apply_reset; // Assert and de-assert reset

        // After reset, the UART should be in a clean IDLE state.
        // Send another byte to verify normal operation resumes.
        send_byte(8'hAD); // Send a new byte
        expect_echoed_byte(8'hAD);
        check_led_out(8'hAD);

        // --- Final Summary ---
        $display("\n--- Test Summary ---");
        if (errors == 0) begin
            $display("All tests PASSED.");
            $fdisplay(f, "PASS"); // Write "PASS" to file for Makefile
        end else begin
            $display("%0d test(s) FAILED.", errors);
            $fdisplay(f, "FAIL"); // Write "FAIL" to file for Makefile
        end
        $fclose(f); // Close the results file
        $finish;    // End simulation
    end

endmodule
