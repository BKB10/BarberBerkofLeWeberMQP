// GHPC_AND_reg.v
module GHPC_AND_reg (
    input  wire input1,
    input  wire input2,
    input  wire clk,
    output reg  Q         // ← renamed from 'output'
);
    wire value;
    assign value = input1 & input2;

    always @(posedge clk)
        Q <= value;

endmodule
