`timescale 1ns / 1ps
`define    Clock 10 //时钟周期
module bluebooth_tb();
    reg clk;
    reg rst_n1,rst_n0;
    wire    clk_div10;
    reg    [31:0]  bt_data32;
    wire    [23:0]  bt_bin;             //转换为二进制之后的串口数据
    wire            bt_valid;           //转换可用标志
    reg     [20:0]  btbin_fil;          //经过溢出检查之后的串口数据
    wire    [11:0]  bt_fil;             //串口数据转化成的频率控制字
    wire    [35:0]  mid_var;            //计算中间变量，因为verilog隐藏线型最大32位不够
    wire    [13:0]  bt_wave;

    initial begin
        clk = 0;
        bt_data32={4'h0,4'h0,4'h7,4'h8,4'h0,4'h0,4'h0,4'h0};
        forever
            #(`Clock/2) clk = ~clk;
    end
    initial begin
        rst_n1 = 0;
        rst_n0 = 0;
        #(`Clock*20+1);
        rst_n0 = 1;//快复位
        #(`Clock*20+1);
        rst_n1 = 1;//慢复位
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
    assign mid_var = (btbin_fil<<14);
    assign bt_fil = mid_var/10000000;

    //十分频时钟
        freq_div10#(
        .DIV_0CLK ( 10 )
        )clkdiv10(
        .clk   ( clk   ),
        .rst_n ( rst_n1 ),
        .clk_div10  ( clk_div10  )
        );

    //例化28bitsBCD码转24bits二进制模块
    bcd_bin#(
        .SIZE_bcd ( 28 ),
        .SIZE_bin ( 24 )
    )u_bcd_bin(
        .clk      ( clk              ),
        .rstn     ( rst_n0            ),
        .data_bcd ( bt_data32[27:0]  ),
        .data_bin ( bt_bin           ),
        .valid    ( bt_valid         )
    );
    DDS14 btdds(            //14*2^14 DDS
        .clk   ( clk_div10 ),
        .rst_n ( rst_n0     ),
        .FRQ_W ( bt_fil    ),
        .o_wave( bt_wave   )
    );

endmodule
