`timescale 1ns / 1ns
module mcp3208_rcvr(
	input clock,  // timespec 6.5 ns
	input trigger,
	input [2:0] chan_in,
	output [15:0] odata,

	// configuration of clock divider, see below
	input [5:0] div_set,

	// four-wire interface to the chip itself
	// Note that DOUT and DIN get their names from the ADC's
	// perspective: this module drives DIN and reads from DOUT.
	output reg CS,
	output reg CLK,
	input DOUT,
	output reg DIN
);

reg [11:0] in_reg=0;
reg [2:0] channel=0;
reg [5:0] ucnt=0;
reg [5:0] state=0;
reg tick=0, run=0;

wire SGL = 1'b1;   // second configuration bit sent to MCP3208

// tick should come at 2 MHz or slower.
// suggest divide by 28 (div_cnt=27) for clocking with 48 MHz USB clock
// suggest divide by 42 (div_cnt=41) for clocking with ~70 MHz DSP clock
//  (will stay synchronous with upper levels of divider because trigger
//   is synchronous)
wire acq_complete = tick && (state==37);
wire trig_val = trigger & ~run;
reg [15:0] odata_r=0;
always @(posedge clock) begin
	if (trig_val | acq_complete) run <= ~acq_complete;
	tick <= run & (ucnt==1);
	if (run) ucnt <= tick ? div_set : ucnt-1'b1;
	if (tick | trig_val) state <= trig_val ? 0 : (state+1'b1);
	if ((tick & ~state[0]) | trig_val) in_reg <= run ? {in_reg[10:0], DOUT} :
		{1'b1, SGL, chan_in, 7'b0};
	if (trig_val) odata_r <= {1'b0, channel, in_reg};
	if (trig_val) channel <= chan_in;
	CLK <= state[0];
	CS <= ~run;
	if (~state[0]) DIN <= in_reg[11];
end
assign odata = odata_r;

endmodule
