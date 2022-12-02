`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2022 23:23:06
// Design Name: 
// Module Name: Traffic_Detector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: check if there is any traffic waiting for the lane's traffic 
//              light to go green, detects via checking if there if peak 
//              amplitude of noise passes a minimum threshold 
//              (sampling above 3500)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Traffic_Detector(
        input clk_20khz, // sampling freq set to 20khz
        input [11:0] sample, // sample data storing the noise level detected by PModMic
        input has_pedestrians, // checks if there is a pedestrian crossing button press
        output reg has_traffic = 0 // indicates if there is traffic in the lane
    );
    
    // Detects whether the mic picked up any sound 1cm away from it (aka if there is traffic present)
    parameter [11:0] THRESHOLD = 3500; // indicates the minimum value maxAmp needs to constitute cars being there
    reg [31:0] count = 0; // to sample each time count is incremented, counts 2000 times
    reg [11:0] maxAmp = 0; // stores peak of amplitude within sample frame
    
    always @ (posedge clk_20khz) begin
        count <= (count == 2000) ? 0 : count + 1;
        // check for higher peak amplitude within same sample frame
        if (maxAmp < sample)
            maxAmp <= sample;
        
        if (count == 2000) begin
            // check if peak amplitude reaches threshold
            if (maxAmp >= THRESHOLD || has_pedestrians)
                has_traffic <= 1;
            else
                has_traffic <= 0;
            
            // move on to next sampling frame
            maxAmp <= 0; // reset maxAmp for next sampling frame
           
        end
    end
    
endmodule
