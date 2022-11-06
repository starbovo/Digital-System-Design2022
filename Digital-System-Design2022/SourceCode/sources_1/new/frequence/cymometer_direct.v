`timescale 1ns / 1ps


module cymometer_direct(
     input clk,
     input rst_n,
     input clk_fx,								//��������ź�
     output  reg [31:0] fre						//��������ź�Ƶ�� 
    );
    parameter	TIME_SYS  = 10	;				//ϵͳʱ�����ڣ�10ns--Ƶ��=100MHz
    parameter	TIME_GATE = 50_000_000	;		//500msբ�����õ�ʱ�䣬��λ��ns
    localparam	N = TIME_GATE /	TIME_SYS;		//����բ����Ҫ�����ĸ���
    reg 		gate		;					//բ��
    reg [31:0] 	cnt_gate	;					//��������բ�ŵļ�����
    reg [31:0] 	cnt_fx		;					//բ��ʱ���ڶԱ����źż���
    wire		gate_n		;					//բ��ȡ���������ڷ�բ��ʱ�����õ�Ƶ��ֵ
    assign	gate_n = ~gate	;					//բ��ȡ���������ڷ�բ��ʱ�����õ�Ƶ��ֵ

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
 
//բ��ʱ���ڶԱ����źż���
always @(posedge clk_fx or negedge rst_n)
    begin	
	if(!rst_n)
		cnt_fx <= 0;
	else if(gate)
		cnt_fx <= cnt_fx + 1;
	else
		cnt_fx <= 0;
end
 
//�ڷ�բ��ʱ�����õ�Ƶ��ֵ
always @(posedge gate_n or negedge rst_n)
   begin	
	if(!rst_n)
		fre <= 0;
	else 
		//TIME_GATE/cnt_fx=�涨ʱ��/�����źŸ���=�����ź����ڣ�
		//ȡ������ΪƵ�ʣ�fre=1/(TIME_GATE/cnt_fx)���涨ʱ����բ��ʱ��
		fre <= 1000_000_000/TIME_GATE * cnt_fx;	
end
endmodule
