/*********************************************************** 
* File Name     : vga_driver.v
* Description   : vga display driver
* Organization  : NONE 
* Creation Date : 07-03-2020
* Last Modified : Friday 24 December 2021 09:27:51 PM
* Author        : Supratim Das (supratimofficio@gmail.com)
************************************************************/ 
`timescale 1ns/1ps


module vga_driver (
    clk_60Mhz,      //<i 
    reset_,         //<i
    o_v_sync,       //>o
    o_h_sync,       //>o
    o_r,            //>o
    o_g,            //>o
    o_b             //>o
);
    input   clk_60Mhz;
    input   reset_;
    output  o_v_sync;
    output  o_h_sync;
    output  o_r;
    output  o_g;
    output  o_b;

    wire v_sync; 
    wire h_sync; 

    reg v_sync_q;
    reg v_sync_qq;
    reg h_sync_q;

    reg r_q;
    reg g_q;
    reg b_q;

    reg [19:0] v_sync_tick_counter; //max count 999840
    reg [10:0] h_sync_tick_counter; //max count 1238

    reg [19:0] v_sync_tick_counter_next; 
    reg [10:0] h_sync_tick_counter_next; 


    //defines
    `define v_sync_period_ticks 20'd999840
    `define h_sync_period_ticks 11'd1238
    `define v_sync_lo_period_ticks 20'd7440
    `define v_sync_hi_period_ticks 20'd992400
    `define h_sync_lo_period_ticks 11'd129
    `define h_sync_hi_period_ticks 11'd1109

    always @(posedge clk_60Mhz) begin
        if(!reset_) begin
            v_sync_tick_counter <= 20'd0;
        end
        else begin
            v_sync_tick_counter <= v_sync_tick_counter_next;
        end
    end
    

    assign frame_start = v_sync_q & (v_sync_q ^ v_sync);

    always @(posedge clk_60Mhz) begin
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


    //display some pattern
    assign horizontal_back_porch = (h_sync_tick_counter <= 1);
    assign horizontal_front_porch = (h_sync_tick_counter >= (`h_sync_period_ticks - 160));
    assign vertical_back_porch = (v_sync_tick_counter <= 100);
    assign vertical_front_porch = (v_sync_tick_counter >= (`v_sync_period_ticks - 16000));

    assign pixel_en = ~horizontal_back_porch & ~horizontal_front_porch & ~vertical_back_porch & ~vertical_front_porch; // & h_sync & v_sync_q; 

    reg [31:0] count;

    assign r = pixel_en & (v_sync_tick_counter[3]);
    assign g = pixel_en & (v_sync_tick_counter[4]);
    assign b = pixel_en & (v_sync_tick_counter[5]);

    always @(posedge clk_60Mhz) begin
        r_q <= r;
        g_q <= g;
        b_q <= b;
    end

    assign o_r = r_q;
    assign o_g = g_q;
    assign o_b = b_q;

    assign h_sync = (h_sync_tick_counter <= `h_sync_lo_period_ticks) ? 1'b0 : 1'b1;
    assign v_sync = (v_sync_tick_counter <= `v_sync_lo_period_ticks) ? 1'b0 : 1'b1;

    always @(posedge clk_60Mhz) begin
        h_sync_q <= h_sync;
        v_sync_q <= v_sync;
        v_sync_qq <= v_sync_q;
    end

    assign o_v_sync = v_sync_qq;
    assign o_h_sync = h_sync_q;
endmodule
