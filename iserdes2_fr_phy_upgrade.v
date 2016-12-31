`timescale 1ns / 10ps
module iserdes2_fr_phy_upgrade #(
	parameter OUTPUT_MODE=0,
	parameter       SIM_TAP_DELAY = 49
)
(
	clk_p,clk_n,ioce,clkdiv,
	bitslip,da,dout,reset,reva_flag
);
input clk_p;
input clk_n;
input reva_flag;
input ioce;
input clkdiv;
input bitslip;
input da;
input reset;

output [15:0] dout;

// FR + 4A + 4B
wire shift_wire_a,shift_wire_b;
wire [7:0] data_a, data_b;
wire ddly_a_m;
localparam DATA_WIDTH=((OUTPUT_MODE==0)?8:
					   (OUTPUT_MODE==1)?7:
					   (OUTPUT_MODE==2)?6:1);
iserdes2_fr_phy #(
	.DATA_WIDTH(DATA_WIDTH)
) iserdes2_fr_phy(
	.clk_p(clk_p), .clk_n(clk_n), .ioce(ioce), .clkdiv(clkdiv),
	.bitslip(bitslip), .da(da), .dout(dout), .reset(reset), .reva_flag(reva_flag)
);
endmodule
