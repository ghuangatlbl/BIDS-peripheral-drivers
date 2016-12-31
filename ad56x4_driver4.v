`timescale 1ns / 1ns
// Synthesizes to 79 slices at 172 MHz in XC3Sxxx-4 using XST-8.2i

module ad56x4_driver4(
	input clk,  // timespec 5.8 ns
	input ref_sclk,
	input sdac_trig,
	input reconfig,       // single cycle trigger for reconfigure operation
	input internal_ref,   // used on FPGA boot and module reconfig
	input [2:0] addr1,
	input [2:0] addr2,
	input [2:0] addr3,
	input signed [15:0] voltage1,
	input signed [15:0] voltage2,
	input signed [15:0] voltage3,
	input load1,
	input load2,
	input load3,
	output busy,
	output reg sclk,
	output reg [2:0] sdio,
	output reg csb
);

// start simple: output shift registers, one per slow DAC
// heavily cribbed from ad56x4_driver.v and acoustic_engine.v

// modified from ad56x4_driver2.v to allow slowdown; the ad56x4
// is capable of 50 MHz, but we could clock as high as 120 MHz,
// and the cables and drivers getting to this chip on the expansion
// board run out of steam at about 10 MHz.
reg [23:0] sdac1_data=0, sdac2_data=0, sdac3_data=0;
reg [4:0] sdac_cnt=0;
reg ref_sclk1=0, ref_sclk2=0, step=0, sdac_pend=0;
reg sdac_send=0, sdac_shift=0, sdac_power=0;

// addr coding from AD56x4R data sheet Table 9:
//  3'b000  DAC A
//  3'b001  DAC B
//  3'b010  DAC C
//  3'b011  DAC D
//  3'b111  All DACs

// convert voltage from signed to offset binary
wire  [4:0] write1  =  5'b00011;              // Write to and update DAC
wire [23:0] config1 = {8'b00111000, 15'b0, internal_ref};   // reference setup on command
wire [23:0] sdac1_par = sdac_power ?  {write1, addr1, ~voltage1[15], voltage1[14:0]} : config1 ;
wire [23:0] sdac2_par = sdac_power ?  {write1, addr2, ~voltage2[15], voltage2[14:0]} : config1 ;
wire [23:0] sdac3_par = sdac_power ?  {write1, addr3, ~voltage3[15], voltage3[14:0]} : config1 ;
// fully ignore triggers and load commands that come in while we're running
wire start = sdac_trig & ~sdac_send;
wire load1v = load1 & ~sdac_send;
wire load2v = load2 & ~sdac_send;
wire load3v = load3 & ~sdac_send;
assign busy = sdac_pend | sdac_send;

always @(posedge clk) begin
	ref_sclk1 <= ref_sclk;
	ref_sclk2 <= ref_sclk1;
	step <= ~ref_sclk & ref_sclk1;
	if (start | step) sdac_pend <= start;
	if (start | reconfig) sdac_power <= ~reconfig;
	if ((sdac_pend | (sdac_cnt == 24)) & step) sdac_send <= sdac_pend;
	if ((sdac_pend |  sdac_send ) & step) sdac_cnt <= sdac_pend ? 0 : sdac_cnt+1;
	sdac_shift <= sdac_send & step;
	if (load1v | sdac_shift) sdac1_data <= load1v ? sdac1_par : {sdac1_data[22:0],1'b0};
	if (load2v | sdac_shift) sdac2_data <= load2v ? sdac2_par : {sdac2_data[22:0],1'b0};
	if (load3v | sdac_shift) sdac3_data <= load3v ? sdac3_par : {sdac3_data[22:0],1'b0};
	sclk <= ref_sclk2 & sdac_send & (sdac_cnt != 24);
	sdio <= {sdac3_data[23], sdac2_data[23], sdac1_data[23]};
	csb  <= ~sdac_send;
end

endmodule
