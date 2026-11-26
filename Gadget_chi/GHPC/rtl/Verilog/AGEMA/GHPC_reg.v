// reg.v
// Behavioral model of a single-bit D flip-flop.
// Direct conversion from reg.vhd (GHPC_reg.vhd).

`timescale 1ns/1ps

module GHPC_reg (
    input  wire clk,
    input  wire D,
    output reg  Q
);
    always @(posedge clk)
        Q <= D;

endmodule
