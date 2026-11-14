`timescale 1ns/1ps

module tb_LUT3_GHPC;

    parameter INIT    = 180;
    parameter N_TESTS = 1000;
    parameter LOW_LATENCY_GHPC = 0;

    reg [1:0] I0, I1, I2;
    reg clk;
    reg r;
    wire [1:0] O_vlog;
    wire [1:0] O_vhdl;

    integer errors = 0;
    integer i;
    integer seed = 42;

    // clk generation
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Verilog DUT
    LUT3_GHPC #(
	    .INIT(INIT), 
	    .pipeline(1),
	    .low_latency(LOW_LATENCY_GHPC)	
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
	    .low_latency(LOW_LATENCY_GHPC)
    ) dut_vhdl (
        .I0(I0), 
	.I1(I1), 
	.I2(I2), 
	.clk(clk), 
	.r(r), 
	.O(O_vhdl)
    );

    // Apply inputs and check after 2 cycles (GHPC --> 2 cycles delay)
    task run_vector;
        input [1:0] i0_in, i1_in, i2_in;
        input [0:0] r_in;
        begin
            @(negedge clk);
            I0 = i0_in;
            I1 = i1_in;
            I2 = i2_in;
            r  = r_in;
            @(posedge clk); #1;
            @(posedge clk); #1;
            if (O_vlog !== O_vhdl) begin
                $display("MISMATCH: I0=%b I1=%b I2=%b r=%b Vlog=%b Vhdl=%b",
                    i0_in, i1_in, i2_in, r_in, O_vlog, O_vhdl);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        I0 = 0; I1 = 0; I2 = 0; r = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;

        // Random vectors
        for (i = 0; i < N_TESTS; i = i + 1) begin
            run_vector(
                $random(seed) & 2'b11,
                $random(seed) & 2'b11,
                $random(seed) & 2'b11,
                $random(seed) & 1'b1
            );
        end

        if (errors == 0)
            $display("PASS: %0d vectors matched.", N_TESTS);
        else
            $display("FAIL: %0d mismatches.", errors);

        $finish;
    end

endmodule
