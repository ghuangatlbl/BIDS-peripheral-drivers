// FDCP.v
// pathetic model of a Xilinx FDCP primitive
// ignores GSR
`timescale 1ns / 1ns

(* ivl_synthesis_cell *)
module FDCP(
	output Q,
	input C,
	input CLR,
	input D,
	input PRE
);

parameter INIT = 1'b0;

reg r=INIT;
always @(posedge C) r <= (D | PRE) & ~CLR;
always @(CLR or PRE) if (CLR | PRE) r <= PRE & ~CLR;
assign Q=r;

endmodule
