// GHPC_Step1_LUT3.v
// Direct structural conversion from GHPC_Step1_LUT3.vhd.
// Changes vs original GHPC_Step1.vhd preserved: entity name, INIT generic, FuncOut lookup.
// reg → GHPC_reg (renamed to avoid Verilog keyword conflict).

`timescale 1ns/1ps

module GHPC_Step1_LUT3 #(
    parameter integer in_size     = 3,
    parameter integer out_size    = 1,
    parameter integer fresh_size  = 8,
    parameter integer low_latency = 1,
    parameter integer pipeline    = 1,
    parameter [2**in_size-1:0] INIT = 8'hb4
)(
    input  wire [in_size-1:0]                in0,
    input  wire [fresh_size-1:0]             r,
    input  wire                              clk,
    output wire [out_size*(2**in_size)-1:0]  Step1_reg
);

    // in0_comb: for each minterm I, complemented/non-complemented version of in0
    wire [in_size-1:0]  in0_comb [0:2**in_size-1];

    // FuncOut: INIT lookup result per minterm
    wire                FuncOut  [0:2**in_size-1][0:out_size-1];

    // Step1: XOR with fresh randomness before register
    wire                Step1    [0:out_size-1][0:2**in_size-1];

    genvar I, J, X;

    //-------------------------
    // GEN_in0_comb + FuncOut (INIT lookup)
    //-------------------------
    generate
        for (I = 0; I < 2**in_size; I = I + 1) begin : GEN_in0_comb
            for (J = 0; J < in_size; J = J + 1) begin : GEN_in0_bit
                // GetBit(I, in_size, J): bit J of integer I
                assign in0_comb[I][J] = ((I >> J) & 1) ? ~in0[J] : in0[J];
            end
            // INIT_N(unsigned(in0_comb(I))) → INIT indexed by in0_comb
            assign FuncOut[I][0] = INIT[in0_comb[I]];
        end
    endgenerate

    //-------------------------
    // GEN_out: XOR with r, then register
    //-------------------------
    generate
        for (X = 0; X < out_size; X = X + 1) begin : GEN_out
            for (I = 0; I < 2**in_size; I = I + 1) begin : GEN_Step1_1
                wire step1_in;

                if (low_latency == 0) begin : GEN_normal
                    assign step1_in = r[X] ^ FuncOut[I][X];
                end else begin : GEN_LL
                    assign step1_in = r[I + X*(2**in_size)] ^ FuncOut[I][X];
                end

                GHPC_reg reg_ins (
                    .clk (clk),
                    .D   (step1_in),
                    .Q   (Step1_reg[X*(2**in_size) + I])
                );
            end
        end
    endgenerate

endmodule
