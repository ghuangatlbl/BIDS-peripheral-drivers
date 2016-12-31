module lmk01801 #(parameter flip_clk=0)(inout CLKOUT3_INV,inout CLKOUT3,
output CLKUWIRE,inout DATAUWIRE,output LEUWIRE,
output clkout
,input clkuwire_in
,inout datauwire_inout
,input leuwire_in
);
parameter SPIMODE="passthrough";
generate
if (SPIMODE=="passthrough")begin
	assign CLKUWIRE=clkuwire_in;
	assign LEUWIRE=leuwire_in;
	via sdiovia(.a(datauwire_inout),.b(DATAUWIRE));
end
endgenerate

wire clk_n=CLKOUT3_INV;
wire clk_p=CLKOUT3;
wire clk_ibufgds,clk_bufio;

`ifndef SIMULATE
IBUFDS #(.DIFF_TERM("TRUE")) ibuf_clk(.I(flip_clk ? clk_n : clk_p), .IB(flip_clk? clk_p : clk_n), .O(clk_ibufgds));
BUFG bufg_i(.I(clk_ibufgds), .O(clkout));
`endif
endmodule

