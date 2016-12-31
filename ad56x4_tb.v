`timescale 1ns / 1ns
module ad56x4_tb;

reg clk;
integer cc;
reg match1=0, match2=0;
initial begin
	if ($test$plusargs("vcd")) begin
		$dumpfile("ad56x4.vcd");
		$dumpvars(5,ad56x4_tb);
	end
	clk=0;
	for (cc=0; cc<400; cc=cc+1) begin
		#10; clk=1;
		#10; clk=0;
	end
	if (match1&match2) $display("PASS");
	else               $display("FAIL");
end

// pacing counter
reg [1:0] dac_clk_div=0;
always @(posedge clk) dac_clk_div=dac_clk_div+1;

reg strobe=0;
always @(posedge clk) strobe <= (cc%28)==0;

reg signed [15:0] voltage1=256;
reg signed [15:0] voltage2=32767;
reg signed [15:0] voltage3=0;
wire [2:0] dac_sel = 3'b000;  // DAC A only
wire dac_reconfig=0;

wire chip_sclk, chip_csb;
wire [2:0] chip_sdio;
ad56x4_driver4 mut(
	.clk(clk), .ref_sclk(dac_clk_div[1]), .sdac_trig(strobe),
	.reconfig(dac_reconfig), .internal_ref(1'b1),
	.addr1(dac_sel), .addr2(dac_sel), .addr3(dac_sel),
	.voltage1(voltage1), .voltage2(voltage2), .voltage3(voltage3),
	.load1(strobe), .load2(strobe), .load3(strobe),
	.sclk(chip_sclk), .sdio(chip_sdio), .csb(chip_csb)
);

// Super-simple chip simulation
reg [23:0] readout;
wire [23:0] pattern = {5'b00011, dac_sel, ~voltage1[15],voltage1[14:0]};
always @(negedge chip_sclk) if (~chip_csb) readout <= {readout[22:0],chip_sdio[0]};
always @(posedge chip_csb) begin
	$display("readout %x", readout);
	if (readout == 24'h380001) match1=1;
	if (readout == pattern   ) match2=1;
	readout=0;
end

endmodule
