`timescale 1ns / 1ns
module ad95xx_tb();

wire chip_sclk, chip_sdio, chip_csb;
reg clk, write_strobe;
reg [23:0] send_data;

ad95xx_driver mut(
	.clk(clk),
	.send_data(send_data),
	.write_strobe(write_strobe),
	.chip_sclk(chip_sclk), .chip_sdio(chip_sdio), .chip_csb(chip_csb)
);

integer cc;
initial begin
	if ($test$plusargs("vcd")) begin
		$dumpfile("ad95xx.vcd");
		$dumpvars(5,ad95xx_tb);
	end
	clk=0;
	for (cc=0; cc<200; cc=cc+1) begin
		#10; clk=1;
		#10; clk=0;
	end
end

wire [23:0] pattern=24'h123456;
initial begin
	write_strobe = 0;
	send_data = pattern;
end

always @(posedge clk) write_strobe <= (cc==10);

// Super-simple chip simulation
reg [23:0] readout;
always @(posedge chip_sclk) if (~chip_csb) readout <= {readout[22:0],chip_sdio};
always @(posedge chip_csb) begin
	$display("readout %x", readout);
	if (readout == pattern) $display("PASS");
end

endmodule
