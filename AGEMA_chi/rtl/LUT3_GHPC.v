/*
	* Des: this module mimic the behavior of a LUT3_GHPCx module
	* In this case, since the chi.v --> chi_xilinx_netlist_GHPCLL__d1.v --> LL mode --> 1 clk cycle delay
*/
/*
module LUT3_GHPC #(
    parameter low_latency = 1,
    parameter pipeline    = 1,
    parameter [7:0] INIT  = 8'hb4
)(
    input  [1:0] I0, I1, I2,
    input        clk,
    input  [7:0] r,
    output reg [1:0] O
);
    wire a = I0[0] ^ I0[1];
    wire b = I1[0] ^ I1[1];
    wire c = I2[0] ^ I2[1];
    wire func_out = INIT[{c,b,a}];

    reg func_reg, func_reg2;

    always @(posedge clk) begin
        if (low_latency == 1)
            func_reg <= func_out;
        else begin
            func_reg  <= func_out;
            func_reg2 <= func_reg;
        end
    end

    always @(*) begin
        if (low_latency == 1) begin
            O[0] = func_reg ^ r[0];
            O[1] = r[0];
        end else begin
            O[0] = func_reg2 ^ r[0];
            O[1] = r[0];
        end
    end
endmodule
*/

`timescale 1ns/1ps

module LUT3_GHPC #(
    parameter [7:0] INIT        = 8'h00,
    parameter low_latency = 1,
    parameter pipeline    = 1
)(
    input [1:0] I0,   // {I0_share1, I0_share0}
    input [1:0] I1,   // {I1_share1, I1_share0}
    input [1:0] I2,   // {I2_share1, I2_share0}
    input clk,
    input [7:0] r,    // Fresh randomness (8 bits for 3-input GHPC LL)
    output [1:0] O    // {O_share1,  O_share0}
);

    // Unpack Verilog 2-bit combined shares into share-0 and share-1 vectors
    // share0 -> in0, share1 -> in1
    wire [2:0] in0_shares = {I2[0], I1[0], I0[0]};
    wire [2:0] in1_shares = {I2[1], I1[1], I0[1]};

    wire [0:0] out0_share;
    wire [0:0] out1_share;

    // Instantiate AGEMA's VHDL GHPC_Gadget entity
    GHPC_Gadget ghpc_inst (
        .in0  (in0_shares),
        .in1  (in1_shares),
        .r    (r),
        .clk  (clk),
        .out0 (out0_share),
        .out1 (out1_share)
    );

    // Re-pack VHDL outputs back into Verilog 2-bit bus format {share1, share0}
    assign O = {out1_share[0], out0_share[0]};

endmodule
