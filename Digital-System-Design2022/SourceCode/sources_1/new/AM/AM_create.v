`timescale 1ns / 1ps

module AM_create(
	input		clk,
	input		rst_n,
	output	signed	[13:0]	AM_mod
);
wire    [15:0]AM_mod1;
wire 	[7:0]	cos_s;
wire	signed	[7:0]	cos_c;
assign AM_mod = AM_mod1[15:2];

//------------调用出波模块------------//
cos_make		cos_make_inst0(
	.clk			(clk),
	.rst_n		(rst_n),
	.cos_s		(cos_s),
	.cos_c		(cos_c)
);
//-----------------------------------//

//------------调用乘法器--------------//
MULT		MULT_inst1(		
  .CLK	(clk),
  .A		(cos_s),
  .B		(cos_c),
  .P		(AM_mod1)
);

endmodule
