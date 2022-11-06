`timescale 1ns / 1ps


module cymometer_direct(
     input clk,
     input rst_n,
     input clk_fx,								//输入待测信号
     output  reg [31:0] fre						//输出待测信号频率 
    );
    parameter	TIME_SYS  = 10	;				//系统时钟周期：10ns--频率=100MHz
    parameter	TIME_GATE = 50_000_000	;		//500ms闸门设置的时间，单位：ns
    localparam	N = TIME_GATE /	TIME_SYS;		//生成闸门需要计数的个数
    reg 		gate		;					//闸门
    reg [31:0] 	cnt_gate	;					//用于生成闸门的计数器
    reg [31:0] 	cnt_fx		;					//闸门时间内对被测信号计数
    wire		gate_n		;					//闸门取反，用于在非闸门时输出测得的频率值
    assign	gate_n = ~gate	;					//闸门取反，用于在非闸门时输出测得的频率值

always @(posedge clk or negedge rst_n)
   begin	
	if(!rst_n)
	   begin
		cnt_gate <=0;
		gate <=0;
	end	
	else begin
		if(cnt_gate == N-1)
		   begin
			cnt_gate <= 0;
			gate <= ~gate;
		end	
		else
		cnt_gate<=cnt_gate+1;
	end
end 
 
//闸门时间内对被测信号计数
always @(posedge clk_fx or negedge rst_n)
    begin	
	if(!rst_n)
		cnt_fx <= 0;
	else if(gate)
		cnt_fx <= cnt_fx + 1;
	else
		cnt_fx <= 0;
end
 
//在非闸门时输出测得的频率值
always @(posedge gate_n or negedge rst_n)
   begin	
	if(!rst_n)
		fre <= 0;
	else 
		//TIME_GATE/cnt_fx=规定时间/被测信号个数=被测信号周期，
		//取倒数即为频率，fre=1/(TIME_GATE/cnt_fx)，规定时间是闸门时间
		fre <= 1000_000_000/TIME_GATE * cnt_fx;	
end
endmodule
