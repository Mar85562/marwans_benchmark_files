`timescale 1ns / 1ps

module testbench;

    reg signed [7:0] A, B;
    wire signed [7:0] result;
    wire overflow;

    integer i, j, error;
    reg signed [7:0] test_vals [0:8];
    reg signed [7:0] res, neg_b;
    reg expected_ovf;

    sub_8bit_signed uut (
        .A(A),
        .B(B),
        .result(result),
        .overflow(overflow)
    );

    initial begin
        $display("Starting testbench for 8-bit signed subtraction...");
        error = 0;

        // Define corner cases
        test_vals[0] = 0;
        test_vals[1] = 1;
        test_vals[2] = -1;
        test_vals[3] = 127;
        test_vals[4] = -128;
        test_vals[5] = 126;
        test_vals[6] = -127;
        test_vals[7] = 64;
        test_vals[8] = -64;

        for (i = 0; i < 9; i = i + 1) begin
            for (j = 0; j < 9; j = j + 1) begin
                A = test_vals[i];
                B = test_vals[j];
                #5;
                neg_b = ~B + 1;
                res = A + neg_b;
                expected_ovf = (A[7] == neg_b[7]) && (res[7] != A[7]);

                if (result !== (A - B) || overflow !== expected_ovf) begin
                    error = error + 1;
                    $display("FAIL: A=%d, B=%d | Expected=%d, Got=%d | Overflow Expected=%b, Got=%b",
                             A, B, A - B, result, expected_ovf, overflow);
                end
            end
        end

        if (error == 0)
            $display("All 8-bit tests passed successfully!");
        else
            $display("%d tests failed in 8-bit testbench.", error);

        $finish;
    end

endmodule
