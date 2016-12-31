`timescale 1ns / 1ps

module sp6_dco_gen (
    // LTC2175 interface
    input dco,

    // ISERDES2 interface
    output clkdiv_o,
    output clk_p_o,
    output clk_n_o,
    output ioce_o
);

parameter integer clk_divide = 4 ;
parameter divide_bypass = "FALSE";
parameter FPGA_FAMILY="SPARTAN6";
wire dco_bufio0;

//  BUFIO2 driving ISERDES2 DDR
// UG382 Figure 1-15/1-33
// UG381 Figure 3-3
/*IBUFGDS clk_buf_dco (
    .O(dco_bufds),
    .I(dco_p),
    .IB(dco_n)
);
*/

BUFIO2 #(
    .USE_DOUBLER("TRUE"),
    .I_INVERT("FALSE"),
    .DIVIDE(clk_divide),
    .DIVIDE_BYPASS(divide_bypass)
) dco_bufio2_0 (
    .I(dco),
  //  .IB(dco_n),
    .IOCLK(clk_p_o),
    //.IOCLK(clk_p_o_buf),
    .DIVCLK(dco_bufio0),
    .SERDESSTROBE(ioce_o)
);

BUFG dco_bufg_i (
    .I(dco_bufio0),
    .O(clkdiv_o)
);
/*BUFG dco_bufg_p_o (
    .I(clk_p_o_buf),
    .O(clk_p_o)
);
*/
BUFIO2 #(
    .USE_DOUBLER("FALSE"),
    .I_INVERT("TRUE")
) dco_bufio2_1 (
    .I(dco),
    //.IOCLK(clk_n_o_buf)
    .IOCLK(clk_n_o)
);
/*
BUFG dco_bufg_n_o (
    .I(clk_n_o_buf),
    .O(clk_n_o)
);*/
endmodule
