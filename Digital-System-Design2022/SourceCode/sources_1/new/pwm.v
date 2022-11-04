`timescale 1ns / 1ps


module pwm(  //端口的定义，包括输入端口和输出端口
    input clk,
    input rst,
    input pwm_dip,
    output [14:0] led
    );

    reg [24:0] cnt_reg;     //计数寄存器
    reg [14:0] light;       //LED灯寄存器
    reg DIR=1'b1;           //判断标识符，决定灯光强度的下一步变化
    reg [24:0] value;       //用于占空比的设置
    reg [6:0] cs;           //占空比的变化趋势，1~100

    always @ (posedge clk)  //边缘敏感，时钟上升沿到来触发
    begin
    if(!rst || !pwm_dip)
    begin   //以下为变量的初始化
        cnt_reg <= 0;
        cs <= 7'd0;
        value <= 0;
    end
    else
        cnt_reg <= cnt_reg+1;                   //计数器加1
        if(cnt_reg == 500000)                   //经过一个单位时间
            begin           
            if(DIR) begin                       //DIR=1时灯光逐渐变亮
                value <= value + 19'd5000;      //占空比变大
                cnt_reg <= 20'd0;               //计数器归0
                cs <= cs + 1'b1;                //次数+1
            end
            else begin
                value <= value - 19'd5000;      //占空比变小
                cnt_reg <= 20'd0;               //计数器归0
                cs <= cs - 1'b1;                //次数-1
            end
            end
        end
    
    always@(cnt_reg) begin          //电平敏感，其中信号有变化即执行
    //占空比变化的实现
        if(cnt_reg < value) begin   //当前计数器的数小于valuie
            light <= 15'h7fff;      //全1，即亮
        end 
        else begin                  //当前计数器的数小于valuie
            light <= 15'h0000;      //全0，即暗
        end
    end
    
    always @ (value) begin
    if (cs == 100) begin            //当cs达到100后，即占空比达到了1，灯最亮
        DIR <= 1'b0; end            //DIR=0，意味着接下来要开始变暗了
    if (cs == 0) begin              //当cs达到.后，即占空比达到了0，灯最暗
        DIR <= 1'd1; end            //DIR=1，意味着接下来要开始变亮了
    end  
    assign  led = light;            //将寄存器中中保存的电平赋值给线路进行相应电平的输出    
        
    
endmodule