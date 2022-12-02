`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2022 22:23:13
// Design Name: 
// Module Name: Oled_Task_A
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Module which performs OLED Task A
// Has red and orange outer border, with each btnU press, a green border should appear, followed by a 3s buffer
// up to 4 green borders
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Oled_Task_A(
    input CLK_100MHZ,
    input btnU,
    input [12:0] my_pixel_index,
    output reg [15:0] oled_data = 0,
    output reg LD14
    );
    
    // to make my_pixel_data in terms of x and y coordinates
    wire [12:0] x_pix;
    assign x_pix = my_pixel_index % 96;
    wire [12:0] y_pix; 
    assign y_pix = my_pixel_index / 96;
    
    // to control what happens upon pressing the button
    reg [2:0] btnU_count = 0; // to count how many times btnU is pressed 
    reg [31:0] count_3s = 0; // counter using 100MHz clock to get 3s => 299 999 999
    reg is_unpressed = 0; // 1 if btnU is not pressed anymore, 0 if it is, check whether button is held down or lifted
    
    // to control the borders on the screen via the button count
    always @ (posedge CLK_100MHZ) begin
        // if btnU is pressed and count_3s is not ongoing, detect btn press
        if (btnU && !count_3s && is_unpressed) begin
            btnU_count <= (btnU_count == 4) ? 0 : btnU_count + 1;
            count_3s <= 1; // start the 3s counter
        end
        
        // when button is pressed, count_3s will increment, and led14 lights up
        if (count_3s) begin
            count_3s <= (count_3s == 299999999) ? 0 : count_3s + 1;
            LD14 <= 1;
        end
        else begin
            LD14 <= 0;
            is_unpressed = ~btnU;
        end
    end

    //    assign oled_data based on what the my_pixel_index is
    always @ (posedge CLK_100MHZ) begin
        if ((x_pix == 2 || x_pix == 93 || y_pix == 2 || y_pix == 61) && !(x_pix < 2 || x_pix > 93 || y_pix < 2 || y_pix > 61)) begin
            oled_data <= 16'b1111_1000_0000_0000; // red outerborder
        end
        else if (((x_pix >= 6 && x_pix <= 8) || (x_pix >= 87 && x_pix <= 89) || (y_pix >= 6 && y_pix <= 8) || (y_pix >= 55 && y_pix <= 57)) && !(x_pix < 6 || x_pix > 89 || y_pix < 6 || y_pix > 57)) begin
            oled_data <= 16'b1111_1100_0000_0000; // orange border
        end
        else if (btnU_count >= 1 && (x_pix == 11 || x_pix == 84 || y_pix == 11 || y_pix == 52) && !(x_pix < 11 || x_pix > 84 || y_pix < 11 || y_pix > 52)) begin
            oled_data <= 16'b0000_0111_1110_0000; // 1st green border
        end
        else if (btnU_count >= 2 && (x_pix == 14 || x_pix == 81 || y_pix == 14 || y_pix == 49) && !(x_pix < 14 || x_pix > 81 || y_pix < 14 || y_pix > 49)) begin
            oled_data <= 16'b0000_0111_1110_0000; // 2nd green border
        end
        else if (btnU_count >= 3 && (x_pix == 17 || x_pix == 78 || y_pix == 17 || y_pix == 46) && !(x_pix < 17 || x_pix > 78 || y_pix < 17 || y_pix > 46)) begin
            oled_data <= 16'b0000_0111_1110_0000; // 3rd green border
        end
        else if (btnU_count >= 4 && (x_pix == 20 || x_pix == 75 || y_pix == 20 || y_pix == 43) && !(x_pix < 20 || x_pix > 75 || y_pix < 20 || y_pix > 43)) begin
            oled_data <= 16'b0000_0111_1110_0000; // 4th green border
        end
        else begin
            oled_data <= 0;
        end
    end

    
endmodule
