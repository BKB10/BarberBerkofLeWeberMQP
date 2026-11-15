/*
DUT: chi.v
Des: Random-constrained tb with Ref model
*/

`timescale 1ns/1ps

module tb_chi_preAGEMA;

    logic [1599:0] state_in1;
    logic [1599:0] state_out1;

    // DUT
    chi dut (
        .state_in1  (state_in1),
        .state_out1 (state_out1)
    );

    // ------------------------------------------------------------
    // Reference model for CHI
    // ------------------------------------------------------------
    function automatic [1599:0] chi_reference(
        input [1599:0] in_state
    );
        integer x, y, z;
        integer idx0, idx1, idx2;

        begin
            chi_reference = '0;

            for (x = 0; x < 5; x = x + 1) begin
                for (y = 0; y < 5; y = y + 1) begin
                    for (z = 0; z < 64; z = z + 1) begin

                        idx0 = 64 * (5*x + y) + z;
                        idx1 = 64 * (5*x + ((y+1) % 5)) + z;
                        idx2 = 64 * (5*x + ((y+2) % 5)) + z;

                        chi_reference[idx0] =
                            in_state[idx0] ^
                            ((~in_state[idx1]) & in_state[idx2]);

                    end
                end
            end
        end
    endfunction

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------
    logic [1599:0] expected;

    task automatic run_test(input [1599:0] test_input);
        begin
            state_in1 = test_input;

            // Allow combinational logic to settle
            #1;

            expected = chi_reference(test_input);

            if (state_out1 === expected) begin
                $display("PASS");
            end
            else begin
                $display("FAIL");
                $display("Input   = %0400h", test_input);
                $display("Expected= %0400h", expected);
                $display("Actual  = %0400h", state_out1);

                $fatal(1);
            end
        end
    endtask

    // ------------------------------------------------------------
    // Main test sequence
    // ------------------------------------------------------------
    initial begin

        $display("========================================");
        $display("        CHI TESTBENCH START");
        $display("========================================");

        // Test 1: all zeros
        run_test(1600'b0);

        // Test 2: all ones
        run_test({1600{1'b1}});

        // Test 3: alternating bits
        run_test({800{2'b10}});

        // Test 4: inverse alternating bits
        run_test({800{2'b01}});

        // Test 5: random input
        run_test({50{$urandom}});

        // Test 6: another random input
        run_test({50{$urandom}});

        // Test 7: another random input
        run_test({50{$urandom}});

        $display("========================================");
        $display("        ALL TESTS PASSED");
        $display("========================================");

        $finish;
    end

endmodule
