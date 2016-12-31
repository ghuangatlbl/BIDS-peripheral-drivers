`timescale 1ns / 1ns
module mcp3208_wrap(
	input clk,  // assume USB for now

	// Local Bus
	input [31:0] lb_data,
	input [6:0] lb_addr,
	input lb_write,  // single-cycle causes a write

	// LO OK LED support
	output lo_led,

	// host access, once cycle latency
	input [3:0] address,
	output [7:0] result,

	// four-wire interface to the chip itself
	// Note that adc_dout and adc_din get their names from the ADC's
	// perspective: this module drives adc_din and reads from adc_dout.
	output adc_cs,
	output adc_clk,
	input adc_dout,
	output adc_din
);

// Host-settable registers
`include "regmap_support.vh"
`REG_en_slowadc  // u 80[6:6] 1
`REG_mcp3208_divset // u 30[5:0] 42
`REG_mcp3208_trigset // u 30[27:16] 1920
`REG_mcp3208_lochan // u 31[2:0] 1
`REG_mcp3208_lothresh  // u 31[27:16] 1100

reg [2:0] chan_sel=0, chan_prev1=0, chan_prev2=0;
reg adc_trig=0, adc_trig1=0;
reg [11:0] trig_cnt=0;
// adc_trig min period is 38*(mcp3208_divset+1)
always @(posedge clk) begin
	if (en_slowadc) trig_cnt <= trig_cnt==0 ? mcp3208_trigset : trig_cnt-1'b1;
	adc_trig <= en_slowadc & (trig_cnt==0);
	adc_trig1 <= adc_trig;
	if (adc_trig) begin
		chan_sel <= chan_sel+1'b1;
		chan_prev1 <= chan_sel;
		chan_prev2 <= chan_prev1;
	end
end

wire [15:0] mcp_data;
mcp3208_rcvr sa(.clock(clk), .trigger(adc_trig), .chan_in(chan_sel),
	.odata(mcp_data),
	.div_set(mcp3208_divset),
	.CS(adc_cs), .CLK(adc_clk), .DOUT(adc_dout), .DIN(adc_din)
);

wire lo_hit = adc_trig1 & (chan_prev2==mcp3208_lochan);
wire lo_comp = mcp_data[11:0] > mcp3208_lothresh;
(* IOB = "FALSE" *) reg lo_led_r=0;
always @(posedge clk) if (lo_hit|~en_slowadc) lo_led_r <= lo_comp & en_slowadc;
assign lo_led = lo_led_r;

// hope this produces fabric, not BRAM
wire [15:0] result16;
dpram #(.aw(3), .dw(16)) mem(.clka(clk), .clkb(clk),
	.addra(chan_prev2), .dina(mcp_data), .wena(adc_trig1),
	.addrb(address[3:1]), .doutb(result16)
);

// Multiplex, and guarantee that the results stay self-consistent
// even in the face of writes to the dual-port RAM.
// Cheat: require that address step non-randomly (only access an
// odd address after the corresponding even address).
reg addr0a=0, addr0b=0;
reg [15:0] save16=0;
always @(posedge clk) begin
	addr0a <= address[0];
	addr0b <= addr0a;
	if (~addr0a & addr0b) save16 <= result16;
end
assign result = addr0b ? save16[7:0] : save16[15:8];  // msb-first, big-endian

endmodule
