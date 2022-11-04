`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/20 20:54:28
// Design Name: 
// Module Name: tb_cymometer_direct
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


module tb_cymometer_direct();
   reg 		   clk;
   reg         rst_n;
   wire         clk_fx;
   reg         squ_0;
   wire         clk_div104;
   wire  [5:0] FRQ_w;
   //wire  [7:0] o_wave;       
   wire [31:0] fre;
   reg [15:0] max;
   reg [15:0] min;
   wire [15:0] zero;
   assign clk_fx=clk_div104;
//   initial begin       //将DDS输出的正弦波转化成方波
//        max = 100;
//        min = 100;
//   end
//   always@(posedge clk_div)
//   begin
//    if(o_wave > max) 
//    max <= o_wave;
//    end
//    always@(posedge clk_div)
//      begin 
//        if(o_wave < min) 
//          min <= o_wave;
//          end
//     assign zero = (max+min)/2;
//     always@(negedge clk_div)
//        begin 
//           if(o_wave > zero)
//               clk_fx <= 1'b1; 
//                  else clk_fx <= 1'b0;
//                     end
 cymometer_direct	cymometer_direct_inst(
	.clk	( clk	),
	.rst_n	( rst_n	),
	.clk_fx (  clk_fx		),
    .fre       	(   fre		)
);
clk_div10 div(
    .clk(clk),
    .rst_n(rst_n),
    .clk_div10(clk_div)
    );
ES_design_top_div104 div1(
    .clk(clk),
    .rst_n(rst_n),
    .clk_div104(clk_div104)
    );

//DDS dds(
//    .clk(clk_div),
//    .rst_n	( rst_n	),
//    .FRQ_W(6'd1),
//    .o_wave(o_wave)
//    );
initial begin
     clk = 0;
     forever
         #5 clk = ~clk;
 end
 initial begin
     rst_n = 0; 
     #(10*20+1);
     rst_n = 1;
end
endmodule
