// ds1822_driver.v
// Synthesizes to 52 slices and 1 block RAM at 169 MHz in XC3Sxxx-4 using XST-7.1i
// Synthesizes to 80 slices at 169 MHz in XC3Sxxx-4 using XST-8.2i

// Nominally should run all the time, but provide a run input so
// the software can disable it e.g., to check for noise generation.

// expected output result:
//    0- 4:  00 00 fd cc be
//    5-13:  scratchpad
//   14-19:  ff ff ff 00 fd 33
//   20-27:  serial number
//   28-30:  00 fd cc
// The above data will be available for 790 ms at a time via address
// and result pins.  The result will then read all zeros for the 21 ms
// that it takes to read in a new set of results.  It's important to
// read address zero first, and subsequent addresses at a rate of
// at least one per 655 us.  Other access patterns are not guaranteed
// to give self-consistent results.
//
// Each of the three 00 fd pairs in the above list will read 00 ff, if
// no 1-Wire chip is is on the bus.  No chip also yields all 00 for the
// scratchpad and serial number.  If the 1-Wire bus is shorted to
// ground, all bits, including the command words, will read ff.

`timescale 1ns / 1ns

module ds1822_driver(
	input clk,  // timespec 5.9 ns
	input rst,
	inout DS1,
	input run,
	input [4:0] address,
	output [7:0] result
);

// use 192 for simulation 7.9 ms, 19200 for real world 790 ms
parameter cnv_cnt=19200;
// use 7 for simulation with a 3 MHz clock
parameter tck_mask=511;

// Tune this divider to generate proper pulse widths.
// This version good for 50 MHz clk, see tck_mask comments above.
reg [7:0] divider=0;
reg tick=0;
always @(posedge clk or posedge rst) if (rst) begin
	divider <= 0;
	tick <= 0;
end else begin
	divider <= divider + 1'b1;
	tick <= ((divider&tck_mask) == 0);
end

// handle the 1-Wire pin as output
reg drive=0;
assign DS1 = drive ? 1'b0 : 1'bz ;

// handle the 1-Wire pin as input
reg owpd1=0;
always @(posedge clk) if (tick) begin
	owpd1 <= DS1;
end

// ROM with commands
`define RST 1
`define SIT 2
`define RDR 3
`define SKP 4
`define RDS 5
`define CVT 6
`define DLY 7
`define ZZZ 0
reg [2:0] command=0;  // really combinatorial
wire [4:0] command_address;
always @(command_address) case (command_address)
   0: command=`RST;
   1: command=`SIT;
   2: command=`SKP;  // cc
   3: command=`RDS;  // be
  16: command=`RST;
  17: command=`SIT;
  18: command=`RDR;  // 33
  27: command=`RST;
  28: command=`SIT;
  29: command=`SKP;  // cc
  30: command=`CVT;  // 44
  31: command=`DLY;
  default: command=`ZZZ;
endcase

reg [7:0] cmd_byte; // really combinatorial
always @(command) case(command)
  `RST: cmd_byte=8'h00;  // cmd_byte not used
  `SIT: cmd_byte=8'h00;  // cmd_byte not used
  `RDR: cmd_byte=8'h33;  // Read ROM
  `SKP: cmd_byte=8'hcc;  // Skip ROM
  `RDS: cmd_byte=8'hbe;  // Read scratchpad
  `CVT: cmd_byte=8'h44;  // Convert temperature
  `DLY: cmd_byte=8'h00;  // cmd_byte not used
  `ZZZ: cmd_byte=8'hff;  // what to send when reading
  default:  cmd_byte=8'h00;
endcase

// state machine that runs this mess
// one tick is   5.12 us
// one bit  is  81.92 us
// one byte is 655.36 us
reg [14:0] count=0;      // phases within a bit
reg [7:0] bit_count=0;  // counts both bits within byte, and bytes in transaction
reg [7:0] shifter=0;
reg shift_in=0, send_reset=0, send_sit=0, send_delay=0;
wire zero_count    = (count == 4'd0);
wire indata_count  = (count == 4'd3);
reg end_of_count=0;
wire byte_mark     = (bit_count[2:0] == 3'd7);
wire reset_low     = send_reset & run;
wire reset_high    = send_sit & run;
assign command_address = bit_count[7:3];

always @(posedge clk or posedge rst) if (rst) begin
	count <= 0;
	bit_count <= 0;
	end_of_count <= 0;
	send_reset <= 0;
	send_sit   <= 0;
	send_delay <= 0;
end else begin
	if (tick) begin
		count <= (~run | end_of_count) ? 0 : (count + 15'd1);
		end_of_count <= send_delay ? (count==cnv_cnt) : (count==14);
	end
	if (tick & end_of_count) begin
		bit_count <= bit_count + 8'd1;
	end
	if (tick & end_of_count & byte_mark) begin
		send_reset <= command==`RST;
		send_sit   <= command==`SIT;
		send_delay <= command==`DLY;
	end
end

// data path
wire [7:0] next_shifter  = {shift_in,shifter[7:1]};
wire       shift_out     = shifter[0];
always @(posedge clk or posedge rst) if (rst) begin
	drive <= 0;
	shift_in <= 0;
	shifter <= 0;
end else begin
	if (tick) drive <= run & ~send_delay & ~reset_high & (reset_low |
		~end_of_count & (zero_count | ~shift_out));
	if (tick & indata_count) shift_in <= owpd1;
	if (tick & end_of_count) begin
		shifter   <= byte_mark ? cmd_byte : next_shifter;
	end
end

// RAM holds results
reg [7:0] mem [31:0];
wire [4:0] write_addr = bit_count[7:3];
reg [7:0] ram_out;
always @(posedge clk) begin
	if (tick & end_of_count & byte_mark) mem[write_addr] <= next_shifter;
	ram_out <= mem[address];
end

reg consistent=0;
always @(posedge clk or posedge rst) if (rst) begin
	consistent <= 0;
end else begin
	if (address == 0) consistent <= (command_address == 0);
end
assign result = consistent ? ram_out : 8'b0;

endmodule
