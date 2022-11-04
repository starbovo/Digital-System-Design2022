`timescale 1ns / 1ps

module AD_fre(
    input clk,
    input rst_n,
    input   [9:0]   AD_in,
    output  [3:0]   AD0,
    output  [3:0]   AD1,
    output  [3:0]   AD2,
    output  [3:0]   AD3,
    output  [3:0]   AD4,
    output  [3:0]   AD5,
    output  [3:0]   AD6
    );
    wire clk_div10;
    //测频输入的方波信号
    reg clk_fx;

    //测频输出的频率
    wire [31:0] fre;

    //用来获知AD输入平均电压的东西
    reg [9:0] max,min;
    wire [9:0] zero;

    always@(posedge clk_div10)
    begin
        if(!rst_n)begin
            max=10'd100;
            min=10'd100;
        end
        else if(AD_in > max)
            max <= AD_in;
        else if(AD_in < min) 
            min <= AD_in;
        end

    assign zero = (max+min)/2;

    always@(posedge clk_div10)
        begin
          if(AD_in[9:5] > zero[9:5])
                clk_fx <= 1'b1;         
          else if(AD_in[9:5] < zero[9:5])
                clk_fx <= 1'b0;   
          else
                clk_fx <= clk_fx;
        end


    cymometer_direct cymometer_direct1(
    .clk    ( clk    ),
    .rst_n  ( rst_n  ),
    .clk_fx ( clk_fx ),
    .fre    ( fre )
    );


    binary_bcd ADfre_BCD(
        .clk    ( clk    ),
        .rst_n  ( rst_n  ),
        .bin_in ( fre[23:0] ),
        .ones   ( AD0   ),
        .tens   ( AD1   ),
        .huns   ( AD2   ),
        .thous  ( AD3   ),
        .tenk   ( AD4   ),
        .hunk   ( AD5   ),
        .onem   ( AD6   )
    );

    freq_div10 div10(
        clk,
        rst_n,
        clk_div10
    );
endmodule
