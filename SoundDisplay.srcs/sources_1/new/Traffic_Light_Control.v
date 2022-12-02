`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2022 01:04:08
// Design Name: 
// Module Name: Traffic_Light_Control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Controls the colour of the traffic light for the top and bottom lane
//              upon receiving the signals for an emergency vechicle detected in the
//              bottom lane, or when there is a long enough wait by pedestrians/traffic
//              present
//              and outputs the according traffic light colour as well as the state
//              to be presented in the OLED
//              Also controls the 7 segment display showing the timing of the pedestrian
//              crossing, counts bottom lane pedestrian crossing from 10 to 0
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Traffic_Light_Control(
    input CLK_100MHZ, // freq used to detect whether there is a need to change traffic light colour
    input clk_200hz, // to allow for display of different values in the 7 segment display
    input clk_3hz, // to allow for a blinking effect to indicate last 5 seconds for crossing
    input clk_1hz, // to input a counter that counts every second
    input has_emergency, // indicates whether there is an emergency vehicle present to give way to
    input has_traffic, // indicates whether there is traffic in the lane and it is time for the traffic light to go green
    
    // to display the pedestrian crossing timing
    output reg [3:0] an = 4'b1111,
    output reg [6:0] seg = 7'b1111111,
    
    // to aid in the simulation of the traffic displayed in PModOled\
    output reg [6:0] char_xpos = 41, // controls vehilcle's relative x position
    output reg [5:0] char_ypos = 1, // controls vehicle's relative y position 
    output reg [6:0] person_xpos = 25, // controls pedestrian's relative x position
    output reg [5:0] person_ypos = 10, // controls pedestrian's relative y position
    output reg direction = 0, // controls when the ambulance takes a turn, 0 goes up, 1 is going right
    output reg walk = 0, // provides animation input for the pedestrian that is crossing
    output reg emergency = 0, // indicates if it was the emergency vehicle that caused the light to changed
    output reg [2:0] cases = 0 // the different traffic lights combinations to be simulated
    );
    
    
    reg [5:0] light_counter = 15;
    reg start_counter = 0; // to start the above counter
    
    // to ensure top lane goes green for at least 5s before it goes red again
    reg [3:0] top_lane_counter = 0; 
        
    // cases to indicate timing of the traffic light
    // 0 - 1 -> yellow light for Bottom, red light for Top
    // 1 - 2 -> yellow light Bottom, red light for Top
    // 3 - 10 -> red light for Bottom, green light for Top
    // 11 - 12 -> red light for Bottom, yellow light for Top
    // 13 -> red light for Bottom, green light for Top
    
//    // ensure that that what is detected is actually the emergency vehicle and not random noise
//    // ensure its constant sound of 1.5kHz for at least 1 second
//    parameter one_second_200hz = 200; // 200 counts for 1s in 200Hz
//    reg count_emergency = 0; // to count how long emergency sound is detected for
//    always @ (posedge clk_200hz) begin
//        if (has_emergency && has_traffic) begin
//            count_emergency <= count_emergency + 1;
//        end
//        else begin
//            count_emergency <= 0;
//        end
//    end
    
    // actions done in order to change the traffic lights
    always @ (posedge CLK_100MHZ) begin
        // check if the emergency sound is validated and can be constituted as an emergency (constant >= 1.5kHz sound for 1s)
//        if (count_emergency >= one_second_200hz) begin
//            emergency <= 1;
//        end
        // check if there is a need for lane 1 to go red and lane 2 to green
        if (light_counter == 13 && ((top_lane_counter == 0 && has_traffic) || (has_emergency && has_traffic))) begin // if ref light, 5s buffer is up and got traffic, or if red light and emergency vehicle is present
            start_counter <= 1;
            if (has_emergency)
                emergency <= 1;
        end
        else begin
            start_counter <= 0;   
        end 
        
        // reset emergency value once it is over ADDED THIS***
        if (light_counter == 0)
            emergency <= 0;
    end
    
    // to output the correct counter accordingly for the bottom and top traffic light
    always @ (posedge clk_1hz) begin
        // iterate through the light counter
        light_counter <= (light_counter == 13) ? 13 : light_counter - 1;
        
        // if the top lane just turned green, make sure it stays green for at least 5 seconds
        top_lane_counter <= (top_lane_counter == 0) ? 0 : top_lane_counter - 1;
        
        // start the counter when required
        if (start_counter && light_counter == 13)
            light_counter <= 12;
        
        // control the colour of the traffic light according to the counter
        if (light_counter == 13) begin
            cases <= 3'b000; // green on top, red on bottom
        end
        else if (light_counter >= 11) begin
            cases <= 3'b001; // yellow on top, red on bottom
        end
        else if (light_counter >= 2) begin
            cases <= 3'b010; // red on top, green on bottom
        end
        else if (light_counter >= 0) begin
            cases <= 3'b011;
            if (light_counter == 0) begin
                light_counter <= 13; // reset counter back to 13
                top_lane_counter <= 5; // to ensure top lane stays green for at least 5s
            end
        end
    end
    
//    reg switch_an = 1; // to switch between the different anodes
    
    // output the correct number sequence for the pedestrian crossing
    always @ (posedge clk_200hz) begin
        case (light_counter)
        1: begin
            an = 4'b1111;
            seg = 7'b1111111;
            #300000000
            an <= 4'b1110;
            seg <= 7'b1111001;
        end
        2: begin
            #50000
            an <= 4'b1110;
            seg <= 7'b0100100;
        end
        3: begin
            an = 4'b1111;
            seg = 7'b1111111;
            #300000000
            an <= 4'b1110;
            seg <= 7'b0110000;
        end
        4: begin
            an = 4'b1111;
            seg = 7'b1111111;
            #300000000
            an <= 4'b1110;
            seg <= 7'b0011001;
        end
        5: begin
            an = 4'b1111;
            seg = 7'b1111111;
            #300000000
            an <= 4'b1110;
            seg <= 7'b0010010;
        end
        6: begin
            an <= 4'b1110;
            seg <= 7'b0000010;
        end
        7: begin
            an <= 4'b1110;
            seg <= 7'b1111000;
        end
        8: begin
            an <= 4'b1110;
            seg <= 7'b0000000;
        end
        9: begin
            an <= 4'b1110;
            seg <= 7'b0010000;
        end
//        10: begin
//            if (switch_an) begin
//                // put the ones digit
//                an <= 4'b1110;
//                seg <= 7'b1000000;
//            end
//            else begin
//                // put the tens digit
//                an <= 4'b1101;
//                seg <= 7'b1111001;
//            end
//            switch_an <= ~switch_an;
//        end
        default: begin
            an <= 4'b1111; 
            seg <= 7'b1111111;
        end
        endcase    
    end
    
    // to provide movement to the animations once the bottom traffic light goes green
    always @ (posedge clk_1hz) begin
        
        if (light_counter > 5 && light_counter <= 10) begin // move the emergency vehicle up
            direction <= 0;
            char_ypos <= char_ypos + 7;
        end
        else if (light_counter > 0 && light_counter <= 5) begin // move the emergency vehicle right 
            direction <= 1;
            char_xpos <= char_xpos + 9;
        end
        else if (light_counter == 0) begin // end and reset the emergency vehicle to its starting position
            direction <= 0;
            char_xpos <= 41;
            char_ypos <= 1;
        end
       
        if (light_counter == 0) begin
            person_xpos <= 25;
            person_ypos <= 10;
        end
        else if(light_counter <= 9) begin
            person_ypos <= person_ypos + 7;
            walk <= !walk;
        end 
        
    end

endmodule
