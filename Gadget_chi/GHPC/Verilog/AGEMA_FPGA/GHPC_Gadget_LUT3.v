// GHPC_Gadget_LUT3.v
// Direct structural conversion from GHPC_Gadget_LUT3.vhd.
// Changes vs original GHPC_Gadget.vhd preserved: entity name, INIT generic, Step1 instance.
// reg → GHPC_reg (renamed to avoid Verilog keyword conflict).

module GHPC_Gadget_LUT3 #(
    parameter integer in_size     = 3,
    parameter integer out_size    = 1,
    parameter integer low_latency = 1,
    parameter integer pipeline    = 1,
    parameter [7:0]   INIT        = 8'hb4
)(
    input  wire [in_size-1:0]                                 in0,
    input  wire [in_size-1:0]                                 in1,
    input  wire [out_size*(1+low_latency*(2**in_size-1))-1:0] r,
    input  wire                                               clk,
    output wire [out_size-1:0]                                out0,
    output wire [out_size-1:0]                                out1
);

    wire [in_size-1:0]              in1_reg;
    wire [out_size*(2**in_size)-1:0] Step1_reg;
    wire [out_size-1:0]             out0_mid;

    //-------------------------
    // GEN_in: register each in1 bit
    //-------------------------
    genvar I;
    generate
        for (I = 0; I < in_size; I = I + 1) begin : GEN_in
            GHPC_reg reg_ins1 (
                .clk (clk),
                .D   (in1[I]),
                .Q   (in1_reg[I])
            );
        end
    endgenerate

    //-------------------------
    // Step1
    //-------------------------
    GHPC_Step1_LUT3 #(
        .in_size     (in_size),
        .out_size    (out_size),
        .fresh_size  (out_size*(1+low_latency*(2**in_size-1))),
        .low_latency (low_latency),
        .pipeline    (pipeline),
        .INIT        (INIT)
    ) Step1_ins (
        .in0       (in0),
        .r         (r),
        .clk       (clk),
        .Step1_reg (Step1_reg)
    );

    //-------------------------
    // Step2
    //-------------------------
    GHPC_Step2 #(
        .in_size     (in_size),
        .out_size    (out_size),
        .low_latency (low_latency),
        .pipeline    (pipeline)
    ) Step2_inst (
        .Step1_reg (Step1_reg),
        .input_sel (in1_reg),
        .clk       (clk),
        .out       (out1)
    );

    //-------------------------
    // GEN_out: out0 path
    //-------------------------
    genvar X;
    generate
        for (X = 0; X < out_size; X = X + 1) begin : GEN_out
            if (low_latency == 0) begin : GEN_normal
                wire out0_mid_X;
                GHPC_reg reg_out0_ins1 (
                    .clk (clk),
                    .D   (r[X]),
                    .Q   (out0_mid_X)
                );
                GHPC_reg reg_out0_ins2 (
                    .clk (clk),
                    .D   (out0_mid_X),
                    .Q   (out0[X])
                );
            end else begin : GEN_LL
                wire out0_mid_X;
                assign out0_mid_X = r[X*(2**in_size) + in1];
                GHPC_reg reg_out0_ins2 (
                    .clk (clk),
                    .D   (out0_mid_X),
                    .Q   (out0[X])
                );
            end
        end
    endgenerate

endmodule
