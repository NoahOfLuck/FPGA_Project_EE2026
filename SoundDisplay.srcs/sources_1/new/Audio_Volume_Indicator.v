`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2022 23:16:08
// Design Name: 
// Module Name: Audio_Volume_Indicator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Module which performs basic task for team, audio volume indicator
//              Shows the required borders and rectangles based on the audio intensity
//              detected by PModMic
//              Action is performed accordingly when sw[2] is on, overrides sw[1] & sw[0] (individual tasks A & B)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Audio_Volume_Indicator(
    input CLK_100MHZ,
    input clk_20khz,
    input [11:0] sample,
    input [12:0] my_pixel_index,
    output reg [15:0] oled_data = 0,
    output reg [4:0] LD = 0,
    output reg [3:0] an = 4'b1111,
    output reg [6:0] seg = 6'b111111,
    output reg [11:0] maxNoise = 0
    );
    
    // to make my_pixel_data in terms of x and y coordinates
    wire [12:0] x_pix;
    assign x_pix = my_pixel_index % 96;
    wire [12:0] y_pix; 
    assign y_pix = my_pixel_index / 96;
    
//    reg [11:0] maxNoise = 0;
    reg [31:0] count = 0;
        
    always @ (posedge clk_20khz) begin
        count <= count + 1;
        // update the maximum amplitude detected
        if (maxNoise < sample)
            maxNoise <= sample;
        
        // to measure the volume of audio inputted into PModMic and output onto LED
        if (count == 2000) begin
            // send out to the LED
            if (maxNoise < 2400) begin // level 0: no clear audible sound
                LD[4:0] <= 5'b00000; 
                an <= 4'b1110; // on an0
                seg <= 7'b1000000; // number 0
            end
            else if (maxNoise < 2800) begin // level 1: very low volume
                LD[4:0] <= 5'b00001;
                an <= 4'b1101; // on an1
                seg <= 7'b1111001; // number 1
            end
            else if (maxNoise < 3200) begin // level 2: low volume
                LD[4:0] <= 5'b00011;
                an <= 4'b1011; // on an2
                seg <= 7'b0100100; // number 2
            end
            else if (maxNoise < 3600) begin // level 3: medium volume
                LD[4:0] <= 5'b00111;
                an <= 4'b0111; // on an3
                seg <= 7'b0110000; // number 3
            end
            else if (maxNoise < 4000) begin // level 4: high volume
                LD[4:0] <= 5'b01111;
                an <= 4'b1011; // on an2
                seg <= 7'b0011001; // number 4
            end
            else begin// level 5: very high volume
                LD[4:0] <= 5'b11111;
                an <= 4'b1101; // on an1
                seg <= 7'b0010010; // number 5
            end
            // reset the maxNoise and count
            maxNoise <= sample;
            count <= 0;
        end
    end
    
    // to output based on the volume level the required graphics onto PModOled
    always @ (posedge CLK_100MHZ) begin
        
        if (LD >= 5'b00001 && (((x_pix == 2 || x_pix == 93 || y_pix == 2 || y_pix == 61) && !(x_pix < 2 || x_pix > 93 || y_pix < 2 || y_pix > 61)) || ((x_pix > 42 && x_pix < 53) && (y_pix > 53 && y_pix < 59)))) begin
            oled_data <= 16'b1111_1000_0000_0000; // red outerborder & rectangle
        end
        else if (LD >= 5'b00011 && ((((x_pix >= 6 && x_pix <= 8) || (x_pix >= 87 && x_pix <= 89) || (y_pix >= 6 && y_pix <= 8) || (y_pix >= 55 && y_pix <= 57)) && !(x_pix < 6 || x_pix > 89 || y_pix < 6 || y_pix > 57)) || ((x_pix > 42 && x_pix < 53)&&(y_pix > 42 && y_pix < 48)))) begin
            oled_data <= 16'b1111_1100_0000_0000; // orange border & rectangle
        end
        else if (LD >= 5'b00111 && (x_pix == 11 || x_pix == 84 || y_pix == 11 || y_pix == 52) && !(x_pix < 11 || x_pix > 84 || y_pix < 11 || y_pix > 52)) begin
            oled_data <= 16'b0000_0111_1110_0000; // 1st green border
        end
        else if (LD >= 5'b00111 && (x_pix > 42 && x_pix < 53) && (y_pix > 33 && y_pix < 39)) begin
            oled_data <= 16'b0000_0111_1110_0000; // 1st green rectangle
        end
        else if (LD >= 5'b01111 && (x_pix == 14 || x_pix == 81 || y_pix == 14 || y_pix == 49) && !(x_pix < 14 || x_pix > 81 || y_pix < 14 || y_pix > 49)) begin
            oled_data <= 16'b0000_0111_1110_0000; // 2nd green border
        end
        else if (LD >= 5'b01111 && (x_pix > 42 && x_pix < 53) && ( y_pix > 24 && y_pix < 30)) begin
            oled_data <= 16'b0001_1111_1100_0011; // 2nd green rectangle
        end
        else if (LD >= 5'b11111 && (x_pix == 17 || x_pix == 78 || y_pix == 17 || y_pix == 46) && !(x_pix < 17 || x_pix > 78 || y_pix < 17 || y_pix > 46))
        begin
            oled_data <= 16'b0000_0111_1110_0000; // 3rd green border
        end
        else if (LD >= 5'b11111 && (x_pix > 42 && x_pix < 53) && (y_pix > 15 && y_pix < 21)) begin
            oled_data <= 16'b1100_0111_1111_0000; // 3rd green rectangle
        end
        else begin
            oled_data <= 0;
        end
    end
endmodule
