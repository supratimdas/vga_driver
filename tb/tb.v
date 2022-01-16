/*********************************************************** 
* File Name     : tb.v
* Description   : vga display driver tb
* Organization  : NONE 
* Creation Date : 07-03-2020
* Last Modified : Sunday 16 January 2022 03:04:54 PM
* Author        : Supratim Das (supratimofficio@gmail.com)
************************************************************/ 
`timescale 1ns/1ps

`define SIM
`define SIMULATION_END_COUNT 5000000

`include "../vmodel/vga_driver.v" 
`include "../vmodel/ice40_vga_driver.v" 

module tb ();
    reg clk;
    reg reset_;
    integer sim_count;

    initial begin
        clk = 0;
        sim_count = 0;
        #100
        forever begin
           #20 clk = ~clk;
        end
    end

    initial begin
        //prepare for wave dump
        $dumpfile("test.vcd");
        $dumpvars(0, tb);
        $display("*********Simulation Start*************");
        reset_ = 1;
        # 200 reset_ = 0;
        # 200 reset_ = 1;
        wait (sim_count == `SIMULATION_END_COUNT)
        $display("*********Simulation End*************");
        $finish;
    end

    always @(posedge clk) begin
       sim_count <= sim_count + 1'b1; 
    end
    

    //dut instance

    ice40_vga_driver u_vga_driver(
       .clk(clk),         //<i 
       .o_v_sync(),       //>o
       .o_h_sync(),       //>o
       .o_r(),            //>o
       .o_g(),            //>o
       .o_b()             //>o
    );



endmodule
