`timescale 1ns / 1ps

/*
please use GB2312 to open this file
designed by ZhaoJingxuan
final version in 2022/10/27
*/

module top_module(
    //100Mʱ�Ӻ͸�λ�ź�
    input clk,
    input rst_n,

    //�������뿪�غͰ˸���ͨ����
    input   [1:0]   sw_mode,
    input   [7:0]   sw,

    //һ�����ؿ���DDSƵ�ʿ�������Դ
    input dds_dip,
    input AM_dip,
    output dds_led,
    
    //������15λ�����һ�����ؿ���
    input pwm_dip,
    output [14:0] led,

    //��������RX��TX
    input           rxd_pin,
    output          txd_pin,

    //��������
    output bt_pw_on,
    output bt_master_slave,
    output bt_sw_hw,
    output bt_rst_n,
    output bt_sw,

    //AD��DAʱ��
    output reg AD_clk,
    output reg DA_clk,

    //10λAD����
    input   [9:0]   AD_in,

    //DA���
    output [13:0] DA_out,//�ṩ��DAת�������ź�

    //���������
    output [3:0] an1,   //Ƭѡ
    output [7:0] sseg1,  //��ѡ
    output [3:0] an2,   //Ƭѡ
    output [7:0] sseg2  //��ѡ

    );

    //ʮ��Ƶ������10Mʱ��
    wire clk_div10;

    //DDS����ź�
    reg     [13:0]  o_wave;
    wire    [13:0]  sw_wave,bt_wave;
    reg             dds_state = 1'b0;           //DDS���ģʽ��־��sw or bt��

    wire signed	[13:0]	AM_mod;

    //������һ��������м��ź�
    wire    [3:0]   DA0,DA1,DA2,DA3,DA4,DA5,DA6;
    wire    [3:0]   AD0,AD1,AD2,AD3,AD4,AD5,AD6;
    reg     [3:0]   num0,num1,num2,num3,num4,num5,num6,num7,dp0,dp1;

    //�������յ������ݵ�BCD�źţ�8λ���֣�
    wire    [31:0]  bt_data32;

    //���������飨����󲻳���2M����Ŀ����ź�
    reg     [7:0]   sw_fil;

    //��������ת������
    wire    [23:0]  bt_bin;             //ת��Ϊ������֮��Ĵ�������
    wire            bt_valid;           //ת�����ñ�־

    //��������������
    reg     [20:0]  btbin_fil;          //����������֮��Ĵ�������
    wire    [11:0]  bt_fil;             //��������ת���ɵ�Ƶ�ʿ�����
    wire    [35:0]  mid_var;            //�����м��������Ϊverilog�����������32λ����

    //ʮ��Ƶʱ��
        freq_div10#(
        .DIV_0CLK ( 10 )
        )clkdiv10(
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .clk_div10  ( clk_div10  )
        );

    //��10Mʱ�Ӹ�AD��DAģ���ʱ��
    always@(*)begin
        AD_clk<=clk_div10;
        DA_clk<=clk_div10;
    end

    //ͨ����λ���뿪��ѡ��ģʽ
    always @(*)         
        begin
            case(sw_mode)
                2'b00:begin    //00��ʾ2022+ѧ�ź���λ��0118��
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
                2'b01: begin    //01��ʾ���ؿ����µ����Ƶ��
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
                2'b10: begin    //10��ʾAD����Ƶ�ʽ��
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
                2'b11: begin    //11��ʾ���������µ����Ƶ��
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

    //����ж�
    always @(*) begin               //�������������ж�
    //foutΪ2Mʱ��Ƶ�ʿ�����Ϊ2M*(2^8)/10M=8'd51=8'b00110011
        if(sw>8'b00110011)begin     //����110011��Ϊ��
            sw_fil <= 8'b00110011;
        end
        else begin                  //δ�����򱣳�ԭֵ
            sw_fil <= sw;
        end
    end
    always @(*) begin               //�������������ж�
        if(bt_valid)begin
            if(bt_bin>24'd2000000)begin
                btbin_fil<=24'd2000000;
            end
            else begin
                btbin_fil<=bt_bin;
            end
        end
    end
    //Ƶ�ʿ�����Ϊfout*10M/2^14
    //��ΪҪ�����С��2KHZ����ζ��Ƶ�ʲ�����С��4KHZ
    //��ʱ��С���Ϊ4KHZ/(1*10MHZ)=2^14
    //��������DDS���ʱҪ���ò�ͬ��coe�ļ�
    assign mid_var = (btbin_fil<<14);
    assign bt_fil = mid_var/10000000;

    //�����л�Ƶ�ʿ�������Դ�����������ģʽ����
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

    //��������DDS
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

    //����AD��Ƶģ��
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

    //������������ģ��
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

    //����28bitsBCD��ת24bits������ģ��
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

    //����24bits������ת28bitsBCD��ģ��
    sw_BCD swin(        //����������ź�תBCD��
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

    //�˸����������
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

    //������ģ������
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