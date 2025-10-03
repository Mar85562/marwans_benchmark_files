`timescale 1ns / 1ps

module testbench;

    reg signed [31:0] A, B;
    wire signed [31:0] result;
    wire overflow;

    integer i, j, error;
    reg signed [31:0] test_vals [0:8];
    reg signed [31:0] res, neg_b;
    reg expected_ovf;

    sub_32bit_signed uut (
        .A(A),
        .B(B),
        .result(result),
        .overflow(overflow)
    );

    integer f; // Declare file handle outside procedural block

    initial begin
        $display("Starting testbench for 32-bit signed subtraction...");
        error = 0;

        test_vals[0] = 0;
        test_vals[1] = 1;
        test_vals[2] = -1;
        test_vals[3] = 32'sd2147483647;
        test_vals[4] = -32'sd2147483648;
        test_vals[5] = 32'sd2147483646;
        test_vals[6] = -32'sd2147483647;
        test_vals[7] = 32'sd1073741824;
        test_vals[8] = -32'sd1073741824;

        for (i = 0; i < 9; i = i + 1) begin
            for (j = 0; j < 9; j = j + 1) begin
                A = test_vals[i];
                B = test_vals[j];
                #5;
                neg_b = ~B + 1;
                res = A + neg_b;
                expected_ovf = (A[31] == neg_b[31]) && (res[31] != A[31]);

                if (result !== (A - B) || overflow !== expected_ovf) begin
                    error = error + 1;
                    $display("FAIL: A=%0d, B=%0d | Expected=%0d, Got=%0d | Overflow Expected=%b, Got=%b",
                             A, B, A - B, result, expected_ovf, overflow);
                end
            end
        end

        f = $fopen("test_result.txt", "w");
        if (error == 0) begin
            $display("All 32-bit tests passed successfully!");
            $fdisplay(f, "PASS");
        end else begin
            $display("%0d tests failed in 32-bit testbench.", error);
            $fdisplay(f, "FAIL");
        end
        $fclose(f);

        $finish;
    end

endmodule
