`timescale 1ns / 1ps

module testbench;

    reg signed [15:0] A, B;
    wire signed [15:0] result;
    wire overflow;

    integer i, j, error;
    reg signed [15:0] test_vals [0:8];
    reg signed [15:0] res, neg_b;
    reg expected_ovf;

    sub_16bit_signed uut (
        .A(A),
        .B(B),
        .result(result),
        .overflow(overflow)
    );

    initial begin
        $display("Starting testbench for 16-bit signed subtraction...");
        error = 0;

        test_vals[0] = 0;
        test_vals[1] = 1;
        test_vals[2] = -1;
        test_vals[3] = 32767;
        test_vals[4] = -32768;
        test_vals[5] = 32766;
        test_vals[6] = -32767;
        test_vals[7] = 16384;
        test_vals[8] = -16384;

        for (i = 0; i < 9; i = i + 1) begin
            for (j = 0; j < 9; j = j + 1) begin
                A = test_vals[i];
                B = test_vals[j];
                #5;
                neg_b = ~B + 1;
                res = A + neg_b;
                expected_ovf = (A[15] == neg_b[15]) && (res[15] != A[15]);

                if (result !== (A - B) || overflow !== expected_ovf) begin
                    error = error + 1;
                    $display("FAIL: A=%d, B=%d | Expected=%d, Got=%d | Overflow Expected=%b, Got=%b",
                             A, B, A - B, result, expected_ovf, overflow);
                end
            end
        end

        if (error == 0)
            $display("All 16-bit tests passed successfully!");
        else
            $display("%d tests failed in 16-bit testbench.", error);

        $finish;
    end

endmodule
