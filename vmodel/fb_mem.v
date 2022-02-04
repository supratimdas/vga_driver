/*********************************************************** 
* File Name     : fb_mem.v
* Organization  : NONE
* Creation Date : 04-02-2022
* Last Modified : Friday 04 February 2022 08:25:04 PM
* Author        : Supratim Das (supratimofficio@gmail.com)
************************************************************/ 

/*=============Description======================
 *
 *
 *
 *
 * ============================================*/
 module fb_mem(
    clk,      // < i 
    i_wen,    // < i
    i_addr,   // < i
    i_wdata,  // < i
    o_rdata   // > o
    );
    input clk;
    input i_wen;
    input [12:0] i_addr;
    input [7:0] i_wdata;
    output reg [7:0] o_rdata;

    reg [7:0] mem [0:4799]; //80x60 1bit frame buffer

    always @(posedge clk) begin
        if (i_wen) begin 
            mem[i_addr] <= i_wdata;
        end

        o_rdata <= mem[i_addr];
     end
endmodule
