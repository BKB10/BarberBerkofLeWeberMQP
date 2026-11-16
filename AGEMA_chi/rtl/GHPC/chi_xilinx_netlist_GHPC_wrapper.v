// chi_xilinx_netlist_GHPC_wrapper.v
module chi_xilinx_netlist_GHPC_wrapper (
    input  wire clk,
    input  wire rst,
    output wire result    // prevents logic optimization
);
    wire [1599:0] state_in_s0;
    wire [1599:0] state_in_s1;
    wire [1599:0] Fresh;
    wire [1599:0] out_s0;
    wire [1599:0] out_s1;

    // LFSR for state_in_s0 (1600 × 1-bit LFSR)
    genvar i;
    generate
        for (i = 0; i < 1600; i = i + 1) begin : GEN_STATE_S0
            LFSR31 lfsr_s0 (.clk(clk), .rst(rst), .out(state_in_s0[i]));
        end
        for (i = 0; i < 1600; i = i + 1) begin : GEN_STATE_S1
            LFSR31 lfsr_s1 (.clk(clk), .rst(rst), .out(state_in_s1[i]));
        end
        for (i = 0; i < 1600; i = i + 1) begin : GEN_FRESH
            LFSR31 lfsr_f  (.clk(clk), .rst(rst), .out(Fresh[i]));
        end
    endgenerate

    // Chi block
    chi_GHPC__d1 chi_inst (
        .clk           (clk),
        .state_in1_s0  (state_in_s0),
        .state_in1_s1  (state_in_s1),
        .Fresh         (Fresh),
        .state_out1_s0 (out_s0),
        .state_out1_s1 (out_s1)
    );

    // Prevent optimization
    assign result = ^(out_s0 ^ out_s1);

endmodule
