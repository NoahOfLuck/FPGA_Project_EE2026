`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2022 20:36:33
// Design Name: 
// Module Name: Debounce_Button
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: usage of single pulse to debounce button press,
//              makes use of DFF to implement
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Debounce_Button(
    input clk,
    input btn,
    output debounced_btn
    );
    wire q1;
    wire q2;
    
    DFF dff_1 (.clk(clk), .d(btn), .q(q1));
    DFF dff_2 (.clk(clk), .d(q1), .q(q2));
    
    assign debounced_btn = q1 & q2;
endmodule
