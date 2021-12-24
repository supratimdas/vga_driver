/*********************************************************** 
* File Name     : ice_vga_driver.v
* Description   : vga display driver on ice40
* Organization  : NONE 
* Creation Date : 07-03-2020
* Last Modified : Friday 24 December 2021 07:30:45 PM
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
	    .clock_out(clk_60Mhz),
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
        .clk_60Mhz(clk_60Mhz),  //<i 
        .reset_(reset_),        //<i
        .o_v_sync(o_v_sync),    //>o
        .o_h_sync(o_h_sync),    //>o
        .o_r(o_r),              //>o
        .o_g(o_g),              //>o
        .o_b(o_b)               //>o
    );

endmodule
