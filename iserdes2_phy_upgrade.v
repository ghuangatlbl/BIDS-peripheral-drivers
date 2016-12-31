`timescale 1ns / 10ps
module iserdes2_phy_upgrade
(
	clk_p_1, clk_n_1, ioce_1, clkdiv_1, bitslip_1,
	clk_p_2, clk_n_2, ioce_2, clkdiv_2, bitslip_2,
	da, db, dout,
	reset, reva_flag, revb_flag
);

input clk_p_1;
input clk_n_1;
input ioce_1;
input clkdiv_1;
input clk_p_2;
input clk_n_2;
input ioce_2;
input clkdiv_2;
input bitslip_1;
input bitslip_2;
input da;
input db;
input reva_flag;
input revb_flag;
input reset;
output [15:0] dout;

parameter SIM_TAP_DELAY = 49;
parameter OUTPUT_MODE = 0;
parameter FPGA_FAMILY = "SPARTAN6";
parameter DATA_WIDTH = ((OUTPUT_MODE==0)? 8:
					   (OUTPUT_MODE==1)? 7:
					   (OUTPUT_MODE==2)? 6:1);
wire temp=DATA_WIDTH;

iserdes2_phy #(
	.DATA_WIDTH(DATA_WIDTH)
) iserdes2_phy(
	.clk_p_1(clk_p_1), .clk_n_1(clk_n_1), .ioce_1(ioce_1),
	.clkdiv_1(clkdiv_1), .bitslip_1(bitslip_1),
	.clk_p_2(clk_p_2), .clk_n_2(clk_n_2), .ioce_2(ioce_2),
	.clkdiv_2(clkdiv_2), .bitslip_2(bitslip_2),
	.da(da), .db(db), .dout(dout),
	.reset(reset), .reva_flag(reva_flag), .revb_flag(revb_flag)
);
endmodule
