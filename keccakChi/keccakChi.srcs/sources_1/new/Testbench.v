`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2026 06:21:03 PM
// Design Name: 
// Module Name: Testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Testbench(
        
    );
    
    reg [1599 : 0] state_in;
    wire [1599 : 0] state_out;
    
    chi chiModule(
        .state_in1 (state_in),
        .state_out1 (state_out)
    );
    
    integer i;
    reg [1599 : 0] reversedIn;
    reg [1599 : 0] reversedOut;
    initial begin        //From google AI:
        for (i = 0; i < 50; i = i + 1)
            state_in[32*i +: 32] = $random;

        #1000;
        
        for (i = 0; i < 1600; i = i + 1) begin
            reversedIn[i] = state_in[(1600-1) - i];
            reversedOut[i] = state_out[(1600-1) - i];
        end
        
        $display("Input: %h", reversedIn); //Reverse bit order
        $display("Output: %h", reversedOut);
        
        if(state_in == state_out) begin
            $display("States are equal!!!???");
        end
    end
endmodule
