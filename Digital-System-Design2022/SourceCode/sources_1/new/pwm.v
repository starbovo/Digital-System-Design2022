`timescale 1ns / 1ps


module pwm(  //�˿ڵĶ��壬��������˿ں�����˿�
    input clk,
    input rst,
    input pwm_dip,
    output [14:0] led
    );

    reg [24:0] cnt_reg;     //�����Ĵ���
    reg [14:0] light;       //LED�ƼĴ���
    reg DIR=1'b1;           //�жϱ�ʶ���������ƹ�ǿ�ȵ���һ���仯
    reg [24:0] value;       //����ռ�ձȵ�����
    reg [6:0] cs;           //ռ�ձȵı仯���ƣ�1~100

    always @ (posedge clk)  //��Ե���У�ʱ�������ص�������
    begin
    if(!rst || !pwm_dip)
    begin   //����Ϊ�����ĳ�ʼ��
        cnt_reg <= 0;
        cs <= 7'd0;
        value <= 0;
    end
    else
        cnt_reg <= cnt_reg+1;                   //��������1
        if(cnt_reg == 500000)                   //����һ����λʱ��
            begin           
            if(DIR) begin                       //DIR=1ʱ�ƹ��𽥱���
                value <= value + 19'd5000;      //ռ�ձȱ��
                cnt_reg <= 20'd0;               //��������0
                cs <= cs + 1'b1;                //����+1
            end
            else begin
                value <= value - 19'd5000;      //ռ�ձȱ�С
                cnt_reg <= 20'd0;               //��������0
                cs <= cs - 1'b1;                //����-1
            end
            end
        end
    
    always@(cnt_reg) begin          //��ƽ���У������ź��б仯��ִ��
    //ռ�ձȱ仯��ʵ��
        if(cnt_reg < value) begin   //��ǰ����������С��valuie
            light <= 15'h7fff;      //ȫ1������
        end 
        else begin                  //��ǰ����������С��valuie
            light <= 15'h0000;      //ȫ0������
        end
    end
    
    always @ (value) begin
    if (cs == 100) begin            //��cs�ﵽ100�󣬼�ռ�ձȴﵽ��1��������
        DIR <= 1'b0; end            //DIR=0����ζ�Ž�����Ҫ��ʼ�䰵��
    if (cs == 0) begin              //��cs�ﵽ.�󣬼�ռ�ձȴﵽ��0�����
        DIR <= 1'd1; end            //DIR=1����ζ�Ž�����Ҫ��ʼ������
    end  
    assign  led = light;            //���Ĵ������б���ĵ�ƽ��ֵ����·������Ӧ��ƽ�����    
        
    
endmodule