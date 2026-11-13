// GHPC_AND_reg.v
// AND gate followed by a D flip-flop.
// Direct conversion from GHPC_AND_reg.vhd.

module GHPC_AND_reg (
    input  wire input1,
    input  wire input2,
    input  wire clk,
    output reg  output
);
    wire value;
    assign value = input1 & input2;

    always @(posedge clk)
        output <= value;

endmodule
