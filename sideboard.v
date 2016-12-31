// Synthesizes to ???? slices and ? MULT18X18 at 135 MHz in XC3Sxxx-4 using XST-9.2.04i
`timescale 1ns / 1ns

module sideboard(
	input clk,
	// board config
	input [8:0] sconfig,
	// dac
	input sdac_ref_sclk,
	input sdac_trig,
	input [15:0] out1,
	input [15:0] out2,
	input [15:0] out3,
	input [15:0] out4,
	output dac_sb_sclk,
	output [2:0] dac_sb_sdio,
	output dac_sb_csb,
	// switch
	input switch_op,
	input  [2:0] photo_sw,
	inout CS_BIAS,   // O5  J2-9   J3-12  L4N
	input SDO_BIAS,  // I1  J2-15  J3-6   L2P
	//side board support for 7794 3548 CPLD
	inout SCK,       // O1  J2-4   J3-17  L6N
	inout SDI,       // O3  J2-6   J3-15  L5N
	// adc for bias supply
	inout CS_3548,   // O4  J2-7   J3-14  L5P
	input SDO_3548,  // I3  J2-17  J3-4   L1P
	// adc for thermistor
	inout CS_7794,   // O2  J2-5   J3-16  L6P
	input SDO_7794,  // I2  J2-16  J3-5   L1N
	// exploded results
	output [13:0] v10,  // I chan 1
	output [13:0] v11,  // I chan 2
	output [13:0] v12,  // I chan 3
	output [13:0] v13,  // V chan 1
	output [13:0] v14,  // V chan 2
	output [13:0] v15,  // V chan 3
	output [13:0] v16,  // J18 (if R63 populated)
	output [13:0] v17,  // J17 (if R61 populated)
	output [23:0] v20,
	output [23:0] v21,
	output [23:0] v22,
	output [23:0] v23
);

/*
reg [8:0] count=0;
reg sdac_trig=0;
reg [3:0] ref_cnt=0;
reg ref_sclk=0;
always @(posedge clk) begin
	count<=count+1;
	//sdac_trig <= cic_sync;
	sdac_trig <= count==0;
	if (sdac_trig) dac_addr=dac_addr+1;
	ref_cnt <= (ref_cnt==2) ? 0 : (ref_cnt+1);
	if (~ (|ref_cnt)) ref_sclk <= ~ref_sclk;
end
*/
reg [15:0] outsb=16'b0;//,outsb0=16'b0, outsb1=16'b0, outsb2=16'b0, outsb3=16'b0;
reg [1:0] dac_addr=0,dac_addr_d=0;
always @(posedge clk) begin
	if (sdac_trig) dac_addr=dac_addr+1;
	dac_addr_d <= dac_addr;
	case (dac_addr)
		2'd0: begin outsb <= out1; end  //from lo loop
		2'd1: begin outsb <= out2; end  //from vcxo ctrl loop
		2'd2: begin outsb <= out3; end  //from vcxo ctrl loop to iq phase shifter
		2'd3: begin outsb <= out4; end  //from vcxo ctrl loop to iq phase shifter
	endcase
end


ad56x4_driver3 dac_sideboard(.clk(clk),.ref_sclk(sdac_ref_sclk),.sdac_trig(sdac_trig),.addr({1'b0,dac_addr_d}),
	.voltage1(outsb),.voltage2(outsb),.voltage3(outsb),
	.reconfig(1'b0), .internal_ref(1'b0),  // XXX check me
	.sclk(dac_sb_sclk),.sdio(dac_sb_sdio),.csb(dac_sb_csb)
);

wire [5:0] switch_sel = {~photo_sw[2],photo_sw[2],~photo_sw[1],photo_sw[1],~photo_sw[0],photo_sw[0]};

wire [15:0] sporta_stream;
wire stream_tick;
//`define DEBUG_SPORTA
`ifdef DEBUG_SPORTA
// remove it here, instantiate it in llrf4_dsp.vh instead
assign stream_tick=0;
assign sporta_stream=0;
`else
sporta sporta(.clk(clk),
	.SCK(SCK), .SDI(SDI), .CS_7794(CS_7794), .CS_3548(CS_3548),
	.CS_BIAS(CS_BIAS), .SDO_7794(SDO_7794), .SDO_3548(SDO_3548),
	.SDO_BIAS(SDO_BIAS), .sconfig(sconfig),
	.switch_sel(switch_sel), .switch_op(switch_op),
	.stream(sporta_stream), .stream_tick(stream_tick));
`endif
//always @(posedge clk) if (stream_tick) stream_r <= sporta_stream;

wire [7:0] adc1_gate;
wire [13:0] adc1_data;
wire [3:0] adc2_gate;
wire [23:0] adc2_data;
wire [7:0] sporta_fifo;
reg [9:0] sportout_cnt=0;
always @(posedge clk) begin
	sportout_cnt<=sportout_cnt+1;
end
sporta_demux sb_dmux(.clk(clk), .stream(sporta_stream),.stream_tick(stream_tick),.adc1_gate(adc1_gate),.adc1_data(adc1_data),.adc2_gate(adc2_gate),.adc2_data(adc2_data),.oaddr_sync(sportout_cnt[9]),.oaddr(sportout_cnt[5:2]),.fifo_out(sporta_fifo));

reg [13:0] voltage1_0=0,voltage1_1=0,voltage1_2=0,voltage1_3=0,voltage1_4=0,voltage1_5=0,voltage1_6=0,voltage1_7=0;
reg [23:0] voltage2_0=0,voltage2_1=0,voltage2_2=0,voltage2_3=0;
always @(posedge clk) begin
	if (adc1_gate[0]) voltage1_0 <= adc1_data;
	if (adc1_gate[1]) voltage1_1 <= adc1_data;
	if (adc1_gate[2]) voltage1_2 <= adc1_data;
	if (adc1_gate[3]) voltage1_3 <= adc1_data;
	if (adc1_gate[4]) voltage1_4 <= adc1_data;
	if (adc1_gate[5]) voltage1_5 <= adc1_data;
	if (adc1_gate[6]) voltage1_6 <= adc1_data;
	if (adc1_gate[7]) voltage1_7 <= adc1_data;

	if (adc2_gate[0]) voltage2_0 <= adc2_data;
	if (adc2_gate[1]) voltage2_1 <= adc2_data;
	if (adc2_gate[2]) voltage2_2 <= adc2_data;
	if (adc2_gate[3]) voltage2_3 <= adc2_data;
end
assign v10=voltage1_0;
assign v11=voltage1_1;
assign v12=voltage1_2;
assign v13=voltage1_3;
assign v14=voltage1_4;
assign v15=voltage1_5;
assign v16=voltage1_6;
assign v17=voltage1_7;
assign v20=voltage2_0;
assign v21=voltage2_1;
assign v22=voltage2_2;
assign v23=voltage2_3;
endmodule
