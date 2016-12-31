// In this module, use frame as bitslip pattern always has some problem. So
// decide to use ltc2174_ugrade, use teset pattern of adc data as bitslip
// pattern
module ltc2174(
	input frame_p_t,
	input frame_n_t,
	input frame_p_b,
	input frame_n_b,
	input dco_p_t,
	input dco_n_t,
	input dco_p_b,
	input dco_n_b,
	input [3:0] adca_p,
	input [3:0] adca_n,
	input [3:0] adcb_p,
	input [3:0] adcb_n,
	output [15:0] adc1,
	output [15:0] adc2,
	output [15:0] adc3,
	output [15:0] adc4,
	output [15:0] frame_out_t,
	output [15:0] frame_out_b,
	input [3:0] reva_flag,
	input [3:0] revb_flag,
	input rev_fr_flag,
	input [7:0] bitslip_ext,
	input [7:0] bitslip_val,

	input spi_start,
	input spi_read_only,
	output CS,
	output SCK,
	output SDI,
	inout SDO,
	input clk_fpga,

	input reset,
	input bitslip_start,
	input parser,
	input dscoff,
	input rand,
	input twoscomp,
	input [4:0] sleep,
	input [2:0] ilvds,
	input termon,
	input outoff,
	input [2:0] outmode,
	input outtest,
	input [13:0] testpattern,
	output reg dscoff_rdbk,
	output reg rand_rdbk,
	output reg twoscomp_rdbk,
	output reg [4:0] sleep_rdbk,
	output reg [2:0] ilvds_rdbk,
	output reg termon_rdbk,
	output reg outoff_rdbk,
	output reg [2:0] outmode_rdbk,
	output reg outtest_rdbk,
	output reg [13:0] testpattern_rdbk,
	output adc_clk,
	output bitslip_err,
	output bitslip_cmp
);
reg cs_r=0,cs_r_d=0;
parameter tsckw=5; //tsck is 2^5 time ts
reg [tsckw-1:0] tckcnt=0;
reg sck_r=0;
reg [6:0] sdi_addr=0;
wire spi_stop=(sdi_addr >4);
reg [4:0] sck_cnt=0;
reg sck_r_d=0;
reg spi_access=0;
reg finish_addr=0,finish_addr_d=0;
wire [tsckw-1:0] halftckcnt={1'b1,{{tsckw-2{1'b0}}}};
reg spi_read_r=0;
//wire [15:0] frame_out;
//wire bitslip_t=bitslip_ext[1]?bitslip_val[1]:bitslip_in;
//wire bitslip_b=bitslip_ext[0]?bitslip_val[0]:bitslip_in;
wire [15:0] adc_out[3:0];
wire ioce;

wire clk_p_br;
wire clk_n_br;
wire ioce_br;
wire clk_p_bl;
wire clk_n_bl;
wire ioce_bl;
wire clk_p_tr;
wire clk_n_tr;
wire ioce_tr;
wire clk_p_tl;
wire clk_n_tl;
wire ioce_tl;
wire clkdiv_tr;
wire clkdiv_tl;
wire clkdiv_br;
wire clkdiv_bl;

wire dco_t;
wire dco_b;

IBUFGDS clk_buf_dco (
	.O(dco_t),
	.I(dco_p_t),
	.IB(dco_n_t)
);
IBUFGDS clk_buf_dco_1 (
	.O(dco_b),
	.I(dco_p_b),
	.IB(dco_n_b)
);

//br bl tr tl standfor the bufio clocking regions
sp6_dco_gen #(.clk_divide(8),.divide_bypass("FALSE")) dco_gen_i_br ( .dco(dco_b), .clkdiv_o(clkdiv_br), .clk_p_o(clk_p_br), .clk_n_o(clk_n_br), .ioce_o(ioce_br));
sp6_dco_gen #(.clk_divide(8),.divide_bypass("FALSE")) dco_gen_i_bl ( .dco(dco_b), .clkdiv_o(clkdiv_bl), .clk_p_o(clk_p_bl), .clk_n_o(clk_n_bl), .ioce_o(ioce_bl));

sp6_dco_gen #(.clk_divide(8),.divide_bypass("FALSE")) dco_gen_i_tr ( .dco(dco_t), .clkdiv_o(clkdiv_tr), .clk_p_o(clk_p_tr), .clk_n_o(clk_n_tr), .ioce_o(ioce_tr));
sp6_dco_gen #(.clk_divide(8),.divide_bypass("FALSE")) dco_gen_i_tl ( .dco(dco_t), .clkdiv_o(clkdiv_tl), .clk_p_o(clk_p_tl), .clk_n_o(clk_n_tl), .ioce_o(ioce_tl));

//sp6_dco_gen #(.clk_divide(8),.divide_bypass("FALSE")) dco_gen_i_a ( .dco_p(dco_p_a), .dco_n(dco_n_a));
/*
.clk_p_o_b(clk_p_1),.clk_n_o_b(clk_n_1),.ioce_o_b(ioce_1),
	.clk_p_o_c(clk_p_2),.clk_n_o_c(clk_n_2),.ioce_o_c(ioce_2),
	.clk_p_o_d(clk_p_3),.clk_n_o_d(clk_n_3),.ioce_o_d(ioce_3),
	.clk_p_o_e(clk_p_4),.clk_n_o_e(clk_n_4),.ioce_o_e(ioce_4),
	.clk_p_o_f(clk_p_5),.clk_n_o_f(clk_n_5),.ioce_o_f(ioce_5),
	.clk_p_o_g(clk_p_6),.clk_n_o_g(clk_n_6),.ioce_o_g(ioce_6),
	.clk_p_o_h(clk_p_7),.clk_n_o_h(clk_n_7),.ioce_o_h(ioce_7)
);
*/
/*
IBUFGDS clk_buf_dco   (.O(dco_gen1_dly), .I(dco_p),.IB(dco_n));
wire dco_rst = reset;//(~MPI2_RESET) | (~sysclk_dcm0_locked_i);
//IDELAY #(.IOBDELAY_TYPE("VARIABLE"),.IOBDELAY_VALUE(12)) IDELAY_inst_dco (.O(dco_gen2_dly), .C(CLKDIV), .CE(pscasel), .I(dco_gen1_dly), .INC(psincdec), .RST(dco_rst) );
BUFG BUFG_inst_dco (.O(dco_gen),.I(dco_gen1_dly));

reg [7:0] daddr=0;
reg den=0;
reg [15:0] di=0;
wire sram_clk,dwe;
wire den_0 = (~daddr[7]) & den;
wire den_1 = daddr[7] & den;
wire gtp_rst_i=reset;
wire O_clkdiv_cp,sram1_clk,CLKDIV_GEN,sram1_clkn,dco_locked_i;
wire [15:0] do_0;
dco_clk2_source dco_clk_source(.CLKIN1_IN(dco_gen),.DADDR_IN(daddr[4:0]), .DCLK_IN(sram_clk), .DEN_IN(den_0), .DI_IN(di), .DWE_IN(dwe),.DO_OUT(do_0), .DRDY_OUT(drdy_0), .RST_IN(gtp_rst_i), .CLKOUT0_OUT(clk_p), .CLKOUT1_OUT(clk_n), .CLKOUT2_OUT(clkdiv), .CLKOUT3_OUT(sram1_clk),.CLKOUT4_OUT(CLKDIV_GEN),.CLKOUT5_OUT(sram1_clkn),.LOCKED_OUT(dco_locked_i));
*/
assign adc_clk=clkdiv_tr;

// Bank configuration for test-ltc2174 pcb board
// FRAME_T  TR Bitslip Pattern input
// FRAME_B  BL  Bitslip Pattern input
//
// ADCA[0]  BR Bitslip Pattern input
// ADCB[0]  BL
//
// ADCA[1]  BR
// ADCB[1]  BL
//
// ADCA[2]  TR
// ADCB[2]  TL Bitslip Pattern input
//
// ADCA[3]  TL
// ADCB[3]  TR

// FRAME_T  TR Bitslip Pattern input
wire [15:0] pattern_input_tr=frame_out_t;
// ADCB[2]  TL Bitslip Pattern input
//wire [15:0] pattern_input_tl=frame_out_t;
wire [15:0] pattern_input_tl={
				adc_out[2][14], adc_out[2][14],
				adc_out[2][12], adc_out[2][12],
				adc_out[2][10], adc_out[2][10],
				adc_out[2][8], adc_out[2][8],
				adc_out[2][6], adc_out[2][6],
				adc_out[2][4], adc_out[2][4],
				adc_out[2][2], adc_out[2][2],
				adc_out[2][0], adc_out[2][0]};
// ADCA[0]  BR Bitslip Pattern input
//wire [15:0] pattern_input_br=frame_out_b;
wire [15:0] pattern_input_br={
				adc_out[0][15], adc_out[0][15],
				adc_out[0][13], adc_out[0][13],
				adc_out[0][11], adc_out[0][11],
				adc_out[0][9], adc_out[0][9],
				adc_out[0][7], adc_out[0][7],
				adc_out[0][5], adc_out[0][5],
				adc_out[0][3], adc_out[0][3],
				adc_out[0][1], adc_out[0][1]};
// FRAME_B  BL  Bitslip Pattern input
wire [15:0] pattern_input_bl=frame_out_b;

wire bitslip_tr;
wire bitslip_tl;
wire bitslip_br;
wire bitslip_bl;

wire bitslip_err_tr;
wire bitslip_err_tl;
wire bitslip_err_br;
wire bitslip_err_bl;
assign bitslip_err=bitslip_err_tr||bitslip_err_tl||bitslip_err_br||bitslip_err_bl;

wire bitslip_cmp_tr;
wire bitslip_cmp_tl;
wire bitslip_cmp_br;
wire bitslip_cmp_bl;
assign bitslip_cmp=bitslip_cmp_tr&&bitslip_cmp_tl&&bitslip_cmp_br&&bitslip_cmp_bl;

// For half bank TR using frame_out_t as pattern input
bitslip_gen bitslip_gen_tr (.fclk(clkdiv_tr),.rst(1'b1),.bsp_clr(reset),
	.bsp_start(bitslip_start),.data_in(pattern_input_tr),
	//.bsp_start(~reset),.data_in(pattern_input_tr),
	.bsp_gen(bitslip_tr),.bsp_err(bitslip_err_tr),.bsp_cmp(bitslip_cmp_tr));

// For half bank TL using frame_out_t as pattern input
bitslip_gen bitslip_gen_tl (.fclk(clkdiv_tl),.rst(1'b1),.bsp_clr(reset),
	.bsp_start(bitslip_start),.data_in(pattern_input_tl),
	//.bsp_start(~reset),.data_in(pattern_input_tl),
	.bsp_gen(bitslip_tl),.bsp_err(bitslip_err_tl),.bsp_cmp(bitslip_cmp_tl));

// For half bank BR using frame_out_t as pattern input
bitslip_gen bitslip_gen_br (.fclk(clkdiv_br),.rst(1'b1),.bsp_clr(reset),
	.bsp_start(bitslip_start),.data_in(pattern_input_br),
	//.bsp_start(~reset),.data_in(pattern_input_br),
	.bsp_gen(bitslip_br),.bsp_err(bitslip_err_br),.bsp_cmp(bitslip_cmp_br));

// For half bank BL using frame_out_t as pattern input
bitslip_gen bitslip_gen_bl (.fclk(clkdiv_bl),.rst(1'b1),.bsp_clr(reset),
	.bsp_start(bitslip_start),.data_in(pattern_input_bl),
	//.bsp_start(~reset),.data_in(pattern_input_bl),
	.bsp_gen(bitslip_bl),.bsp_err(bitslip_err_bl),.bsp_cmp(bitslip_cmp_bl));

//wire clk=clkdiv_tr;
wire clk=clk_fpga;
wire [3:0] adca,adcb;
/*genvar ix;
generate
for (ix=0; ix<4; ix=ix+1) begin: in_cell
	IBUFDS #(.DIFF_TERM("TRUE")) buf_adca(.I(adca_p[ix]), .IB(adca_n[ix]), .O(adca[ix]));
	IBUFDS #(.DIFF_TERM("TRUE")) buf_adcb(.I(adcb_p[ix]), .IB(adcb_n[ix]), .O(adcb[ix]));
	iserdes2_phy iserdes2_phy(.clk_p(clk_p),.clk_n(clk_n),.ioce(ioce),.clkdiv(clkdiv),. bitslip(bitslip),.da(adca[ix]),.db(adcb[ix]),.dout(adc_out[ix]),. reset(reset),.reva_flag(reva_flag[ix]),.revb_flag(revb_flag[ix]));
end
endgenerate
*/


IBUFDS #(.DIFF_TERM("TRUE")) buf_adca0(.I(adca_p[0]), .IB(adca_n[0]), .O(adca[0]));
IBUFDS #(.DIFF_TERM("TRUE")) buf_adcb0(.I(adcb_p[0]), .IB(adcb_n[0]), .O(adcb[0]));
iserdes2_phy iserdes2_phy0(
	.clk_p_1(clk_p_br),.clk_n_1(clk_n_br),.ioce_1(ioce_br),.clkdiv_1(clkdiv_br),.bitslip_1(bitslip_br),
	.clk_p_2(clk_p_bl),.clk_n_2(clk_n_bl),.ioce_2(ioce_bl),.clkdiv_2(clkdiv_bl),.bitslip_2(bitslip_bl),
	.da(adca[0]),.db(adcb[0]),.dout(adc_out[0]),
	.reset(reset),.reva_flag(reva_flag[0]),.revb_flag(revb_flag[0]));
IBUFDS #(.DIFF_TERM("TRUE")) buf_adca1(.I(adca_p[1]), .IB(adca_n[1]), .O(adca[1]));
IBUFDS #(.DIFF_TERM("TRUE")) buf_adcb1(.I(adcb_p[1]), .IB(adcb_n[1]), .O(adcb[1]));
iserdes2_phy iserdes2_phy1(
	.clk_p_1(clk_p_br),.clk_n_1(clk_n_br),.ioce_1(ioce_br),.clkdiv_1(clkdiv_br),.bitslip_1(bitslip_br),
	.clk_p_2(clk_p_bl),.clk_n_2(clk_n_bl),.ioce_2(ioce_bl),.clkdiv_2(clkdiv_bl),.bitslip_2(bitslip_bl),
	.da(adca[1]),.db(adcb[1]),.dout(adc_out[1]),
	.reset(reset),.reva_flag(reva_flag[1]),.revb_flag(revb_flag[1]));
IBUFDS #(.DIFF_TERM("TRUE")) buf_adca2(.I(adca_p[2]), .IB(adca_n[2]), .O(adca[2]));
IBUFDS #(.DIFF_TERM("TRUE")) buf_adcb2(.I(adcb_p[2]), .IB(adcb_n[2]), .O(adcb[2]));
iserdes2_phy iserdes2_phy2(
	.clk_p_1(clk_p_tr),.clk_n_1(clk_n_tr),.ioce_1(ioce_tr),.clkdiv_1(clkdiv_tr),.bitslip_1(bitslip_tr),
	.clk_p_2(clk_p_tl),.clk_n_2(clk_n_tl),.ioce_2(ioce_tl),.clkdiv_2(clkdiv_tl),.bitslip_2(bitslip_tl),
	.da(adca[2]),.db(adcb[2]),.dout(adc_out[2]),
	.reset(reset),.reva_flag(reva_flag[2]),.revb_flag(revb_flag[2]));
IBUFDS #(.DIFF_TERM("TRUE")) buf_adca3(.I(adca_p[3]), .IB(adca_n[3]), .O(adca[3]));
IBUFDS #(.DIFF_TERM("TRUE")) buf_adcb3(.I(adcb_p[3]), .IB(adcb_n[3]), .O(adcb[3]));
iserdes2_phy iserdes2_phy3(
	.clk_p_1(clk_p_tl),.clk_n_1(clk_n_tl),.ioce_1(ioce_tl),.clkdiv_1(clkdiv_tl),.bitslip_1(bitslip_tl),
	.clk_p_2(clk_p_tr),.clk_n_2(clk_n_tr),.ioce_2(ioce_tr),.clkdiv_2(clkdiv_tr),.bitslip_2(bitslip_tr),
	.da(adca[3]),.db(adcb[3]),.dout(adc_out[3]),
	.reset(reset),.reva_flag(reva_flag[3]),.revb_flag(revb_flag[3]));

//iserdes2_phy iserdes2_phy2(.clk_p(clk_p_2),.clk_n(clk_n_2),.clk_p2(clk_p_3),.clk_n2(clk_n_3),.ioce(ioce_2),.ioce2(ioce_3),.clkdiv(clkdiv),. bitslip(bitslip),.da(adca[1]),.db(adcb[1]),.dout(adc_out[1]),. reset(reset),.reva_flag(reva_flag[1]),.revb_flag(revb_flag[1]));
//iserdes2_phy iserdes2_phy3(.clk_p(clk_p_4),.clk_n(clk_n_4),.clk_p2(clk_p_5),.clk_n2(clk_n_5),.ioce(ioce_4),.ioce2(ioce_5),.clkdiv(clkdiv),. bitslip(bitslip),.da(adca[2]),.db(adcb[2]),.dout(adc_out[2]),. reset(reset),.reva_flag(reva_flag[2]),.revb_flag(revb_flag[2]));
//iserdes2_phy iserdes2_phy4(.clk_p(clk_p_6),.clk_n(clk_n_6),.clk_p2(clk_p_7),.clk_n2(clk_n_7),.ioce(ioce_6),.ioce2(ioce_7),.clkdiv(clkdiv),. bitslip(bitslip),.da(adca[3]),.db(adcb[3]),.dout(adc_out[3]),. reset(reset),.reva_flag(reva_flag[3]),.revb_flag(revb_flag[3]));
IBUFDS #(.DIFF_TERM("TRUE")) buf_frame_t(.I(frame_p_t), .IB(frame_n_t), .O(frame_t));
IBUFDS #(.DIFF_TERM("TRUE")) buf_frame_b(.I(frame_p_b), .IB(frame_n_b), .O(frame_b));
// FRAME_T  TR Bitslip Pattern input
// FRAME_B  BL Bitslip Pattern input
iserdes2_fr_phy iserdes2_fr_phy_t(.clk_p(clk_p_tr),.clk_n(clk_n_tr),.ioce(ioce_tr),.clkdiv(clkdiv_tr),. bitslip(bitslip_tr),.da(frame_t),.dout(frame_out_t),. reset(reset),.reva_flag(rev_fr_flag));
iserdes2_fr_phy iserdes2_fr_phy_b(.clk_p(clk_p_bl),.clk_n(clk_n_bl),.ioce(ioce_bl),.clkdiv(clkdiv_bl),. bitslip(bitslip_bl),.da(frame_b),.dout(frame_out_b),. reset(reset),.reva_flag(rev_fr_flag));
//iserdes2_phy iserdes2_frame(.clk_p(clk_p),.clk_n(clk_n),.ioce(ioce),.clkdiv(clkdiv),. bitslip(bitslip),.da(frame),.db(0),.dout(frame_out),. reset(reset),.reva_flag(rev_fr_flag),.revb_flag(rev_fr_flag));

assign adc1=adc_out[0][15:0];
assign adc2=adc_out[1][15:0];
assign adc3=adc_out[2][15:0];
assign adc4=adc_out[3][15:0];
reg cs_d=1;
reg [6:0] spi_addr=0;
reg [7:0] spi_data=0;
wire spi_ready;
reg spi_read_m=0,spi_start_m=0;
wire [7:0] spi_rdbk;
reg tmp_1_rdbk;
assign CS=parser?0:cs_ser;
assign SDI=parser?0:sdi_ser;
assign SDO=parser?1:1'bz;
assign SCK=parser?0:sck_ser;
assign sdo_ser = SDO;

reg spi_start_d=0;
//wire spi_start_rising_edge=1;//spi_start&(~spi_start_d);
wire spi_start_rising_edge=spi_start&(~spi_start_d);
wire spi_start_flag=spi_start_rising_edge&(~parser)&cs_ser;

always @(posedge clk) begin
	spi_start_d<=spi_start;
end


spi_master #(
	.tsckw(tsckw)) spi_master(.clk(clk),.spi_start(spi_start_m),.spi_read(spi_read_m),
	.spi_addr(spi_addr),.spi_data(spi_data),.cs(cs_ser),.sck(sck_ser),
	.sdi(sdi_ser),.sdo(sdo_ser),.spi_ready(spi_ready),.spi_rdbk(spi_rdbk));

wire cs=cs_ser;
wire cs_rising_edge = cs&~cs_d;
wire cs_falling_edge = ~cs & cs_d;
reg [tsckw-1:0] wait_cnt={tsckw{1'b0}};

always @(posedge clk) begin
	if (cs_rising_edge) begin
		wait_cnt<=1;
	end
	else begin
		if (wait_cnt!=0)
			wait_cnt<=wait_cnt+1;
	end
end
reg [7:0] spi_value=0;
always @(posedge clk) begin
	cs_d <= cs;
	//if (cs & (reset || spi_start_flag || spi_read_only)) begin
	if (cs & (reset || spi_start_flag)) begin
		spi_addr<=0;
		spi_read_m <= spi_read_only;
		spi_start_m <= 1;
	end else if (&wait_cnt) begin
		if (spi_addr==4) begin
			if (~spi_read_m) begin
				spi_read_m <= 1;
				spi_start_m <= 1;
				spi_addr <= 0;
			end else begin
				spi_read_m <= 0;
				spi_start_m <= 0;
				spi_addr <= 0;
			end
		end else begin
			spi_addr <= spi_addr +1;
			spi_start_m <= 1;
		end
	end else begin
		spi_start_m <= 0;
	end
end
always @(posedge clk) begin
	if (cs_falling_edge) begin
		case (spi_addr)
			7'd0: spi_data<=8'h00;
			7'd1: spi_data<={dscoff,rand,twoscomp,sleep};
			7'd2: spi_data<={ilvds,termon,outoff,outmode};
			7'd3: spi_data<={outtest,1'b0,testpattern[13:8]};
			7'd4: spi_data<={testpattern[7:0]};
			default: spi_value<=8'h80;
		endcase
	end
// if (cs_rising_edge & spi_read_m) begin
	if (spi_ready) begin
		case (spi_addr)
			7'd1: {dscoff_rdbk,rand_rdbk,twoscomp_rdbk,sleep_rdbk} <= spi_rdbk;
			7'd2: {ilvds_rdbk,termon_rdbk,outoff_rdbk,outmode_rdbk} <= spi_rdbk;
			7'd3: {outtest_rdbk,tmp_1_rdbk,testpattern_rdbk[13:8]} <= spi_rdbk;
			7'd4: {testpattern_rdbk[7:0]} <= spi_rdbk;
		endcase
	end

end

endmodule
