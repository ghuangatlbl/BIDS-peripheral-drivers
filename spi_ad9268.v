`timescale 1ns / 1ns

module spi_ad9268 #(
	parameter tsckw=5
)
(
	// Local bus interface
	input       clk,    // local clock
	input       strobe, // bus strobe
	input       ce,     // clock enable / module select
	input       rd,     // read/write
	output reg  ack,    // ack from the module
	input [8:0] addr,   // 9 bit register address
	input [7:0] din,    // from the bus
	output reg [7:0] read_r,

	// control lines
	(* IOB = "FALSE" *)
	output reg sclk, // serial clock
	(* IOB = "FALSE" *)
	inout  sdio, // serial data
	(* IOB = "FALSE" *)
	output reg csb, // load
	output [7:0] spi_state
);
// Registers
reg [23:0] sft_reg;
reg [tsckw-1:0] tckcnt=0;
parameter IDLE = 6'h3f; parameter START = 6'h00;
parameter END_SPI = 6'h30;
parameter END = 6'h31;
reg [5:0] state = IDLE;
reg sdo_r;

//assign spi_state={{(8-tsckw){1'b0}},tckcnt};

initial begin
	ack <= 1'b0;
	sclk <= 1'b0;
	sdo_r <= 1'b0;
	csb <= 1'b1;
	tckcnt<=0;
end


// sclk is two times slower than clk, should be <25 MHz
reg rwb;
wire clk_div=tckcnt[tsckw-1];
always @(posedge clk) begin
	tckcnt<=tckcnt+1;
end
wire strobe_div;
flag_xdomain flag_xdomain(.clk1(clk),.flagin_clk1(strobe),.clk2(clk_div),.flagout_clk2(strobe_div));

always @(posedge clk_div) begin
	if ( strobe_div & ce & ~ack & (state == IDLE) & csb) begin
		rwb <= rd;
		// R/W, W[1:0], A[12:7], A[6:0], D[7:0]
		//sft_reg <= {rd, 2'b0, 6'b0, addr, 8'b0};
		sft_reg <= {rd, 2'b0, 4'b0, addr, din[7:0]};
		state <= START;
		csb   <= 1'b0;
	end
	if (ack) begin
		ack <= 1'b0;
	end
	//if ((state != IDLE)&&(&tckcnt)) begin
	if ((state != IDLE)) begin
		if (state == END_SPI) begin
			state <= state + 6'b1;
			sclk <= 1'b0;
			csb <= 1'b1;
		end
		else if(state == END) begin
			state <= IDLE;
			ack <=1'b1;
		end
		else begin
			state <= state + 6'b1;
			if (~state[0]) begin
				sdo_r <= sft_reg[23];
				sft_reg <= {sft_reg[22:0], 1'b0};
				sclk <= 1'b0;
			end
			else begin
				sclk <= 1'b1;
				if (rwb & state[5]) begin
					read_r <= {read_r[6:0],sdio};
				end
			end
		end
	end
end
// output assignment
assign sdio = ((~csb) & rwb & state[5]) ? 1'bz : sdo_r;
endmodule
