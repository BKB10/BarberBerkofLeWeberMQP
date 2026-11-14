// LUT3_GHPC.v
// Wrapper specific to GHPCLL (low_latency=1, 8 fresh bits).
// NOT the authors' cell (unavailable). Built from the authors' GHPC gadget Verilog + one INIT patch.
// Port bundles are {share1, share0}.
// Direct structural conversion from LUT3_GHPC.vhd (GHPCLL variant).

module LUT3_GHPC #(
    parameter integer INIT     = 0,
    parameter integer pipeline = 1,
    parameter integer low_latency = 1		// This is a dummy param for netlist
)(
    input  wire [1:0] I0,
    input  wire [1:0] I1,
    input  wire [1:0] I2,
    input  wire       clk,
    input  wire [7:0] r,          // 8 fresh bits (GHPCLL)
    output wire [1:0] O
);
    wire [2:0] x0, x1;
    wire [0:0] o0, o1;

    // Unpack share 0 and share 1
    assign x0 = {I2[0], I1[0], I0[0]};
    assign x1 = {I2[1], I1[1], I0[1]};

    GHPC_Gadget_LUT3 #(
        .in_size     (3),
        .out_size    (1),
        .low_latency (1),           // hardcoded GHPCLL
        .pipeline    (pipeline),
        .INIT        (INIT[7:0])
    ) g (
        .in0  (x0),
        .in1  (x1),
        .r    (r),
        .clk  (clk),
        .out0 (o0),
        .out1 (o1)
    );

    // Pack output: {share1, share0}
    assign O = {o1[0], o0[0]};

endmodule
