`timescale 1ns/1ps

module tb_LUT3_GHPCLL;

    parameter INIT    = 180;
    parameter N_TESTS = 1000;
    parameter LOW_LATENCY_GHPCLL = 1;

    reg  [1:0] I0, I1, I2;
    reg        clk;
    reg  [7:0] r;              // 8 fresh bits (GHPCLL)
    wire [1:0] O_vlog;
    wire [1:0] O_vhdl;

    integer errors = 0;
    integer i;
    integer seed = 42;

    initial clk = 0;
    always #5 clk = ~clk;

    // Verilog DUT
    LUT3_GHPC #(
	    .INIT(INIT), 
	    .pipeline(1),
	    .low_latency(LOW_LATENCY_GHPCLL)
    ) dut_vlog (
        .I0(I0), 
	.I1(I1), 
	.I2(I2), 
	.clk(clk), 
	.r(r), 
	.O(O_vlog)
    );

    // VHDL golden
    LUT3_GHPC_vhdl #(
	    .INIT(INIT), 
	    .pipeline(1),
	    .low_latency(LOW_LATENCY_GHPCLL)
    ) dut_vhdl (
        .I0(I0), 
	.I1(I1), 
	.I2(I2), 
	.clk(clk), 
	.r(r), 
	.O(O_vhdl)
    );

    task run_vector;
        input [1:0] i0_in, i1_in, i2_in;
        input [7:0] r_in;
        begin
            @(negedge clk);
            I0 = i0_in;
            I1 = i1_in;
            I2 = i2_in;
            r  = r_in;
            @(posedge clk); #1;    // 1 cycle latency (GHPCLL)
            if (O_vlog !== O_vhdl) begin
                $display("MISMATCH: I0=%b I1=%b I2=%b r=%b Vlog=%b Vhdl=%b",
                    i0_in, i1_in, i2_in, r_in, O_vlog, O_vhdl);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        I0 = 0; I1 = 0; I2 = 0; r = 0;
        @(posedge clk); #1;        // 1 cycle reset (GHPCLL)

        for (i = 0; i < N_TESTS; i = i + 1) begin
            run_vector(
                $random(seed) & 2'b11,
                $random(seed) & 2'b11,
                $random(seed) & 2'b11,
                $random(seed) & 8'hff    // 8 fresh bits
            );
        end

        if (errors == 0)
            $display("PASS: %0d vectors matched.", N_TESTS);
        else
            $display("FAIL: %0d mismatches.", errors);

        $finish;
    end

endmodule
