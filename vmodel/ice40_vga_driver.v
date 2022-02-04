/*********************************************************** 
* File Name     : ice_vga_driver.v
* Description   : vga display driver on ice40
* Organization  : NONE 
* Creation Date : 07-03-2020
* Last Modified : Friday 04 February 2022 09:25:40 PM
* Author        : Supratim Das (supratimofficio@gmail.com)
************************************************************/ 
`timescale 1ns/1ps

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

    frame_buffer u_frame_buffer (
        .clk(clk_25Mhz),                        //<i
        .reset_(o_v_sync),                      //<i
        .i_fetch_next_pixel(fetch_next_pixel),  //<i
        .i_fb_update(1.b0),                     //<i
        .i_fb_addr(),                           //<i
        .i_fb_data(),                           //<i
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
