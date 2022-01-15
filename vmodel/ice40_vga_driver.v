/*********************************************************** 
* File Name     : ice_vga_driver.v
* Description   : vga display driver on ice40
* Organization  : NONE 
* Creation Date : 07-03-2020
* Last Modified : Saturday 15 January 2022 11:33:47 PM
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


    pll u_pll(
	    .clock_in(clk),
	    .clock_out(clk_50Mhz),
	    .locked(pll_locked));

    //reset generation
    always @(posedge clk) begin
        if(!pll_locked) begin
            reset_ <= 1'b0;
        end
        else begin
            reset_ <= 1'b1;
        end
    end


    vga_driver u_vga_core (
        .clk_50Mhz(clk_50Mhz),  //<i 
        .reset_(reset_),        //<i
        .o_v_sync(o_v_sync),    //>o
        .o_h_sync(o_h_sync),    //>o
        .o_r(o_r),              //>o
        .o_g(o_g),              //>o
        .o_b(o_b),              //>o
        .o_fetch_next_pixel(),  //>o
        .i_pixel_r(),           //<i
        .i_pixel_g(),           //<i
        .i_pixel_b(),           //<i
        .i_self_test(1'b1)      //<i
    );

endmodule
