`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2022 20:33:08
// Design Name: 
// Module Name: DFF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: acts as a D-Flipflop
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// D-Flipflop

module DFF(
    input clk,
    input d,
    output reg q = 0
    );
    
    always @ (posedge clk) begin
        q <= d;
    end
endmodule
