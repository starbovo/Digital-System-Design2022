`timescale 1ns / 1ps

module DDS8(
    input clk,          //10MHZ
    input rst_n,
    input [5:0] FRQ_W,  //频率控制字M
    output [13:0] o_wave
    );
    reg		[7:0]	phase_sum=0;
    wire	[7:0]	addr;
    wire    [7:0]   o_wave8bit;

    //相位累加器
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            phase_sum <= 8'd0;
        else 
            phase_sum <= phase_sum + FRQ_W;
    end

    assign addr = phase_sum[7:0];
    assign o_wave = {o_wave8bit,6'b000000};

    blk_mem_gen_0 rom_8_256 (
    .clka(clk),         // input wire clka
    .addra(addr),       // input wire [7 : 0] addra
    .douta(o_wave8bit)  // output wire [7 : 0] douta
    );
endmodule

module DDS14(
    input clk,              //10MHZ
    input rst_n,
    input [11:0] FRQ_W,     //频率控制字M
    output [13:0] o_wave
    );
    reg		[13:0]	phase_sum=0;
    wire	[13:0]	addr;

    //相位累加器
    always @(posedge clk or negedge rst_n)begin
        if(!rst_n)
            phase_sum <= 14'd0;
        else 
            phase_sum <= phase_sum + FRQ_W;
    end

    assign addr = phase_sum[13:0];

    blk_mem_gen_1 rom_14_16384 (
    .clka(clk),       // input wire clka
    .addra(addr),     // input wire [13 : 0] addra
    .douta(o_wave)    // output wire [13 : 0] douta
    );
endmodule

