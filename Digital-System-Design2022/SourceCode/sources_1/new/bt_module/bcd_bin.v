`timescale 1ns / 1ps

module bcd_bin#(
    parameter  SIZE_bcd =8'd28  ,
    parameter  SIZE_bin =8'd24   
)
(
    input                       clk,
    input                       rstn,
    input       [SIZE_bcd-1:0]  data_bcd,
    output  reg [SIZE_bin-1:0]  data_bin,
    output  reg                 valid 
);

reg [ 7:0] cnt;
reg [SIZE_bcd-1:0] data_bcd_temp;
reg [SIZE_bin-1:0] data_bin_temp;

localparam  CYCCLE = SIZE_bcd/4;    //十进制位数

always @(posedge clk ) begin
    if (!rstn) begin
        cnt <= 0;
    end
    else begin
        if(cnt > CYCCLE)
            cnt <= 0;
        else
            cnt <= cnt +1;
    end
end

always @(posedge clk ) begin 
    if(!rstn ) begin
        valid <= 1'd0;    
        data_bcd_temp <= 0;
        data_bin_temp <= 0;
    end 
    else begin
        if ( cnt == 0 ) begin
            valid     <= 1'd0;
            data_bcd_temp <= data_bcd;
            data_bin_temp <= 0;
        end
        else if( cnt <= CYCCLE ) begin
            data_bin_temp <=  MULTI10(data_bin_temp) + data_bcd_temp[(SIZE_bcd+3-cnt*4)-:4];     //注意位索引写法，表示8'd43-cnt*4开始低4位
        end
        else if ( cnt == CYCCLE +1 ) begin
            data_bin <= data_bin_temp;
            valid    <= 1'd1;
        end
    end

end

//加法和位拼接：乘10运算--*8+*2 
//注意：输出数据位数
function [SIZE_bin-1:0] MULTI10 (input [SIZE_bin-1:0] a);   
begin
    MULTI10 = {a[SIZE_bin-4 :0],3'b000 } + {a[SIZE_bin-2 :0],1'b0 };      
end
endfunction

endmodule
