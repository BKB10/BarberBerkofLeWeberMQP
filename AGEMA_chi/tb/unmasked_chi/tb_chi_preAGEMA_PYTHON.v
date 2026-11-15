/*
Description: Simply took the input from SimpleChi.py and tested it with chi.v
Result: FAILED
Cause: chi.v and SimpleChi.py processes the input differently in terms of Endian-ess
*/

`timescale 1ns/1ps

module tb_chi_preAGEMA_directed;

    reg  [1599:0] state_in1;
    wire [1599:0] state_out1;

    integer i;
    integer first_mismatch;
    integer mismatch_count;

    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------
    chi dut (
        .state_in1  (state_in1),
        .state_out1 (state_out1)
    );

    // ------------------------------------------------------------
    // Input from Python reference model
    // ------------------------------------------------------------
    localparam [1599:0] INPUT_VECTOR =
        1600'h24aca848817a9103906b2121c66a0f8db0de9d60b199fb62a621434d484aec9180c7cf00b0b3eb606e8fc4dcbcb3b178b7ea2b6e31efb4629f97bf3e6324ecc7a321ef47554bc8aba7eff54eee4e4bdd486b4c91f1db37e24f960c9e73696ee7175e002fa37253473a921a74bd14717bb41ad569a664e54dc646f78d50e1cea00144dc030484260855a21eaab9333373697c04d3c81dc191b01c3d61ca6be595d6bbf9acab5465574052e881757c6aebb897ff70f34ea3e7c492218850a690a05350cea73c328c79;

    // ------------------------------------------------------------
    // Expected output from Python reference model
    // ------------------------------------------------------------
    localparam [1599:0] EXPECTED_VECTOR =
        1600'h04383408b0eb6161964a632c8e280b1cb01811600128f802820963054902fc921084ce21f6b3e5ec669a50ccfeb3f9fd97ca6b2f25a4b44a9b59af36c920ef93eb21efd745fa788b368fde6cef024fdf58234cb071c926e2671616ce6f6d4edf9356c526a112d74372f312e4ec8f63d9b38ed567a444ad4892e4f525e9d2dfd32918dc524488e688c5a2278abb5117772f3ec65fd89dcbb1b11c3563ce6fc59d6e3eeedc2956e4530452e80975dc7aebabd73157df5eafbe40391080d3e2f1a65310cea6681a86d1;

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------
    initial begin

        $display("========================================");
        $display("        CHI PRE-AGEMA DIRECTED TEST");
        $display("========================================");

        state_in1 = INPUT_VECTOR;

        // Allow combinational logic to settle
        #1;

        $display("Input    : %0400h", state_in1);
        $display("Expected : %0400h", EXPECTED_VECTOR);
        $display("Actual   : %0400h", state_out1);

        mismatch_count = 0;
        first_mismatch = -1;

        for (i = 0; i < 1600; i = i + 1) begin
            if (state_out1[i] !== EXPECTED_VECTOR[i]) begin
                mismatch_count = mismatch_count + 1;

                if (first_mismatch == -1)
                    first_mismatch = i;
            end
        end

        if (mismatch_count == 0) begin
            $display("");
            $display("PASS: CHI output matches Python reference.");
        end
        else begin
            $display("");
            $display("FAIL: CHI output does NOT match Python reference.");
            $display("Number of mismatched bits = %0d", mismatch_count);
            $display("First mismatch at bit       = %0d", first_mismatch);
            $display("Actual bit                  = %b",
                     state_out1[first_mismatch]);
            $display("Expected bit                = %b",
                     EXPECTED_VECTOR[first_mismatch]);

            $fatal(1);
        end

        $display("========================================");

        $finish;
    end

endmodule
