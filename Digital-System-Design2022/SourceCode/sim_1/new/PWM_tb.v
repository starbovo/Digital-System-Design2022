`timescale 1ns / 1ps

module PWM_tb();
reg 	clk;
reg		rst_n;
reg     pwm_dip;
wire 	[14:0]	led;

initial		clk = 1;
always	#5	clk = ~clk;		//100M时钟

initial	begin
    pwm_dip=1;
	rst_n = 0;
	#500
	rst_n = 1;
end

pwm u_pwm(
    .clk     ( clk     ),
    .rst     ( rst_n   ),
    .pwm_dip ( pwm_dip ),
    .led     ( led     )
);

endmodule
