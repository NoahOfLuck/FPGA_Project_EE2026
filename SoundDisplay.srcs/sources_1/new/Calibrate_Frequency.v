`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2022 19:18:47
// Design Name: 
// Module Name: Calibrate_Frequency
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


module Calibrate_Frequency(
    input CLK_100MHZ, // basys3 clock
    input clk_20khz, // freq inputted, matches audio sample freq of 20kHz
    input on_calibration, // switch to indicate when to calibrate the frequency
    input [11:0] sample, // sample obtained from the PMODMIC connected
    input [11:0] maxNoise, // maximum value obtained from audio volume indicator
    output reg [31:0] count_threshold = 14, // stores calibrated count which results in the desired frequency, initially starts at 1.5kHz
    output reg is_above_freq = 0 // 1 indicates if it passes the given freq, 0 if it does not pass the required frequency
    );
        
    parameter [11:0] amp_zeropoint = 3072; // the zeropoint: middle point of the possible range of the sample output
    
    // stores the current and previous samples obtained
    reg[11:0] curr_sample = 1;
    reg[11:0] prev_sample = 0;
    
    // indicates the number of samples taken since it last crossed the zero point
    // time corresponds to when curr_sample and prev_sample are taken respectively
    reg [31:0] time_curr_sample = 0;
    reg [31:0] time_prev_sample = 0;
    
    // store the last known count taken for sample to reach the zero point again
    reg [31:0] last_time_count = 0;
    
    // we check how long it takes for the sample to cross the zero point
    always @ (posedge clk_20khz) begin
        // measure the next sample
        prev_sample <= curr_sample;
        curr_sample <= sample;
        
        // update its time
        time_prev_sample <= time_curr_sample;
        time_curr_sample <= time_curr_sample + 1;
        
        // check whether sample has crossed the zero point
//        if ((prev_sample >= amp_zeropoint && curr_sample <= amp_zeropoint) || (prev_sample <= amp_zeropoint && curr_sample >= amp_zeropoint)) begin
        if (prev_sample <= amp_zeropoint && curr_sample > amp_zeropoint) begin // only look at the posedge at which the wave crosses the zero point
            // sample has crossed the zero point, store and reset the count
            last_time_count <= time_curr_sample;
            time_prev_sample <= 0; // account for the update of sample values
            time_curr_sample <= 1; // account for the update of sample values
        end
    end
    
    // toggle between detection mode and calibration mode
    always @ (posedge clk_20khz) begin
        if (on_calibration) begin
            // off detection of frequency
            is_above_freq <= 0;
            
            // store the measured value of what is being detected
            count_threshold <= last_time_count;
        end
        else begin // to detect with the latest callibrated frequency
            // check whether frequency measured is >= calibrated frequency
                // the time between 2 zero points == 1/2 period
                // hence (1/20k)s * last_time_count corresponds to frequency calibrated
            if (last_time_count <= count_threshold && maxNoise > 3500)
                is_above_freq <= 1;
            else
                is_above_freq <= 0;
        end
    end
        
    
endmodule