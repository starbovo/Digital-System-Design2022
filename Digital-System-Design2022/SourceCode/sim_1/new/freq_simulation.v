`timescale 1ns / 1ps
`define    Clock 10 //时钟周期
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/17 14:41:57
// Design Name: 
// Module Name: freq_simulation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module freq_simulation();
    reg sys_clk;
    reg rst_n;
    wire [7:0] o_wave;
    wire clkdiv10;
initial begin
     sys_clk = 0;
     forever
         #(`Clock/2) sys_clk = ~sys_clk;
 end
 
 initial begin
     rst_n = 0; #(`Clock*20+1);
     rst_n = 1;
end
freq_div10 div10(
    sys_clk,
    rst_n,
    clkdiv10
);
DDS mydds(
    clkdiv10,      //10MHZ
    rst_n,
    6'd1,//频率控制字M
    o_wave
    );
endmodule