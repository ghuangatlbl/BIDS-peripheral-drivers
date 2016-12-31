`timescale 1ns / 1ns
module sporta_tb;

reg clk;

wire SCK, SDI, CS_7794, CS_3548, CS_BIAS, SDO_7794, SDO_BIAS;
reg SDO_3548;
wire stream_tick;
wire [15:0] stream;
wire [8:0] sconfig=9'h28; // led=0, gain=2(x4), filt=8(19.6 Hz)
wire [5:0] switch_sel=8'h15;
reg switch_op=0;

sporta mut(.clk(clk),
	.SCK(SCK), .SDI(SDI), .CS_7794(CS_7794), .CS_3548(CS_3548),
	.CS_BIAS(CS_BIAS), .SDO_7794(SDO_7794), .SDO_3548(SDO_3548),
	.SDO_BIAS(SDO_BIAS), .sconfig(sconfig),
	.switch_sel(switch_sel), .switch_op(switch_op),
	.stream(stream), .stream_tick(stream_tick));

integer cc;
initial begin
	if ($test$plusargs("vcd")) begin
		$dumpfile("sporta.vcd");
		$dumpvars(5,sporta_tb);
	end
	clk=0;
	for (cc=0; cc<50000; cc=cc+1) begin
		#10; clk=1;
		#11; clk=0;
	end
end

always @(posedge clk) begin
	switch_op <= cc==10000;
end

// Crude simulation of TLC3548
reg [15:0] sro_3548=0;
always @(posedge CS_3548) begin
	#30;
	SDO_3548 = 1'bz;
end
always @(negedge CS_3548) begin
	sro_3548 = 16'h1234;
	#30;
	SDO_3548 = sro_3548[15];
end
always @(posedge SCK) if (~CS_3548) begin
	SDO_3548 = 1'bx;
	#30;
	sro_3548 = {sro_3548[14:0],1'bx};
	SDO_3548 = sro_3548[15];
end

// Crude simulation of AD7794
reg d_7794=0;
always @(negedge SCK) d_7794 <= $random;
assign SDO_7794 = CS_7794 ? 1'bx : d_7794;

reg [7:0] sri_7794;
integer cnt_7794;
always @(negedge CS_7794) begin
	sri_7794 = 8'hxx;
	cnt_7794 = 0;
	$display("7794 CE");
end
always @(posedge SCK) if (~CS_7794) begin
	sri_7794 = {sri_7794[6:0],SDI};
	cnt_7794 = cnt_7794+1;
	if (cnt_7794 == 8) begin
		$display("7794 Rx %x", sri_7794);
		cnt_7794 = 0;
	end
end

// Instantiate real simulation of CPLD
bias_ctl bias(
	.SCK(SCK), .SDI(SDI), .STR(CS_BIAS),
	.Trip1(1'b0), .ON1(1'b0), .OFF1(1'b0),
	.Trip2(1'b0), .ON2(1'b0), .OFF2(1'b0),
	.Trip3(1'b0), .ON3(1'b0), .OFF3(1'b0),
	.SDO(SDO_BIAS)
);

endmodule
