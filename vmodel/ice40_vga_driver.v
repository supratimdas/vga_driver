/*********************************************************** 
* File Name     : ice_vga_driver.v
* Description   : vga display driver on ice40
* Organization  : NONE 
* Creation Date : 07-03-2020
* Last Modified : Monday 24 January 2022 04:16:28 PM
* Author        : Supratim Das (supratimofficio@gmail.com)
************************************************************/ 
`timescale 1ns/1ps

`define MAX_H_PIXELS 10'd640
`define MAX_V_LINES 9'd480

module img_rom(
    clk,                //<i
    reset_,             //<i
    i_fetch_next_pixel, //<i
    o_pixel_rgb         //>o
);
    input           clk;
    input           reset_;
    input           i_fetch_next_pixel;
    output [2:0]    o_pixel_rgb;

    reg [8:0] line;
    reg [9:0] pixels_per_line;
    reg [2:0] pixel_rgb;

    assign row_done = (pixels_per_line >= `MAX_H_PIXELS);
    assign frame_done = (line >= `MAX_V_LINES);

    always @(posedge clk) begin
        if(!reset_) begin
            line <= 8'd0;
            pixels_per_line <= 10'd0;
        end
        else if(i_fetch_next_pixel) begin
            pixels_per_line <= pixels_per_line + 1'b1;
            if(row_done) begin
                pixels_per_line <= 10'd0;
                line <= line + 1; 
            end
            if(frame_done) begin
                line <= 7'd0;
                pixels_per_line <= 10'd0;
            end
        end
    end

    always @(*) begin
        case({line,pixels_per_line})
            `include "img.v"
            default: pixel_rgb = 3'b111;
        endcase
    end

    assign o_pixel_rgb = pixel_rgb;
endmodule

module ice40_vga_driver (
    clk,            //<i 
    o_v_sync,       //>o
    o_h_sync,       //>o
    o_r,            //>o
    o_g,            //>o
    o_b             //>o
);
    input   clk;
    output  o_v_sync;
    output  o_h_sync;
    output  o_r;
    output  o_g;
    output  o_b;


    reg reset_;


`ifndef SIM
    wire pll_locked;
    wire clk_50Mhz;
    pll u_pll(
	    .clock_in(clk),
	    .clock_out(clk_50Mhz),
	    .locked(pll_locked));
`else
    reg pll_locked;
    wire clk_50Mhz;
    assign clk_50Mhz = clk;

    initial begin
        pll_locked = 1'b0;
        #1000 pll_locked = 1'b1;
    end
`endif
    //reset generation
    always @(posedge clk) begin
        if(!pll_locked) begin
            reset_ <= 1'b0;
        end
        else begin
            reset_ <= 1'b1;
        end
    end

    reg clk_25Mhz;
`ifdef SIM
    initial begin
        clk_25Mhz <= 0;
    end
`endif
    always @(posedge clk_50Mhz) begin
        clk_25Mhz <= ~clk_25Mhz;
    end

    wire r,g,b;
    wire fetch_next_pixel;

    img_rom u_img_rom (
        .clk(clk_25Mhz),                        //<i
        .reset_(o_v_sync),                      //<i
        .i_fetch_next_pixel(fetch_next_pixel),  //<i
        .o_pixel_rgb({r,g,b})                   //>o
    );

    vga_driver u_vga_core (
        .clk_50Mhz(clk_50Mhz),                  //<i 
        .reset_(reset_),                        //<i
        .o_v_sync(o_v_sync),                    //>o
        .o_h_sync(o_h_sync),                    //>o
        .o_r(o_r),                              //>o
        .o_g(o_g),                              //>o
        .o_b(o_b),                              //>o
        .o_fetch_next_pixel(fetch_next_pixel),  //>o
        .i_pixel_r(r),                          //<i
        .i_pixel_g(g),                          //<i
        .i_pixel_b(b),                          //<i
        .i_self_test(1'b0)                      //<i
    );

endmodule
