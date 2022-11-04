`timescale 1ns / 1ps
`define    Clock 10 //时钟周期

module swDDS_tb();
    reg clk;
    reg rst_n;
    wire [3:0] an1,an2;
    wire [6:0] sseg1,sseg2;
    wire dp1,dp2;
    wire [13:0] o_wave;
    reg [7:0] sw;
    wire [3:0] ones,tens,huns,thous,tenk,hunk,onem;
    wire clk_div10,clk_div104,clk_div106;

    initial begin
        clk = 0;
        sw = 8'b0000_0000;
        rst_n = 0; #(`Clock*20+1);
        rst_n = 1;
     forever
         #(`Clock/2) clk = ~clk;
    end
    always@(posedge clk_div106)begin
        sw <= sw+1;
    end
    freq_div10#(
        .DIV_0CLK ( 10000 )
    )freq_div104(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .clk_div10  ( clk_div104 )
    );
    freq_div10#(
        .DIV_0CLK ( 100 )
    )freq_div106(
        .clk   ( clk_div104   ),
        .rst_n ( rst_n ),
        .clk_div10  ( clk_div106 )
    );
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
        .FRQ_W ( sw[5:0]),
        .o_wave( o_wave )
    );
    sw_BCD u_sw_BCD(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .sw    ( sw    ),
        .ones  ( ones  ),
        .tens  ( tens  ),
        .huns  ( huns  ),
        .thous ( thous ),
        .tenk  ( tenk  ),
        .hunk  ( hunk  ),
        .onem  ( onem  )
    );
    seg_display seg_left(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .hex0  ( 4'h0 ),
        .hex1  ( onem  ),
        .hex2  ( hunk  ),
        .hex3  ( tenk  ),
        .dp_in ( 4'b0000 ),
        .an    ( an1    ),
        .sseg  ( {dp1,sseg1} )
    );
    seg_display seg_right(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .hex0  ( thous ),
        .hex1  ( huns  ),
        .hex2  ( tens  ),
        .hex3  ( ones  ),
        .dp_in ( 4'b0001 ),
        .an    ( an2    ),
        .sseg  ( {dp2,sseg2} )
    );
endmodule
