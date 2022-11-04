`timescale 1ns / 1ps
`define    Clock 10 // ±÷”÷‹∆⁄

module seg_tb();
    reg clk;
    reg rst_n;
    wire [3:0] an1,an2;
    wire [6:0] sseg1,sseg2;
    wire dp1,dp2;
initial begin
     clk = 0;
     rst_n = 0; #(`Clock*20+1);
     rst_n = 1;
     forever
         #(`Clock/2) clk = ~clk;
end
seg_display seg_left(
    .clk   ( clk   ),
    .rst_n ( rst_n ),
    .hex0  ( 4'h2 ),
    .hex1  ( 4'h0  ),
    .hex2  ( 4'h2  ),
    .hex3  ( 4'h2  ),
    .dp_in ( 4'b1000 ),
    .an    ( an1    ),
    .sseg  ( {dp1,sseg1} )
);
seg_display seg_right(
    .clk   ( clk   ),
    .rst_n ( rst_n ),
    .hex0  ( 4'h0 ),
    .hex1  ( 4'h1  ),
    .hex2  ( 4'h1  ),
    .hex3  ( 4'h8  ),
    .dp_in ( 4'b0000 ),
    .an    ( an2    ),
    .sseg  ( {dp2,sseg2} )
);
endmodule
