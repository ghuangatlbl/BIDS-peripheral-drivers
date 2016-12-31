`timescale 1 ns / 1 ns
// support for
//   AD7794 24-bit 6-channel ADC
//   TLC3548 14-bit 8-channel ADC
//   XC9536XL CPLD (programmed according to bias_ctl.v)
// sharing SCK and SDI, but with individual CS and SDO.

// Pin assignments, refer to test22.ps (expansion board schematic)
// and LLRF4 board documentation.  J2 is on expansion board, J3 is
// on LLRF4 board.
// SDI sends a signal to devices from this FPGA

module sporta(
	input clk,       // timespec 8 ns
	output SCK,      // O1  J2-4   J3-17  L6N
	output SDI,      // O3  J2-6   J3-15  L5N
	output CS_7794,  // O2  J2-5   J3-16  L6P
	output CS_3548,  // O4  J2-7   J3-14  L5P
	output CS_BIAS,  // O5  J2-9   J3-12  L4N
	input SDO_7794,  // I2  J2-16  J3-5   L1N
	input SDO_3548,  // I3  J2-17  J3-4   L1P
	input SDO_BIAS,  // I1  J2-15  J3-6   L2P
	input [8:0] sconfig,  // expand as needed
	input [5:0] switch_sel,
	input switch_op,
	output [15:0] stream,
	output stream_tick
);

// The open-drain output of the 74LCX07 causes asymmetries in the
// output waveforms: slow rise, fast fall.  The rising-edge triggered
// AD7794 therefore needs its data to have a three-ish clock cycle
// hold time, in case it makes a high-to-low transition that could
// beat the rise time of the clock.

// AD7794:
//   SCLK up to 5 MHz
//   CS_7794 held high when not in use
//   SDI must be valid around SCK rising edge
//   SDO_7794 changes in response to SCK falling edge
//   possible transactions:
//      lower CS, send write to command register (0x08),
//            send 16 bits data to mode register, raise CS
//      lower CS, send write to command register (0x58),
//            read 24 data bits from data register, raise CS

// TLC3548:
//   SCLK up to 25 MHz
//   CS_3548 held high when not in use
//   SDI must be valid around SCK falling edge
//   SDO_3548 changes in response to SCK rising edge
//   possible transactions:
//      lower CS, send 4 bits of command, 12 bits to configuration register,
//            raise CS
//      lower CS, send 4 bits of command while reading data, 10 more clocks
//            to read data, 2 more clocks for don't care bits, 72 more clocks
//            to operate conversion, raise CS
//   See page 18 for the 4-bit command code; selects channel or write CFR
//      (needs to cycle through A, 0-7, to setup and read 8 analog channels)
//   4+12+72=88 clock cycle (short, up to 10 MHz) 11 us at 8 MHz
//   4+44+72=120 clock cycle (long, up to 25 MHz) 5 us at 24 MHz
//    120 ~ 128, or 16 bytes
//   suitable command register transaction: 0xa100, external clock

// Bias CPLD:
//   SCLK up to 200 MHz
//   CS_BIAS held low when not in use
//   SDI must be valid around SCK rising edge
//   SDO_BIAS changes in response to SCK rising edge
//   possible transaction:
//      send 6 on/off command bits, raise CS, clock once,
//            lower CS, clock 6 status bits back

// 5 MHz SCLK
// groups of 8, either send/receive data, or raise/lower CS lines
// instruction memory for send data, 2 x CS lines, clock enable,
// and indirect modifiers for data (e.g., use channel counter).

reg [1:0] c6=0;  //  0 to 2, choosing slow ADC channel
reg [1:0] c5=0;  //  0 to 3, choosing slow ADC sequence
reg [3:0] c4=0;  //  0 to 10, choosing fast ADC channel, setup
reg [3:0] c3=0;  //  0 to 11, counting bytes within 88 bit fast ADC cycle
reg [2:0] c2=0;  //  0 to 7, bits within the byte
reg [0:0] c1=0;  //  SCK high or low
reg [3:0] c0=0;  //  0 to 5 or 11, high/low SCK time for 3548 or 7794 (87.5 MHz clock)
wire [7:0] stream_state = {c6,c5==3,c4,c3==0};

reg carry0=0, carry2=0, carry3=0, carry4=0, carry5=0;
wire carry1 = c1;
reg ready_7794=0;
always @(posedge clk) begin
	carry0 <= (c4==10) ? (c0==10) : (c0==4);
	c0 <= carry0 ? 0 : (c0+1);
	if (carry0) begin
		c1 <= ~c1;
	end
	if (carry0 & carry1) begin
		carry2 <= c2==6;
		c2 <= c2+1;
	end
	if (carry0 & carry1 & carry2) begin
		carry3 <= (c4==10) ? (c3==3) : (c3==10);
		c3 <= carry3 ? 0 : (c3+1);
	end
	if (carry0 & carry1 & carry2 & carry3) begin
		carry4 <= c4==9;
		c4 <= carry4 ? 0 : (c4+1);
	end
	if (carry0 & carry1 & carry2 & carry3 & carry4) begin
		carry5 <= c5==3;
		c5 <= c5 + (c5!=2 | ready_7794);
	end
	if (carry0 & carry1 & carry2 & carry3 & carry4 & carry5) begin
		c6 <= c6+1;
	end
end

// Bias CPLD programming
// XXX still needs to read out the state
reg [5:0] switch_pend=0;
wire switch_load = carry0 & carry1 & carry2 & (c3==10);
always @(posedge clk) begin
	if (switch_op | switch_load) switch_pend <= switch_op ? switch_sel : 8'b0;
end
wire [7:0] txd_bias = {sconfig[8:7],switch_pend};

reg [7:0] txd1;  // AD7794 programming
wire [3:0] filt_7794 = sconfig[3:0]; // See table 19
wire [2:0] gain_7794 = sconfig[6:4]; // See table 20
wire [3:0] chan_7794 = (c6==3) ? 4'h6 : {2'b0,c6};  // AIN1, AIN2, AIN3, Temperature
always @(posedge clk) case ({c5,c3[1:0]})
	4'h0: txd1 <= 8'h08;  // Write to mode register
	4'h1: txd1 <= 8'h20;  // Single Conversion, PSW off, AMP-CM off
	4'h2: txd1 <= {4'h0,filt_7794};  // Int. 64 kHz clock, chop enable
	4'h3: txd1 <= 8'h00;

	4'h4: txd1 <= 8'h10;  // Write to configuration register
	4'h5: txd1 <= {5'h0,gain_7794}; // No bias, config sets gain
	4'h6: txd1 <= {4'h0,chan_7794}; // REFIN1, enable ref_det, c6 sets input channel
	4'h7: txd1 <= 8'h00;

	4'h8: txd1 <= 8'h40;  // Read from status register
	4'h9: txd1 <= 8'h00;  // pad  (high order bit is #RDY)
	4'ha: txd1 <= 8'h00;
	4'hb: txd1 <= 8'h00;

	4'hc: txd1 <= 8'h58;  // Read from data register
	4'hd: txd1 <= 8'h00;
	4'he: txd1 <= 8'h00;
	4'hf: txd1 <= 8'h00;
endcase

reg [7:0] txd0=0;  // TLC3548 programming
always @(posedge clk) case(c4)
	4'h0: txd0 <= 8'ha3;
	4'h1: txd0 <= 8'h00;
	4'h2: txd0 <= 8'h10;
	4'h3: txd0 <= 8'h20;
	4'h4: txd0 <= 8'h30;
	4'h5: txd0 <= 8'h40;
	4'h6: txd0 <= 8'h50;
	4'h7: txd0 <= 8'h60;
	4'h8: txd0 <= 8'h70;
	4'h9: txd0 <= 8'hb0;  // test (ignore)
	4'ha: txd0 <= txd1;
endcase
wire [7:0] txd = ((c3==0) | (c4==10)) ? txd0 : switch_load ? txd_bias : 8'h00;

reg sck_r=0, sel_3548=0, sel_7794=0, sel_bias=0;
reg in_from_bias=0, in_from_3548=0, in_from_7794=0;
wire rxd = sel_3548 ? in_from_3548 : sel_7794 ? in_from_7794 : 1'b1 ;
reg [7:0] sr=0;
reg sr_out1=0, sr_out2=0, sr_out3=0, sr_out4=0;
wire [7:0] sr_next = {sr[6:0],rxd};
always @(posedge clk) begin
	if (carry0 & ~carry1) in_from_3548 <= SDO_3548;  // Latch in IOB
	if (carry0 &  carry1) in_from_7794 <= SDO_7794;  // Latch in IOB
	sck_r <= (c1 & (c3 != 0))^((c4==10)|({c4,c3,c2[2]}==0));
	sel_3548 <= (c4!=10) & (c3!=0);
	sel_7794 <= ((c4==10) & (c3!=0)) | ({c4,c3,c2[2:1]}==0);
	sel_bias <= (c4!=10) & (c3==0) & (c2[2:1]==0);
	if (carry0 & carry1) sr <= carry2 ? txd : sr_next;
	if (carry0 & carry1 & c2==0 & c3==2 & c4==10) ready_7794 <= ~in_from_7794;
	sr_out1 <= sr[7];
	sr_out2 <= sr_out1;
	// AD7794 has two cycles (~42 ns) extra hold time for reasons discussed above
	sr_out3 <= sel_7794 ? sr_out2 : sr[7];
	sr_out4 <= sr_out3;
end

assign SCK = sck_r;
assign SDI = sr_out4;
assign CS_BIAS =  sel_bias;  // ignore for now
assign CS_3548 = ~sel_3548;
assign CS_7794 = ~sel_7794;
reg [15:0] stream_r=0;
reg stream_tick_r=0;
always @(posedge clk) begin
	if (carry0 & carry1 & carry2) stream_r <= {stream_state,sr_next};
	stream_tick_r <= carry0 & carry1 & carry2;
end
assign stream = stream_r;
assign stream_tick = stream_tick_r;
// That will give ~2 MByte/sec, can ignore garbage later

// stream output should give a block 16 bytes (identifiable),
//   byte spacing within the block is about 1/ few microseconds,
//   part of the larger repeat cycle of 256 bytes
// should be good enough to give a cycle ID along with the 38-bit sr
//  once every millisecond?
// Actual lcls configuration as of 2009-05-11:
//  cic_sample rate set to freq_dsp/(4*COHERENT_DEN) in lcls_rf.v
//    output rate is half of that, because of the half-band filter.
//    COHERENT_DEN is 50 for SLAC production, so the block rate is
//    87.5/50/4/2 = 0.21875 MHz (400 DSP clock cycles)
//    that's for 12 x 20-bit numbers, plus 8-bit aux and its 8-bit address
//  To stay clean, want to get this block tick directly from the DSP
//   clock domain, don't route through USB.  Problem is that the routing
//   is through wave_mem, which can be a deep FIFO.

endmodule
