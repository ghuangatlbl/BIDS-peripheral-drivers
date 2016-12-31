// Synthesizes to 15 slices at 200 MHz in XC3Sxxx-4 using XST-8.2i
`timescale 1ns / 1ns
module max1820(
	// input clocks
	input dspclk,
	input usbclk,

	// output
	output sync,

	// control inputs
	input sync_enable,   // posedge usbclk domain
	input [2:0] div_ctl, // posedge dspclk domain
	input mux_ctl        // more-or-less asynchronous
);

// MAX1820Y sync range is 15 to 21 MHz, nominal 19.8 MHz

// start simple
reg sync_usb=0;
reg [1:0] usb_cnt=0;

always @(posedge usbclk) begin
	// hard-coded divide 48 MHz USB clock by 3 to get 16 MHz
	usb_cnt <= (usb_cnt==2) ? 0 : (usb_cnt + 1'b1);
	sync_usb <= usb_cnt==2'd2;
end

// Except for a gap at low frequencies from 42 to 45 MHz, divide ratios
// of 2 to 8 can in principle sync to any FPGA/ADC clock from 30 to 168 MHz.
reg [2:0] dsp_cnt=0;
reg sync_dsp;
always @(posedge dspclk) begin
	dsp_cnt <= (dsp_cnt==div_ctl) ? 0 : (dsp_cnt+1'b1);
	sync_dsp <= dsp_cnt > {1'b0,div_ctl[2:1]};
end

// asynchronous multiplexer on output
assign sync = sync_enable ? (mux_ctl ? sync_dsp : sync_usb) : 1'b0;

endmodule
