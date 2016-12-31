// Bias control for LCLS LLRF expansion board
// Larry Doolittle, LBNL
// I/O signal names match page 5 of board schematic
// Target: XC9536XL
`timescale 1ns / 1ns
module bias_ctl(
	input SCK,  // timespec 10.0 ns
	input SDI,
	input STR,

	input Trip1, input ON1, input OFF1, output Enable1,
	input Trip2, input ON2, input OFF2, output Enable2,
	input Trip3, input ON3, input OFF3, output Enable3,

	output SDO
);

reg [11:0] shiftd=0;
wire ff1, ff2, ff3;
always @(posedge SCK) shiftd <= STR ? {Trip3,ff3,Trip2,ff2,Trip1,ff1,6'b0} : {shiftd[10:0],SDI};

wire set1 = ON1 | (shiftd[0]&STR);  wire clr1 = Trip1 | OFF1 | (shiftd[1]&STR);
wire set2 = ON2 | (shiftd[2]&STR);  wire clr2 = Trip2 | OFF2 | (shiftd[3]&STR);
wire set3 = ON3 | (shiftd[4]&STR);  wire clr3 = Trip3 | OFF3 | (shiftd[5]&STR);

// Inferred flip-flop version; Xilinx tools are happier with XC primitive
//always @(*) ff1 = (ff1 | set1) & ~clr1;
//always @(*) ff2 = (ff2 | set2) & ~clr2;
//always @(*) ff3 = (ff3 | set3) & ~clr3;

FDCP u1(.C(1'b0), .D(1'b0), .PRE(set1), .CLR(clr1), .Q(ff1));
FDCP u2(.C(1'b0), .D(1'b0), .PRE(set2), .CLR(clr2), .Q(ff2));
FDCP u3(.C(1'b0), .D(1'b0), .PRE(set3), .CLR(clr3), .Q(ff3));

assign Enable1 = ff1;
assign Enable2 = ff2;
assign Enable3 = ff3;
assign SDO = shiftd[11];

endmodule
