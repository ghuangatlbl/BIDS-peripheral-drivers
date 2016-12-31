`timescale 1ns / 1ps

module sp6_deser (
    // LTC2174 interface
    input dco_p,
    input dco_n,
    input fr_p,
    input fr_n,
    input [3:0] adca_p,
    input [3:0] adca_n,
    input [3:0] adcb_p,
    input [3:0] adcb_n,

    // bitslip
    input rst,
    // Parallel data out
    output [13:0] dout0,
    output [13:0] dout1,
    output [13:0] dout2,
    output [13:0] dout3
);

parameter integer clk_divide = 8;

wire clkdiv_dco, clk0_dco, clk1_dco, ioce_dco;

sp6_dco_gen #(
    .clk_divide(clk_divide),
    .divide_bypass("FALSE")
) dco_gen_i (
    .dco_p(dco_p),
    .dco_n(dco_n),
    .clkdiv_o(clkdiv_dco),
    .clk0_o(clk0_dco),
    .clk1_o(clk1_dco),
    .ioce_o(ioce_dco)
);

wire [7:0] data [0:8];
wire bitslip;

bitslip_gen #(
    .BSP_PATTERN(8'hf0)
) bitslip_gen (
    .fclk(clkdiv_dco),
    .rst(1'b1),
    .bsp_clr(rst),
    .bsp_start(~rst),
    .data_in(data[0]),
    .bsp_gen(bitslip)
);

// FR + 4A + 4B
wire [8:0] isds_d_p = {adca_p[3:0], adcb_p[3:0],fr_p};
wire [8:0] isds_d_n = {adca_n[3:0], adcb_n[3:0],fr_n};
wire [8:0] isd_d;
wire [8:0] shift_wire;
genvar ix;
generate
    for (ix=0; ix<9; ix=ix+1) begin: isds
    IBUFDS bufgds_i(
        .I(isds_d_p[ix]),
        .IB(isds_d_n[ix]),
        .O(isd_d[ix])
    );

    // Jin Yang 01/29/2015:
    //The work flow for the shift register in ISERDES2 is below:
    //        Master                |  wire shiftwrite    |           Slave
    //       D-->Q4-->Q3-->Q2-->Q1-------------------------->Q4-->Q3-->Q2-->Q1
    // So MSB for this 8 bit ISERDES2s is Slave(Q1) different from the definition on ug381 page 82.
    ISERDES2 #(
        .DATA_RATE("DDR"),
        .DATA_WIDTH(8),
        .BITSLIP_ENABLE("TRUE"),
        .SERDES_MODE("MASTER"),
        .INTERFACE_TYPE("RETIMED")
    ) isd_m (
        //.Q1(data[ix][4]),.Q2(data[ix][5]),.Q3(data[ix][6]),.Q4(data[ix][7]),
        .Q1(data[ix][3]),.Q2(data[ix][2]),.Q3(data[ix][1]),.Q4(data[ix][0]),
        .SHIFTOUT(shift_wire[ix]),
        .BITSLIP(bitslip),
        .CE0(1'b1),
        .CLK0(clk0_dco),.CLK1(clk1_dco),.CLKDIV(clkdiv_dco),.D(isd_d[ix]),.IOCE(ioce_dco),.RST(rst)
    );
    ISERDES2 #(
        .DATA_RATE("DDR"),
        .DATA_WIDTH(8),
        .BITSLIP_ENABLE("TRUE"),
        .SERDES_MODE("SLAVE"),
        .INTERFACE_TYPE("RETIMED")
    ) isd_s (
        //.Q1(data[ix][0]),.Q2(data[ix][1]),.Q3(data[ix][2]),.Q4(data[ix][3]),
        .Q1(data[ix][7]),.Q2(data[ix][6]),.Q3(data[ix][5]),.Q4(data[ix][4]),
        .SHIFTIN(shift_wire[ix]),
        .BITSLIP(bitslip),
        .CE0(1'b1),
        .CLK0(clk0_dco),.CLK1(clk1_dco),.CLKDIV(clkdiv_dco),.D(1'b0),.IOCE(ioce_dco),.RST(rst)
    );
    end
endgenerate

// parallel data out, 2-lane 14 bit des
// out_a: d13, d11 ... d1
// out_b: d12, d10 ... d0
// d13-d0: q4as, q4bs, q3as, q3bs, q2as, q2bs, q4am, q4bm, q3am, q3bm, q2am, q2bm, q1am, q1bm
wire [13:0] dout0 = {
                     data[5][7], data[1][7],
                     data[5][6], data[1][6],
                     data[5][5], data[1][5],
                     data[5][4], data[1][4],
                     data[5][3], data[1][3],
                     data[5][2], data[1][2],
                     data[5][1], data[1][1]};
wire [13:0] dout1 = {
                     data[6][7], data[2][7],
                     data[6][6], data[2][6],
                     data[6][5], data[2][5],
                     data[6][4], data[2][4],
                     data[6][3], data[2][3],
                     data[6][2], data[2][2],
                     data[6][1], data[2][1]};
wire [13:0] dout2 = {
                     data[7][7], data[3][7],
                     data[7][6], data[3][6],
                     data[7][5], data[3][5],
                     data[7][4], data[3][4],
                     data[7][3], data[3][3],
                     data[7][2], data[3][2],
                     data[7][1], data[3][1]};
wire [13:0] dout3 = {
                     data[8][7], data[4][7],
                     data[8][6], data[4][6],
                     data[8][5], data[4][5],
                     data[8][4], data[4][4],
                     data[8][3], data[4][3],
                     data[8][2], data[4][2],
                     data[8][1], data[4][1]};
endmodule

