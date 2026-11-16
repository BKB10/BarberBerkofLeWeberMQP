`timescale 1ns/1ps
// LFSR31.v
// 31-bit LFSR based on paper: "Spin Me Right Round"
// Implemented as: 1 XOR LUT + 2 SRL16E (3 LUTs total per paper)
// Primitive polynomial: x^31 + x^3 + 1

module LFSR31 (
    input  wire clk,
    input  wire rst,
    output wire out
);
    reg [30:0] state;

    always @(posedge clk) begin
        if (rst)
            state <= 31'h7FFFFFFF;    // non-zero seed
        else
            state <= {state[29:0], state[30] ^ state[2]};
    end

    assign out = state[30];

endmodule
