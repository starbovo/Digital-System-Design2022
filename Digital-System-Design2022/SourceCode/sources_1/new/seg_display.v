`timescale 1ns / 1ps

module seg_display(
    input clk,
    input rst_n,
    input [3:0] hex0, //第一个数码管显示的数字
    input [3:0] hex1,
    input [3:0] hex2,
    input [3:0] hex3,
    input [3:0] dp_in, //小数点控制
    output reg [3:0] an,   //片选
    output reg [7:0] sseg  //段选
    );

      wire [1:0] s;     
      reg [3:0] digit;
      wire [3:0] aen;
      reg [19:0] clkdiv;
      reg dp;
      assign s = clkdiv[19:18];
      assign aen = 4'b1111; // all turned off initially
      
      always @(posedge clk)// or posedge clr)
      begin
         case(s)
            0:begin
               digit = hex0;
               dp = dp_in[0]; // s is 00 -->0 ;  digit gets assigned 4 bit value assigned to x[3:0]
            end
            1:begin
               digit = hex1;
               dp = dp_in[1]; // s is 01 -->1 ;  digit gets assigned 4 bit value assigned to x[7:4]
            end
            2:begin
               digit = hex2;
               dp = dp_in[2]; // s is 10 -->2 ;  digit gets assigned 4 bit value assigned to x[11:8
            end
            3:begin
               digit = hex3;
               dp = dp_in[3]; // s is 11 -->3 ;  digit gets assigned 4 bit value assigned to x[15:12]
            end
            default:digit = hex0;
         endcase
      end
      always@(*)
         begin
            case(digit)
               4'h0: sseg[6:0] = 7'b1111110; //共阴极数码管
               4'h1: sseg[6:0] = 7'b0110000;
               4'h2: sseg[6:0] = 7'b1101101;
               4'h3: sseg[6:0] = 7'b1111001;
               4'h4: sseg[6:0] = 7'b0110011;
               4'h5: sseg[6:0] = 7'b1011011;
               4'h6: sseg[6:0] = 7'b1011111;
               4'h7: sseg[6:0] = 7'b1110000;
               4'h8: sseg[6:0] = 7'b1111111;
               4'h9: sseg[6:0] = 7'b1111011;
               4'ha: sseg[6:0] = 7'b1110111;
               4'hb: sseg[6:0] = 7'b0011111;
               4'hc: sseg[6:0] = 7'b1001110;
               4'hd: sseg[6:0] = 7'b0111101;
               4'he: sseg[6:0] = 7'b1001111;
               default: sseg[6:0] = 7'b1000111;
            endcase
         sseg[7] = dp;
         end

      always @(*)begin
         an=4'b0000;
         if(aen[s] == 1)
            an[s] = 1;
      end

      //clkdiv
      always @(posedge clk or negedge rst_n) begin
         if (!rst_n)
            clkdiv <= 0;
         else
            clkdiv <= clkdiv+1;
      end

endmodule
