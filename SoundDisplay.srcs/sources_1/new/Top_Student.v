`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable): MONDAY P.M, TUESDAY P.M, WEDNESDAY P.M, THURSDAY A.M., THURSDAY P.M
//
//  STUDENT A NAME: Thomas Joseph Lee Alba
//  STUDENT A MATRICULATION NUMBER: A0238909N
//
//  STUDENT B NAME: Joshua Goh Min Rui
//  STUDENT B MATRICULATION NUMBER: 
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input CLK_100MHZ,
    input [15:0] sw,
    input btnC,
    input btnU,
    input btnL,
    input btnR,
    input btnD,
    output [15:0] led,
    output [3:0] an,
    output [6:0] seg,
    
    // PMODMIC connection - connected to JB pins
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,   // Connect to this signal from Audio_Capture.v
    
    // PMODOLED connection - connected to JC pins
    output [7:0] JC
    );


    // CLOCKS: the clocks that are generated and to be used in the project
    // 20kHz clock: used as the sample clock for PModMic
    parameter m_20khz = 2499; // m value to obtain 20kHz clock frequency
    wire clk_20khz; // to store clock of freq 20kHz
    Get_Clock get_clk_20khz(.CLK_100MHZ(CLK_100MHZ), .m(m_20khz), .output_clk(clk_20khz));     
    // 6.25MHz clock: used as the sample clock for PModOled
    parameter m_6p25Mhz = 7; // m value to obtain 6.25MHz
    wire clk_6p25Mhz; // to store clock of freq 6.25MHz
    Get_Clock get_clk_6p25Mhz(.CLK_100MHZ(CLK_100MHZ), .m(m_6p25Mhz), .output_clk(clk_6p25Mhz)); 

    // 25Hz clock: used for debouncing of button inputs
    parameter [31:0] m_25hz = 1999999;
    wire clk_25hz;
    Get_Clock get_clk_25hz(.CLK_100MHZ(CLK_100MHZ), .m(m_25hz), .output_clk(clk_25hz));

    // 1Hz clock: used as the clock for the traffic light to count each second
    parameter [31:0] m_1hz = 49999999;
    wire clk_1hz;
    Get_Clock get_clk_1hz(.CLK_100MHZ(CLK_100MHZ), .m(m_1hz), .output_clk(clk_1hz));
    // 200Hz clock: used to allow for multiple number displayed seperate anodes of the 7-segment display
    parameter m_200hz = 24999;
    wire clk_200hz;
    Get_Clock get_clk_200hz(.CLK_100MHZ(CLK_100MHZ), .m(m_200hz), .output_clk(clk_200hz));
    // 0.16Hz clock: used as the timing for toggling between menu items
    parameter m_0p16hz = 7999999;
    wire clk_0p16hz;
    Get_Clock get_clk_0p16hz(.CLK_100MHZ(CLK_100MHZ), .m(m_0p16hz), .output_clk(clk_0p16hz));

    
    // Debounce button inputs via using single pulse
    wire btnC_pulsed;
    Debounce_Button debounced_btnC (.clk(clk_25hz), .btn(btnC), .debounced_btn(btnC_pulsed)); 
    wire btnU_pulsed;
    Debounce_Button debounced_btnU (.clk(clk_25hz), .btn(btnU), .debounced_btn(btnU_pulsed));    
    wire btnL_pulsed;
    Debounce_Button debounced_btnL (.clk(clk_25hz), .btn(btnL), .debounced_btn(btnL_pulsed)); 
    wire btnR_pulsed;
    Debounce_Button debounced_btnR (.clk(clk_25hz), .btn(btnR), .debounced_btn(btnR_pulsed)); 
    wire btnD_pulsed;    
    Debounce_Button debounced_btnD (.clk(clk_25hz), .btn(btnD), .debounced_btn(btnD_pulsed));    

    // PMODMIC: to send and receive data from the microphone
    wire [11:0] sample;
    Audio_Capture audio_capture(.CLK(CLK_100MHZ), .cs(clk_20khz), .MISO(J_MIC3_Pin3), .clk_samp(J_MIC3_Pin1), .sclk(J_MIC3_Pin4), .sample(sample));

        
    // PMODOLED: to send and receive data from the oled
    wire [15:0] oled_data;
    wire [12:0] my_pixel_index;   
    // dummy wires
    wire frame_begin;
    wire send_pixels;
    wire sample_pixel;
    
    Oled_Display oled_display(.clk(clk_6p25Mhz), .reset(0), .frame_begin(frame_begin), .sending_pixels(send_pixels), .sample_pixel(sample_pixel), .pixel_index(my_pixel_index), .pixel_data(oled_data), .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]), .pmoden(JC[7]), .teststate(0));
 
    // MENU DISPLAY - to select the different modes we have made
    wire [15:0] oled_data_menu;
    reg [2:0] toggle_menu = 0;
    reg [2:0] current = 0;
    wire btnC_menu, btnU_menu, btnD_menu, btnL_menu, btnR_menu;
    
    // always block to control the menu selection
    always @ (posedge clk_0p16hz) begin
        if (sw[7]) begin
            toggle_menu <= 0;
        end
        if (btnC_menu) begin
            toggle_menu <= current;
        end
        if (btnL_menu) begin
            current <= (current == 0) ? current : current - 1;
        end
        if (btnR_menu) begin
            current <= (current == 3) ? current : current + 1;
        end
        if (btnU_menu) begin
            current = (current == 2 || current == 3) ? current - 2 : current;
        end
        if (btnD_menu) begin
            current = (current == 0 || current == 1) ? current + 2 : current;
        end
    end
    
    Display_Menu display_menu(.basys_clk(clk_6p25Mhz), .slow_clk(clk_0p16hz), .pixel_index(my_pixel_index), .display_setting(toggle_menu), .current(current), .oled_data(oled_data_menu));
    
    // OLED TASK A - to activate using sw[0]
    wire btnU_task_a;    
    wire [15:0] led_task_a;
    wire [15:0] oled_data_task_a;
    
    Oled_Task_A oled_task_a (.CLK_100MHZ(CLK_100MHZ), .btnU(btnU_task_a), .my_pixel_index(my_pixel_index), .oled_data(oled_data_task_a), .LD14(led_task_a[14]));
    
    // OLED TASK B - to activate using sw[1]
    wire btnD_task_b;
    wire [15:0] led_task_b;
    wire [15:0] oled_data_task_b;
    
    Oled_Task_B oled_task_b (.CLK_100MHZ(CLK_100MHZ), .btnD(btnD_task_b), .my_pixel_index(my_pixel_index), .oled_data(oled_data_task_b), .LD12(led_task_b[12]));
    
    // AUDIO VOLUME INDICATOR (Basic Task for Team) - to activate using sw[2]
    wire [15:0] oled_data_task_c;
    wire [15:0] led_task_c;
    wire [3:0] an_task_c;
    wire [6:0] seg_task_c;
    wire [11:0] maxNoise;
    
    Audio_Volume_Indicator audio_volume_indicator (.CLK_100MHZ(CLK_100MHZ), .clk_20khz(clk_20khz), .sample(sample), .my_pixel_index(my_pixel_index), .oled_data(oled_data_task_c), .LD(led_task_c[4:0]), .an(an_task_c), .seg(seg_task_c), .maxNoise(maxNoise));
    
    // Calibration of Frequency limit
    wire sw15_settings;
    wire sw14_settings;
    wire [31:0] count_threshold;
    wire [15:0] led_settings;
    wire is_above_freq;
    
    Calibrate_Frequency calibrate_frequency (.CLK_100MHZ(CLK_100MHZ), .clk_20khz(clk_20khz), .on_calibration(sw15_settings), .sample(sample), .maxNoise(maxNoise), .count_threshold(count_threshold), .is_above_freq(is_above_freq));
    
    // To input in OLED instructions on how to calibrate the frequency being detected
    wire [15:0] oled_data_settings;
    
    Settings_Display settings_display (.clk(CLK_100MHZ), .my_pixel_index(my_pixel_index), .oled_data(oled_data_settings));
    
    // QR code that brings you to frequency generator online, assessed via settings page and on sw[0]
    wire [15:0] oled_data_qr;
    QR_Code qr_code (.clk(CLK_100MHZ), .my_pixel_index(my_pixel_index), .oled_data(oled_data_qr));
    
    // Improvements made: simulating a T-junction with traffic light and pedestrian crossing
    // to activate using sw[3]
    wire btnU_team;
    wire [15:0] oled_data_team;
    wire [3:0] an_team;
    wire [6:0] seg_team;
    
    Traffic_Junction traffic_junction(.CLK_100MHZ(CLK_100MHZ), .clk_20khz(clk_20khz), .clk_200hz(clk_200hz), .clk_1hz(clk_1hz), .btnU(btnU_team), .sample(sample), .my_pixel_index(my_pixel_index), .is_above_freq(is_above_freq), .oled_data(oled_data_team), .an(an_team), .seg(seg_team));   
    
    
    // to control which task is inputting/outputting the data onto the basys3 board
    assign led_settings[15] = is_above_freq;
    assign btnC_menu = btnC_pulsed;
    assign btnU_menu = (toggle_menu == 0) ? btnU_pulsed : 0;
    assign btnD_menu = (toggle_menu == 0) ? btnD_pulsed : 0;
    assign btnL_menu = (toggle_menu == 0) ? btnL_pulsed : 0;
    assign btnR_menu = (toggle_menu == 0) ? btnR_pulsed : 0;
    assign sw15_settings = (toggle_menu == 3) ? sw[15] : 0;
    assign sw14_settings = (toggle_menu == 3) ? sw[14] : 0;
    assign btnU_task_a = (sw[0] && !sw[1] && !sw[2] && toggle_menu == 2) ? btnU_pulsed : 0;
    assign btnU_team = (toggle_menu == 1) ? btnU_pulsed : 0;
    assign btnD_task_b = (sw[1] && !sw[2] && toggle_menu == 2) ? btnD_pulsed : 0;
    assign led = (toggle_menu == 1 || toggle_menu == 3) ? {led_settings[15], led_task_c[14:0]} : (toggle_menu == 2 && sw[2]) ? led_task_c : (toggle_menu == 2 && sw[1]) ? led_task_b : (toggle_menu == 2 && sw[0]) ? led_task_a : 0;
    assign an = (toggle_menu == 1) ? an_team : (toggle_menu == 2 && sw[2]) ? an_task_c : 4'b1111;
    assign seg = (toggle_menu == 1) ? seg_team : (toggle_menu == 2 && sw[2]) ? seg_task_c : 7'b1111111;
    assign oled_data = (toggle_menu == 0) ? oled_data_menu : (toggle_menu == 1) ? oled_data_team : (toggle_menu == 2 && sw[2]) ? oled_data_task_c : (toggle_menu == 2 && sw[1]) ? oled_data_task_b : (toggle_menu == 2 && sw[0]) ? oled_data_task_a : (toggle_menu == 3 && !sw14_settings) ? oled_data_settings : (toggle_menu == 3 && sw14_settings) ? oled_data_qr : 0;
    
endmodule