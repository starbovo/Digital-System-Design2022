`timescale 1ns / 1ps

/*
please use GB2312 to open this file
designed by ZhaoJingxuan
final version in 2022/10/27
*/

module top_module(
    //100M时钟和复位信号
    input clk,
    input rst_n,

    //两个拨码开关和八个普通开关
    input   [1:0]   sw_mode,
    input   [7:0]   sw,

    //一个开关控制DDS频率控制字来源
    input dds_dip,
    input AM_dip,
    output dds_led,
    
    //呼吸灯15位输出，一个开关控制
    input pwm_dip,
    output [14:0] led,

    //串口引脚RX、TX
    input           rxd_pin,
    output          txd_pin,

    //蓝牙控制
    output bt_pw_on,
    output bt_master_slave,
    output bt_sw_hw,
    output bt_rst_n,
    output bt_sw,

    //AD和DA时钟
    output reg AD_clk,
    output reg DA_clk,

    //10位AD输入
    input   [9:0]   AD_in,

    //DA输出
    output [13:0] DA_out,//提供给DA转换器的信号

    //数码管引脚
    output [3:0] an1,   //片选
    output [7:0] sseg1,  //段选
    output [3:0] an2,   //片选
    output [7:0] sseg2  //段选

    );

    //十分频出来的10M时钟
    wire clk_div10;

    //DDS相关信号
    reg     [13:0]  o_wave;
    wire    [13:0]  sw_wave,bt_wave;
    reg             dds_state = 1'b0;           //DDS输出模式标志（sw or bt）

    wire signed	[13:0]	AM_mod;

    //下面是一堆数码管中间信号
    wire    [3:0]   DA0,DA1,DA2,DA3,DA4,DA5,DA6;
    wire    [3:0]   AD0,AD1,AD2,AD3,AD4,AD5,AD6;
    reg     [3:0]   num0,num1,num2,num3,num4,num5,num6,num7,dp0,dp1;

    //蓝牙接收到的数据的BCD信号（8位数字）
    wire    [31:0]  bt_data32;

    //经过溢出检查（计算后不超过2M）后的开关信号
    reg     [7:0]   sw_fil;

    //串口数据转二进制
    wire    [23:0]  bt_bin;             //转换为二进制之后的串口数据
    wire            bt_valid;           //转换可用标志

    //串口数据溢出检查
    reg     [20:0]  btbin_fil;          //经过溢出检查之后的串口数据
    wire    [11:0]  bt_fil;             //串口数据转化成的频率控制字
    wire    [35:0]  mid_var;            //计算中间变量，因为verilog隐藏线型最大32位不够

    //十分频时钟
        freq_div10#(
        .DIV_0CLK ( 10 )
        )clkdiv10(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .clk_div10  ( clk_div10  )
        );

    //将10M时钟给AD和DA模块的时钟
    always@(*)begin
        AD_clk<=clk_div10;
        DA_clk<=clk_div10;
    end

    //通过两位拨码开关选择模式
    always @(*)         
        begin
            case(sw_mode)
                2'b00:begin    //00显示2022+学号后四位（0118）
                    num7=4'h2;
                    num6=4'h0;
                    num5=4'h2;
                    num4=4'h2;
                    num3=4'h0;
                    num2=4'h1;
                    num1=4'h1;
                    num0=4'h8;
                    dp0=4'b1000;
                    dp1=4'b0000;
                  end    
                2'b01: begin    //01显示开关控制下的输出频率
                    num7=4'h0;
                    num6=DA6;
                    num5=DA5;
                    num4=DA4;
                    num3=DA3;
                    num2=DA2;
                    num1=DA1;
                    num0=DA0;
                    dp0=4'b0000;
                    dp1=4'b0001;
                    end
                2'b10: begin    //10显示AD测量频率结果
                    num7=4'h0;
                    num6=AD6;
                    num5=AD5;
                    num4=AD4;
                    num3=AD3;
                    num2=AD2;
                    num1=AD1;
                    num0=AD0;
                    dp0=4'b0000;
                    dp1=4'b0001;
                    end
                2'b11: begin    //11显示蓝牙控制下的输出频率
                    num7=bt_data32[31:28];
                    num6=bt_data32[27:24];
                    num5=bt_data32[23:20];
                    num4=bt_data32[19:16];
                    num3=bt_data32[15:12];
                    num2=bt_data32[11:8];
                    num1=bt_data32[7:4];
                    num0=bt_data32[3:0];
                    dp0=4'b0000;
                    dp1=4'b0001;
                end
            endcase
        end

    //溢出判断
    always @(*) begin               //开关输入的溢出判断
    //fout为2M时，频率控制字为2M*(2^8)/10M=8'd51=8'b00110011
        if(sw>8'b00110011)begin     //超出110011则赋为它
            sw_fil <= 8'b00110011;
        end
        else begin                  //未超出则保持原值
            sw_fil <= sw;
        end
    end
    always @(*) begin               //蓝牙输入的溢出判断
        if(bt_valid)begin
            if(bt_bin>24'd2000000)begin
                btbin_fil<=24'd2000000;
            end
            else begin
                btbin_fil<=bt_bin;
            end
        end
    end
    //频率控制字为fout*10M/2^14
    //因为要求误差小于2KHZ，意味着频率步进缩小到4KHZ
    //此时最小深度为4KHZ/(1*10MHZ)=2^14
    //所以蓝牙DDS输出时要采用不同的coe文件
    assign mid_var = (btbin_fil<<14);
    assign bt_fil = mid_var/10000000;

    //开关切换频率控制字来源，如果是蓝牙模式灯亮
    always@(*) begin
        if(AM_dip)
            o_wave<=AM_mod;
        else begin
            if(dds_dip)begin
                dds_state <= 1;
                o_wave<=bt_wave;
            end
            else begin
                dds_state <= 0;
                o_wave<=sw_wave;
            end
        end
    end
    assign dds_led = dds_state;
    assign DA_out = o_wave;

    //例化两个DDS
    DDS8 swdds(             //8*2^8 DDS
        .clk   ( clk_div10  ),
        .rst_n ( rst_n      ),
        .FRQ_W ( sw_fil[5:0]),
        .o_wave( sw_wave    )
    );
    DDS14 btdds(            //14*2^14 DDS
        .clk   ( clk_div10 ),
        .rst_n ( rst_n     ),
        .FRQ_W ( bt_fil    ),
        .o_wave( bt_wave   )
    );

    //例化AD测频模块
    AD_fre u_AD_fre(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .AD_in ( AD_in ),
        .AD0   ( AD0   ),
        .AD1   ( AD1   ),
        .AD2   ( AD2   ),
        .AD3   ( AD3   ),
        .AD4   ( AD4   ),
        .AD5   ( AD5   ),
        .AD6   ( AD6   )
    );

    //例化蓝牙接收模块
    bt_uart u_bt_uart(
        .clk_pin         ( clk             ),
        .rst_pin         ( rst_n           ),
        .rxd_pin         ( rxd_pin         ),
        .txd_pin         ( txd_pin         ),
        .bt_pw_on        ( bt_pw_on        ),
        .bt_master_slave ( bt_master_slave ),
        .bt_sw_hw        ( bt_sw_hw        ),
        .bt_rst_n        ( bt_rst_n        ),
        .bt_sw           ( bt_sw           ),
        .bt_data32       ( bt_data32       )
    );

    //例化28bitsBCD码转24bits二进制模块
    bcd_bin#(
        .SIZE_bcd ( 28 ),
        .SIZE_bin ( 24 )
    )u_bcd_bin(
        .clk      ( clk              ),
        .rstn     ( rst_n            ),
        .data_bcd ( bt_data32[27:0]  ),
        .data_bin ( bt_bin           ),
        .valid    ( bt_valid         )
    );

    //例化24bits二进制转28bitsBCD码模块
    sw_BCD swin(        //开关输入的信号转BCD码
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .sw    ( sw_fil),
        .ones  ( DA0  ),
        .tens  ( DA1  ),
        .huns  ( DA2  ),
        .thous ( DA3  ),
        .tenk  ( DA4  ),
        .hunk  ( DA5  ),
        .onem  ( DA6  )
    );

    //八个数码管例化
    seg_display seg_left(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .hex0  ( num7  ),
        .hex1  ( num6  ),
        .hex2  ( num5  ),
        .hex3  ( num4  ),
        .dp_in ( dp0   ),
        .an    ( an1   ),
        .sseg  ( sseg1 )
    );
    seg_display seg_right(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .hex0  ( num3  ),
        .hex1  ( num2  ),
        .hex2  ( num1  ),
        .hex3  ( num0  ),
        .dp_in ( dp1   ),
        .an    ( an2   ),
        .sseg  ( sseg2 )
    );

    //呼吸灯模块例化
    pwm u_pwm(
        .clk     ( clk     ),
        .rst     ( rst_n   ),
        .pwm_dip ( pwm_dip ),
        .led     ( led     )
    );
    AM_create u_AM_create(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .AM_mod  ( AM_mod  )
    );


endmodule