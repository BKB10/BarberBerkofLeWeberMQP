`timescale 1ns/1ps
// tb_chi_GHPC.v
// Validates chi_xilinx_netlist_GHPC__d1.v against unmasked golden chi.v
// GHPC variant: low_latency=0, Fresh=1600 bits, 2-cycle latency.

module tb_chi_GHPC;

    parameter N_TESTS = 100;

    reg  [1599:0] state_in;
    reg  [1599:0] s0;
    reg  [1599:0] s1;
    reg  [1599:0] Fresh;
    reg           clk;

    wire [1599:0] golden_out;
    wire [1599:0] mo0, mo1;
    wire [1599:0] masked_out;

    integer errors = 0;
    integer i, j;
    integer seed = 42;

    initial clk = 0;
    always #5 clk = ~clk;

    // Unmasked golden model
    chi golden (
        .state_in1  (state_in),
        .state_out1 (golden_out)
    );

    // Masked DUT
    chi_GHPC__d1 dut (
        .clk           (clk),
        .state_in1_s0  (s0),
        .state_in1_s1  (s1),
        .Fresh         (Fresh),
        .state_out1_s0 (mo0),
        .state_out1_s1 (mo1)
    );

    // Unmask output
    assign masked_out = mo0 ^ mo1;

    // Randomize 1600-bit vector chunk by chunk
    task randomize_reg;
        output [1599:0] vec;
        integer k;
        begin
            for (k = 0; k < 50; k = k + 1)
                vec[k*32 +: 32] = $random(seed);
        end
    endtask

    // Apply inputs and check after 2 cycles (GHPC latency)
    task run_vector;
        begin
            @(negedge clk);

            // Generate random state_in and shares
            randomize_reg(s0);
            randomize_reg(state_in);
            s1 = state_in ^ s0;

            // Generate random Fresh (1600 bits for GHPC)
            randomize_reg(Fresh);

            // Wait 2 clock cycles (GHPC: 2 pipeline stages)
            @(posedge clk); #1;
            @(posedge clk); #1;

            // Compare
            if (masked_out !== golden_out) begin
                $display("MISMATCH at vector %0d: masked_out=%h golden_out=%h",
                    i, masked_out, golden_out);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        state_in = 0; s0 = 0; s1 = 0; Fresh = 0;

        // Reset: wait 2 cycles
        @(posedge clk); #1;
        @(posedge clk); #1;

        // Run test vectors
        for (i = 0; i < N_TESTS; i = i + 1)
            run_vector();

        // Summary
        if (errors == 0)
            $display("PASS: %0d vectors matched.", N_TESTS);
        else
            $display("FAIL: %0d mismatches detected.", errors);

        $finish;
    end

endmodule
