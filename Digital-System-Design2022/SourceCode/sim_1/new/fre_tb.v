`timescale 1ns / 1ps
`define    Clock 10 //时钟周期

module fre_tb();
    reg clk;
    reg rst_n;
    wire [3:0] an1,an2;
    wire [6:0] sseg1,sseg2;
    wire dp1,dp2;
    wire [13:0] o_wave;
    wire [3:0] AD0,AD1,AD2,AD3,AD4,AD5,AD6;
    wire clk_div10;

    initial begin
        clk = 0;
        forever
            #(`Clock/2) clk = ~clk;
    end
    initial begin
        rst_n = 0; #(`Clock*200+1);
        rst_n = 1;
    end

    freq_div10#(
        .DIV_0CLK ( 10 )
    )freq_div10(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .clk_div10  ( clk_div10 )
    );

    DDS8 u_DDS8(
        .clk   (clk_div10),
        .rst_n (  rst_n ),
        .FRQ_W (   46   ),
        .o_wave( o_wave )
    );
    AD_fre u_AD_fre(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .AD_in ( o_wave[13:4] ),
        .AD0   ( AD0   ),
        .AD1   ( AD1   ),
        .AD2   ( AD2   ),
        .AD3   ( AD3   ),
        .AD4   ( AD4   ),
        .AD5   ( AD5   ),
        .AD6   ( AD6   )
    );
    seg_display seg_left(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .hex0  ( 4'h0 ),
        .hex1  ( AD6  ),
        .hex2  ( AD5  ),
        .hex3  ( AD4  ),
        .dp_in ( 4'b0000 ),
        .an    ( an1    ),
        .sseg  ( {dp1,sseg1} )
    );
    seg_display seg_right(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .hex0  ( AD3 ),
        .hex1  ( AD2  ),
        .hex2  ( AD1  ),
        .hex3  ( AD0  ),
        .dp_in ( 4'b0001 ),
        .an    ( an2    ),
        .sseg  ( {dp2,sseg2} )
    );
endmodule
