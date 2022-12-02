`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2022 17:36:31
// Design Name: 
// Module Name: Traffic_Junction
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


module Traffic_Junction(
    input CLK_100MHZ,
    input clk_20khz,
    input clk_200hz,
    input clk_1hz,
    input btnU,
    input [11:0] sample,
    input [12:0] my_pixel_index,
    input is_above_freq,
    output [15:0] oled_data,
    output [3:0] an,
    output [6:0] seg
    );
    
    // To check whether a vehicle is by the lanes, waiting for their traffic light to go green
    // Also checks if the pedestrians have pressed the crossing button (btnD)
    // Once either detected, wait at least 5 seconds before it sends that there is traffic at the bototm
    // bottom lane to be detected by J_MIC3_1
    wire traffic_bottom;
    Traffic_Detector traffic_detector_bottom (.clk_20khz(clk_20khz), .sample(sample), .has_pedestrians(btnU), .has_traffic(traffic_bottom));

    // Actions for the traffic light and pedestrian crossing to perform
    // Traffic light colour to change according to the following values stored
    // green light with emergency vehicle => 2'b11 green light => 2'b10, yellow light => 2'b01, red light => 2'b00
    wire [6:0] char_xpos;
    wire [5:0] char_ypos;
    wire [6:0] person_xpos;
    wire [5:0] person_ypos;
    wire direction;
    wire walk;
    wire emergency;
    wire [2:0] cases;
   
    // TODO: to update this with the extra parameters needed!!!
    Traffic_Light_Control traffic_light_control (.CLK_100MHZ(CLK_100MHZ), .clk_200hz(clk_200hz), .clk_1hz(clk_1hz), .has_emergency(is_above_freq), .has_traffic(traffic_bottom), .an(an), .seg(seg), .char_xpos(char_xpos), .char_ypos(char_ypos), .person_xpos(person_xpos), .person_ypos(person_ypos), .direction(direction), .walk(walk), .emergency(emergency), .cases(cases));
    
    // Display on PModOled the simulation of the traffic based on the above modules
    
    // TODO: to input the required inputs and outputs needed!!!
    Traffic_Light_Simulation traffic_light_simulation (.CLK_100MHZ(CLK_100MHZ), .clk_1hz(clk_1hz), .my_pixel_index(my_pixel_index), .char_xpos(char_xpos), .char_ypos(char_ypos), .person_xpos(person_xpos), .person_ypos(person_ypos), .direction(direction), .walk(walk), .cases(cases), .emergency(emergency), .oled_data(oled_data));
    
endmodule
