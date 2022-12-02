`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2022 15:06:39
// Design Name: 
// Module Name: Oled_Task_B
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


module Oled_Task_B(
    input CLK_100MHZ,
    input btnD,
    input [12:0] my_pixel_index,
    output reg [15:0] oled_data = 0,
    output reg LD12
    );
    
    // to make my_pixel_data in terms of x and y coordinates
    wire [12:0] x_pix;
    assign x_pix = my_pixel_index % 96;
    wire [12:0] y_pix; 
    assign y_pix = my_pixel_index / 96;
    
    // to control what happens upon pressing the button
    reg [2:0] btnD_count = 0; // to count how many times btnD is pressed
    reg [31:0] count_5s = 0; // counter using 100MHz clock to get 5s => 499 999 999
    reg is_unpressed = 0; // 1 if btnD is not pressed anymore, 0 if it is, check whether button is held down or lifted
    
    // to control the rectangles on the screen via the button count
    always @ (posedge CLK_100MHZ) begin
        
        // if btnD is pressed and count_5s is not ongoing, detect btn press
        if (btnD && !count_5s && is_unpressed) begin
            btnD_count <= (btnD_count == 3) ? 0 : btnD_count + 1;
            count_5s <= 1; // start the 5s counter;
        end
        
        // when button is pressed, count_5s will increment, and led12 will light up
        if (count_5s) begin
            count_5s <= (count_5s == 499999999) ? 0 : count_5s + 1;
            LD12 <= 1;
        end
        else begin
            LD12 <= 0;
            is_unpressed = ~btnD;
        end
    end
    
    // assign oled_data based on what the my_pixel_index is
    always @ (posedge CLK_100MHZ) begin
        if ((x_pix > 42 && x_pix < 53) && (y_pix > 53 && y_pix < 59)) begin
            oled_data <= 16'b1111_1000_0000_0000; // red rectangle
        end
        else if ((x_pix > 42 && x_pix < 53) && (y_pix > 42 && y_pix < 48)) begin
            oled_data <= 16'b1111_1100_0000_0000; // orange rectangle
        end
        else if (btnD_count >= 1 && (x_pix > 42 && x_pix < 53) && (y_pix > 33 && y_pix < 39)) begin
            oled_data <= 16'b0000_0111_1110_0000; // 1st green rectangle
        end
        else if (btnD_count >= 2 && (x_pix > 42 && x_pix < 53) && (y_pix > 24 && y_pix < 30)) begin
            oled_data <= 16'b0001_1111_1100_0011; // 2nd green rectangle
        end
        else if (btnD_count >= 3 && (x_pix > 42 && x_pix < 53) && (y_pix > 15 && y_pix < 21)) begin
            oled_data <= 16'b1100_0111_1111_0000; // 3rd green rectangle
        end
        else
            oled_data <= 0;
        
    end

endmodule
