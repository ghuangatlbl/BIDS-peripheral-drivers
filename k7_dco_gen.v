`timescale 1ns / 1ps
module k7_dco_gen (
    input clk_reset,
    // LTC2175 interface
    input dco_p,
    input dco_n,

    // ISERDES2 interface
    output clkdiv,
    output clkdiv_g,
    output clk_p_o,
    output clk_n_o
);
parameter integer clk_divide = 4 ;
parameter divide_bypass = "FALSE";

wire clk_in_int, clk_in_int_buf, clk_buf, clk_inv, clk_div_int;

IBUFDS #(
    .DIFF_TERM(TRUE),
    .IOSTANDARD("LVDS_25")
) ibufgds_inst_clk (
    .I(dco_p),
    .IB(dco_n),
    .O(clk_in_int)
);

// High Speed BUFIO clock buffer
BUFIO bufio_inst_clk(
    .I(clk_in_int),
    .O(clk_in_int_buf)
);

// BUFR generates the slow clock
BUFR #(
    .BUFR_DIVIDE(clk_divide)
) bufr_inst_clk_div (
    .I(clk_in_int),
    .O(clk_div_int),
    .CE(1'b1),
    .CLR(clk_reset)
);

assign clk_p_o = clk_in_int_buf;
assign clk_n_o = ~ clk_in_int_buf;
assign clkdiv = clk_div_int;

BUFG _bufg (
  .I(clk_div_int),
  .O(clkdiv_g)
);

endmodule
