module LUT3_GHPC #(
    parameter low_latency = 1,
    parameter pipeline = 1,
    parameter [7:0] INIT = 8'h00
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

    reg func_reg;
    always @(posedge clk)
        func_reg <= func_out;

    always @(*) begin
        O[0] = func_reg ^ r[0];
        O[1] = r[0];
    end
endmodule
