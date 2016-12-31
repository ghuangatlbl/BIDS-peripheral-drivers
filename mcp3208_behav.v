// Stupidest possible model of mcp3208.
// Doesn't even understand the start bit, it assumes
// that the first bit is the start bit.

`timescale 1 ns / 1 ns

module mcp3208_behav(
	input CS, input CLK, output DOUT, input DIN);

reg [4:0] count;
reg [12:0] shifter;
reg [4:0] conf;
reg [12:0] example [15:0];

initial begin
	// single-ended
	example[8] = 12'h111;
	example[9] = 12'h222;
	example[10] = 12'h123;
	example[11] = 12'h456;
	example[12] = 12'h678;
	example[13] = 12'h9ab;
	example[14] = 12'hcde;
	example[15] = 12'hfef;
end

always @(CS) begin
	count = 0;
	shifter = 13'bz;
end

always @(posedge CLK) if (~CS) begin
	if (count < 5) conf = {conf[3:0], DIN};
	count <= count+1;
end
always @(negedge CLK) if (~CS) begin
	shifter <= (count==6) ? example[conf[3:0]] : {shifter[12:0], 1'bz};
end

assign DOUT = CS ? 1'bz : shifter[12];

endmodule
