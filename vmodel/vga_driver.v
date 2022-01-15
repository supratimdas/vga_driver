/*********************************************************** 
* File Name     : vga_driver.v
* Description   : vga display driver supporting 8 color mode
* Organization  : NONE 
* Creation Date : 07-03-2020
* Last Modified : Saturday 15 January 2022 11:32:28 PM
* Author        : Supratim Das (supratimofficio@gmail.com)
************************************************************/ 
`timescale 1ns/1ps

`define VGA_640x480_MODE
//add more modes if possible


module vga_driver (
    clk_50Mhz,          //<i 
    reset_,             //<i
    o_v_sync,           //>o
    o_h_sync,           //>o
    o_r,                //>o
    o_g,                //>o
    o_b,                //>o
    o_fetch_next_pixel, //>o
    i_pixel_r,          //<i 
    i_pixel_g,          //<i
    i_pixel_b,          //<i
    i_self_test         //<i
);
    input   clk_50Mhz;
    input   reset_;
    output  o_v_sync;
    output  o_h_sync;
    output  o_r;
    output  o_g;
    output  o_b;

    input   i_pixel_r;
    input   i_pixel_g;
    input   i_pixel_b;
    output  o_fetch_next_pixel;

    input   i_self_test;

    wire v_sync; 
    wire h_sync; 

    reg v_sync_q;
    reg v_sync_qq;
    reg h_sync_q;

    reg r_q;
    reg g_q;
    reg b_q;

    reg [19:0] v_sync_tick_counter;
    reg [10:0] h_sync_tick_counter;

    reg [19:0] v_sync_tick_counter_next; 
    reg [10:0] h_sync_tick_counter_next; 


`ifdef VGA_640x480_MODE
`define H_PIXELS 640
`define V_LINES 480
`endif
//VGA Timings: 640x480p60
//clk_50Mhz_freq: 50.250Mhz period: 19.9ns (actual achieved freq by ice40 pll)
//Screen Refresh rate: 60Hz
//Vertical regresh: 31.468KHz
//pixel freq. 25.175MHz
//Pixel Time          39.72 ns ±0.5%
//H_SYNC pulse	3.8μs (96 pixels)
//Horizontal front porch	0.63μs (16 pixels)
//Horizontal display	25.42μs (640 pixels)
//Horizontal back porch	1.90μs (48 pixels)
//Horizontal line time 31.8us (800 pixels)
//V_SYNC pulse	63us (2 lines or 1600 pixels)
//Vertical front porch	317μs (10 lines or 8000 pixels)
//Vertical display	15.2ms (480 lines or 384000 pixels)
//Vertical back porch	1.04ms (33 lines or 26400 pixels)
//vertical frame time 16.6ms (525 lines or 420000 pixels)
    `define HORIZONTAL_PIXEL_SHIFT_MARGIN 32
    `define VERTICAL_LINE_SHIFT_MARGIN 0
    `define PIXELS_PER_LINE 800 //ACTIVE + BLANKING Pixels
    `define v_sync_period_ticks 20'd840000
    `define h_sync_period_ticks 11'd1600
    `define v_sync_lo_period_ticks 20'd3200
    `define v_sync_hi_period_ticks (`v_sync_period_ticks - `v_sync_lo_period_ticks)
    `define h_sync_lo_period_ticks 11'd192
    `define h_sync_hi_period_ticks (`h_sync_period_ticks - `h_sync_lo_period_ticks)
    `define h_front_porch 11'd32
    `define h_back_porch (11'd96 + (`HORIZONTAL_PIXEL_SHIFT_MARGIN*2))
    `define v_front_porch 20'd16000
    `define v_back_porch (20'd52800 + (`VERTICAL_LINE_SHIFT_MARGIN*`PIXELS_PER_LINE))

    always @(posedge clk_50Mhz) begin
        if(!reset_) begin
            v_sync_tick_counter <= 20'd0;
        end
        else begin
            v_sync_tick_counter <= v_sync_tick_counter_next;
        end
    end
    

    assign frame_start = v_sync_q & (v_sync_q ^ v_sync);

    always @(posedge clk_50Mhz) begin
        if(frame_start) begin
            h_sync_tick_counter <= 11'd0;
        end
        else begin
            h_sync_tick_counter <= h_sync_tick_counter_next;
        end
    end


    always @(*) begin
        if(v_sync_tick_counter == (`v_sync_period_ticks - 1)) begin
            v_sync_tick_counter_next = 20'd0;
        end
        else begin
            v_sync_tick_counter_next = v_sync_tick_counter + 1'b1;
        end
    end

    always @(*) begin
        if(h_sync_tick_counter == (`h_sync_period_ticks - 1)) begin
            h_sync_tick_counter_next = 20'd0;
        end
        else begin
            h_sync_tick_counter_next = h_sync_tick_counter + 1'b1;
        end
    end


    assign horizontal_back_porch = (h_sync_tick_counter <= (`h_back_porch));
    assign horizontal_front_porch = (h_sync_tick_counter > (`h_back_porch + (`H_PIXELS*2) + `h_front_porch));
    assign vertical_back_porch = (v_sync_tick_counter <= `v_back_porch);
    assign vertical_front_porch = (v_sync_tick_counter > (`v_back_porch + (`V_LINES*800*2) + `v_front_porch));

    assign pixel_en = ~horizontal_back_porch & ~horizontal_front_porch & ~vertical_back_porch & ~vertical_front_porch & h_sync & v_sync_q; 

    reg [31:0] count;

    assign o_fetch_next_pixel = pixel_en;
    always @(posedge clk_50Mhz) begin
        fetch_next_pixel_q <= o_fetch_next_pixel;
        if(fetch_next_pixel_q) begin
            r <= i_pixel_r;
            g <= i_pixel_g;
            b <= i_pixel_b;
        end
    end

    //display some pattern in self test mode
    assign pixel_r = (i_self_test) ? v_sync_tick_counter[4]: r; 
    assign pixel_g = (i_self_test) ? v_sync_tick_counter[5]: g; 
    assign pixel_b = (i_self_test) ? v_sync_tick_counter[6]: b; 

    assign final_r = fetch_next_pixel_q & pixel_r;
    assign final_g = fetch_next_pixel_q & pixel_g;
    assign final_b = fetch_next_pixel_q & pixel_b;

    always @(posedge clk_50Mhz) begin
        final_r_q <= final_r;
        final_g_q <= final_g;
        final_b_q <= final_b;
    end

    assign o_r = final_r_q;
    assign o_g = final_g_q;
    assign o_b = final_b_q;

    assign h_sync = (h_sync_tick_counter < `h_sync_lo_period_ticks) ? 1'b0 : 1'b1;
    assign v_sync = (v_sync_tick_counter < `v_sync_lo_period_ticks) ? 1'b0 : 1'b1;

    always @(posedge clk_50Mhz) begin
        h_sync_q  <= h_sync;
        v_sync_q  <= v_sync;
        h_sync_qq <= h_sync_q;
        v_sync_qq <= v_sync_q;
    end

    assign o_v_sync = v_sync_qq;
    assign o_h_sync = h_sync_qq;
endmodule
