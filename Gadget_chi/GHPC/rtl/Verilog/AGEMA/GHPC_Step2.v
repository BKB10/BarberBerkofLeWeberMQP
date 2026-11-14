// GHPC_Step2.v
// Direct structural conversion from GHPC_Step2.vhd.
// Preserves low_latency parameter — no splitting.

module GHPC_Step2 #(
    parameter in_size    = 3,
    parameter out_size   = 1,
    parameter low_latency = 1,
    parameter pipeline   = 0
)(
    input  wire [out_size*(2**in_size)-1:0] Step1_reg,
    input  wire [in_size-1:0]               input_sel,
    input  wire                             clk,
    output reg  [out_size-1:0]              out
);
    wire [2**in_size-1:0] in_comb;
    wire [out_size*(2**in_size)-1:0] Step2_reg;

    genvar I, X;
    generate
        if (low_latency == 0) begin : GEN_normal
            // One-hot encode input_sel
            for (I = 0; I < 2**in_size; I = I + 1) begin : GEN_in_comb
                assign in_comb[I] = (input_sel == I[in_size-1:0]) ? 1'b1 : 1'b0;
            end
            // AND + register via GHPC_AND_reg
            for (X = 0; X < out_size; X = X + 1) begin : GEN_out
                for (I = 0; I < 2**in_size; I = I + 1) begin : GEN_Step2
                    GHPC_AND_reg and_reg_inst (
                        .input1   (in_comb[I]),
                        .input2   (Step1_reg[X*(2**in_size) + I]),
                        .clk (clk),
                        .Q   (Step2_reg[X*(2**in_size) + I])
                    );
                end
                // XOR reduction
                assign out[X] = ^Step2_reg[X*(2**in_size) +: 2**in_size];
            end
        end else begin : GEN_LL
            // Combinational mux
            for (X = 0; X < out_size; X = X + 1) begin : GEN_out
                assign out[X] = Step1_reg[X*(2**in_size) + input_sel];
            end
        end
    endgenerate

endmodule
