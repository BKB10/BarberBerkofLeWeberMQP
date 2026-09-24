`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2026 02:53:27 PM
// Design Name: 
// Module Name: chi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Added REQUIRED AGEMA Attribute
// 
//////////////////////////////////////////////////////////////////////////////////

//From hakatu on Github (https://github.com/hakatu/keccak-hw-prj/blob/42c21987ee44a6f12c9dd3daa7ce374eb2c32ac2/Keccak/AllworldSHA/chi.sv#L4):
module chi (
    (* AGEMA = "secure" *) input [1599:0] state_in1,
    // (* AGEMA = "secure" *) output [1599:0] state_out1
    output [1599:0] state_out1
);

genvar x, y, z;
generate
    //The first bit (bit 0) is printed on the right side of the hexadecimal number in the simulation output
    for (x = 0; x < 5; x = x + 1) begin
        for (y = 0; y < 5; y = y + 1) begin
            for (z = 0; z < 64; z = z + 1) begin
                assign state_out1[64 * (5 * x + y) + z] = state_in1[64 * (5 * x + y) + z] ^ ((~state_in1[64 * (5 * x + ((y + 1) % 5)) + z]) & state_in1[64 * (5 * x + ((y + 2) % 5)) + z]);
            end
        end
    end
endgenerate

endmodule

//From Claude Opus 5:
/*
module chi (
    input  wire [1599:0] state_in2,
    output wire [1599:0] state_out2
);

    genvar x, y;
    generate
        for (y = 0; y < 5; y = y + 1) begin : gen_plane
            for (x = 0; x < 5; x = x + 1) begin : gen_lane
                assign state_out2[64*(5*y + x) +: 64] =
                      state_in2[64*(5*y +  x         ) +: 64]
                    ^ (~state_in2[64*(5*y + (x+1) % 5) +: 64]
                     &  state_in2[64*(5*y + (x+2) % 5) +: 64]);
            end
        end
    endgenerate
endmodule
*/
