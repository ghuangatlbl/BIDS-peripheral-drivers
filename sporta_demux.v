`timescale 1ns / 1ns

module sporta_demux(
	input clk,  // timespec 8.0 ns
	input [15:0] stream,
	input stream_tick,

	output reg [13:0] adc1_data,
	output reg [7:0] adc1_gate,

	output reg [23:0] adc2_data,
	output reg [3:0] adc2_gate,

	input oaddr_sync, // wire to haddr[7]: falling edge triggers FIFO reload
	input [3:0] oaddr,
	output [7:0] fifo_out
);

// This Verilog module parallels mode5x.c
wire [7:0] d   = stream[7:0];
wire       c3z = stream[8];
wire [3:0] c4  = stream[12:9];
wire       c5z = stream[13];
wire [1:0] c6  = stream[15:14];

reg [3:0] c3=0;
reg [7:0] lastd1=0, lastd2=0;
always @(posedge clk) begin
	adc1_gate <= 0;
	adc2_gate <= 0;
	if (stream_tick) begin
		c3 <= c3z ? 0 : c3+1;
		lastd1 <= d;
		lastd2 <= lastd1;
		if ((c3==1) & (c4>1) & (c4<10)) begin
			adc1_data <= {lastd1[6:0],d[7:1]};
			adc1_gate[c4-2] <= 1;
		end
		if (c5z & (c3==3) & (c4==10)) begin
			adc2_data <= {lastd2[6:0],lastd1,d,1'b0};
			adc2_gate[c6] <= 1;
		end
	end
end

// FIFO to send to USB clock domain
// Ideas and code structure adapted from slow_snap2.v
reg trig1=0, trig2=0, fifo_arm=0, fifo_op=0, fifo_ok=0;
reg [127:0] shifter=0;  // intended to synthesize to 8 x SRL16E
always @(posedge clk) begin
	trig1 <= oaddr_sync;
	trig2 <= trig1;
	if (~trig1 & trig2) begin // falling edge
		fifo_arm <= 1;
		fifo_ok <= 0;
	end
	if (stream_tick) begin
		if (fifo_arm & (c4==1)) begin
			fifo_arm <= 0;
			fifo_op <= 1;
		end
		if (fifo_op & (c3[3:1]==0) & (c4>1) & (c4<10)) begin
			shifter <= {d,shifter[127:8]};
		end
		if (c4==10) begin
			fifo_op <= 0;
			fifo_ok <= 1;
		end
	end
end
wire [7:0] slow_data = shifter[{oaddr,3'b0}+:8];
assign fifo_out = fifo_ok ? slow_data : 8'h80;

endmodule
