`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2022 23:33:00
// Design Name: 
// Module Name: Get_Clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: To generate the desired clock frequency from the basys3 clock of 100MHz
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Get_Clock(
    input CLK_100MHZ,
    input [31:0] m,
    output reg output_clk = 0
    );
    
    reg [31:0] count = 0;
    
    always @ (posedge CLK_100MHZ) begin
        count <= (count == m) ? 0 : count + 1;
        output_clk <= (count == 0) ? ~output_clk : output_clk;
    end
endmodule
