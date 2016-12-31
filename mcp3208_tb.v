`timescale 1ns / 1ns
module mcp3208_tb;

reg clk, trigger;
wire [15:0] data;
reg [2:0] chan_in=0;
wire CS, CLK, DOUT, DIN;

mcp3208_rcvr mut(.clock(clk), .trigger(trigger), .chan_in(chan_in),
	.div_set(6'd41),
	.odata(data), .CS(CS), .CLK(CLK), .DOUT(DOUT), .DIN(DIN));

mcp3208_behav ic(CS, CLK, DOUT, DIN);

integer cc;
initial begin
	if ($test$plusargs("vcd")) begin
		$dumpfile("mcp3208.vcd");
		$dumpvars(5,mcp3208_tb);
	end
	clk=0;
	trigger=0;
	for (cc=0; cc<20000; cc=cc+1) begin
		#10; clk=1;
		#11; clk=0;
	end
end

always @(posedge clk) begin
	trigger <= (cc%600) == 20;
	if (trigger) chan_in <= chan_in+1;
	if (trigger) $display("%x", data);
end

endmodule
