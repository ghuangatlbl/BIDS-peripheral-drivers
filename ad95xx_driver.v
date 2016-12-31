// Synthesizes to 34 slices at 140 MHz in XC3Sxxx-4 using XST-8.2i

`timescale 1ns / 1ns

module ad95xx_driver(
	input clk,  // timespec 7.0 ns
	// control input (in the (posedge clk) domain)
	input [23:0] send_data,
	input write_strobe,

	// pins that connect to the AD95xx chip
	output reg chip_sclk,
	output reg chip_sdio,
	output reg chip_csb);

reg [6:0] divclk=0;
reg [23:0] divdata=0;
reg div_send=0, shift=0;
initial begin
	chip_sclk=0;
	chip_sdio=0;
	chip_csb=1;
end
always @(posedge clk) begin
	if (write_strobe | divclk == 96) div_send <= write_strobe;
	if (write_strobe | div_send) divclk <= write_strobe ? 0 : divclk+1'b1;
	shift <= div_send & divclk[1:0]==2'b11;
	if (write_strobe | shift) divdata <= write_strobe ? send_data :
		{divdata[22:0],1'b0};
	// register each pin, to make timing at the pins more predictable
	chip_sclk <= divclk[1];
	chip_sdio <= divdata[23];
	chip_csb  <= ~div_send;
end

endmodule
