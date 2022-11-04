`timescale 1ns / 1ps

    module binary_bcd(
    input clk,
    input rst_n,
    input [23:0] bin_in,
    output reg [3:0] ones,
    output reg [3:0] tens,
    output reg [3:0] huns,
    output reg [3:0] thous,
    output reg [3:0] tenk,
    output reg [3:0] hunk,
    output reg [3:0] onem
    );
    integer i;
    always @(posedge clk, negedge rst_n) 
    begin
    if(!rst_n) begin
   	ones 		= 4'd0;
	tens 		= 4'd0;
	huns 	    = 4'd0;
    thous 		= 4'd0;
    tenk 		= 4'd0;
    hunk 		= 4'd0;
    onem 		= 4'd0;
    end
    else begin
	ones 		= 4'd0;
	tens 		= 4'd0;
	huns 	    = 4'd0;
    thous 		= 4'd0;
    tenk 		= 4'd0;
    hunk 		= 4'd0;
    onem 		= 4'd0;
	
	for(i = 23; i >= 0; i = i - 1) begin
		if (ones >= 4'd5) 	ones = ones + 4'd3;
		if (tens >= 4'd5) 	tens = tens + 4'd3;
		if (huns >= 4'd5)   huns = huns + 4'd3;
        if (thous>= 4'd5)   thous= thous+ 4'd3;
        if (tenk >= 4'd5)   tenk = tenk + 4'd3;
        if (hunk >= 4'd5)   hunk = hunk + 4'd3;
        if (onem >= 4'd5)   onem = onem + 4'd3;
        onem    = { onem[2:0]  ,hunk[3]   };
        hunk    = { hunk[2:0]  ,tenk[3]   };
        tenk    = { tenk[2:0]  ,thous[3]  };
        thous   = { thous[2:0] ,huns[3]   };
		huns    = { huns[2:0]  ,tens[3]   };
		tens    = { tens[2:0]  ,ones[3]   };
		ones    = { ones[2:0]  ,bin_in[i] };
	end
 
    end
 end
endmodule

module sw_BCD(
    input clk,
    input rst_n,
    input [7:0] sw,
    output  [3:0] ones,
    output  [3:0] tens,
    output  [3:0] huns,
    output  [3:0] thous,
    output  [3:0] tenk,
    output  [3:0] hunk,
    output  [3:0] onem
    );
	wire [23:0] bin_in;
    assign bin_in = ((sw*10000000)>>8);

    binary_bcd binary_bcd0(
        .clk    ( clk    ),
        .rst_n  ( rst_n  ),
        .bin_in ( bin_in ),
        .ones   ( ones   ),
        .tens   ( tens   ),
        .huns   ( huns   ),
        .thous  ( thous  ),
        .tenk   ( tenk   ),
        .hunk   ( hunk   ),
        .onem   ( onem   )
    );
    endmodule
    