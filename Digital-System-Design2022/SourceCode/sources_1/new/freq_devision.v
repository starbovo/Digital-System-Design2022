`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/17 14:29:42
// Design Name: 
// Module Name: freq_devision
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module freq_div10
 # (parameter DIV_0CLK = 10 )
 (
    input clk,
    input rst_n,
    output clk_div10
    );
    reg [15:0]            cnt ;
    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         cnt    <= 'b0 ;
      end
      else if (cnt == (DIV_0CLK/2)-1) begin
         cnt    <= 'b0 ;
      end
      else begin
         cnt    <= cnt + 1'b1 ;
      end
    end
   reg clk_div10_r ;
   always @(posedge clk or negedge rst_n)
   begin
      if (!rst_n)
      begin
         clk_div10_r <= 1'b0 ;
      end
      else if (cnt == (DIV_0CLK/2)-1 ) begin
         clk_div10_r <= ~clk_div10_r ;
      end
   end
   assign clk_div10 = clk_div10_r ;
endmodule

//module freq_devision
// # (parameter DIV_CLK = 10000 )
// (
//    input clk,
//    input rst_n,
//    output clk_div10
//    );
//    reg [15:0]            cnt ;
//    always @(posedge clk or negedge rst_n) begin
//      if (!rst_n) begin
//         cnt    <= 'b0 ;
//      end
//      else if (cnt == (DIV_CLK/2)-1) begin
//         cnt    <= 'b0 ;
//      end
//      else begin
//         cnt    <= cnt + 1'b1 ;
//      end
//    end
   
//   reg clk_div10_r ;
//   always @(posedge clk or negedge rst_n)
//   begin
//      if (!rst_n)
//      begin
//         clk_div10_r <= 1'b0 ;
//      end
//      else if (cnt == (DIV_CLK/2)-1 ) begin
//         clk_div10_r <= ~clk_div10_r ;
//      end
//   end
//   assign clk_div10 = clk_div10_r ;
//endmodule
//module div108(
//    input clk,
//    input rst_n,
//    output clk_div104,
//    output clk_div108
//);
//freq_devision div1(
//    clk,
//    rst_n,
//    clk_div104
//);
//assign clk_input=clk_div104;
//freq_devision div2(
//    clk_input,
//    rst_n,
//    clk_div108
//);
//endmodule

