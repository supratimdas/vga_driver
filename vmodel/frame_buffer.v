/*********************************************************** 
* File Name     : frame_buffer.v
* Organization  : NONE
* Creation Date : 04-02-2022
* Last Modified : Friday 04 February 2022 09:25:51 PM
* Author        : Supratim Das (supratimofficio@gmail.com)
************************************************************/ 

/*=============Description======================
 *
 *
 *
 *
 * ============================================*/
`define MAX_H_PIXELS 10'd640
`define MAX_V_LINES 9'd480
//`define __IMAGE_ROM__

module frame_buffer(    
    clk,                //<i
    reset_,             //<i
    i_fetch_next_pixel, //<i    
    i_fb_update,        //<i
    i_fb_addr,          //<i
    i_fb_data,          //<i
    o_pixel_rgb         //>o
);
    input           clk;
    input           reset_;
    input           i_fetch_next_pixel;
    input           i_fb_update; 
    input [12:0]    i_fb_addr;
    input [7:0]     i_fb_data;
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

`ifdef __IMAGE_ROM__ //static image
    always @(*) begin
        case({line,pixels_per_line})
            `include "img.v"
            default: pixel_rgb = 3'b111;
        endcase
    end
`else
    reg wen0;
    reg [12:0] addr0;
    reg [7:0] w_dat0;
    wire [7:0] r_dat0;

    always @(*) begin
        wen0 = i_fb_update;
        w_dat0 = i_fb_data;
    end

    reg [12:0] addr0;
    always @(*) begin
        if(wen0) begin
            addr0 = i_fb_addr;
        end
        else begin
            addr0 = {line[7:3],pixels_per_line[10:3]};
        end
    end

    //frame buffer stores 8 pixels in a single 1byte
    fb_mem u_fb_mem0 (
        .clk(clk),          // < i 
        .i_wen(wen0),       // < i
        .i_addr(addr0),     // < i
        .i_wdata(w_dat0),   // < i
        .o_rdata (r_dat0)   // > o
    );

    reg [7:0] pixel_read_mask;
    always @(posedge clk) begin
        if(!reset_ || row_done || frame_done) begin
            pixel_read_mask <= 8'h00;
        end
        else begin
            pixel_read_mask <= pixel_read_mask_next;
        end
    end

    reg [7:0] pixel_read_mask_next;
    always @(*) begin
        pixel_read_mask_next = 8'h0000_0000;
        if(i_fetch_next_pixel) begin
            case(pixel_read_mask) 
                8'b0000_0000:   pixel_read_mask_next = 8'b0000_0001;
                8'b0000_0001:   pixel_read_mask_next = 8'b0000_0010;
                8'b0000_0010:   pixel_read_mask_next = 8'b0000_0100;
                8'b0000_0100:   pixel_read_mask_next = 8'b0000_1000;
                8'b0000_1000:   pixel_read_mask_next = 8'b0001_0000;
                8'b0001_0000:   pixel_read_mask_next = 8'b0010_0000;
                8'b0010_0000:   pixel_read_mask_next = 8'b0100_0000;
                8'b0100_0000:   pixel_read_mask_next = 8'b1000_0000;
                8'b1000_0000:   pixel_read_mask_next = 8'b0000_0001;
                default: pixel_read_mask_next = 8'h0000_0000;
            endcase
        end
    end

    always @(*) begin
        pixel_rgb = (r_dat0 & pixel_read_mask_next) ? 3'b111 : 3'b000;
    end

`endif

    assign o_pixel_rgb = pixel_rgb;
endmodule
