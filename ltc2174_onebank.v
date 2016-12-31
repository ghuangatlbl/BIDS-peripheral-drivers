module ltc2174_onebank(
	input frame_p,
	input frame_n,
	input dco_p,
	input dco_n,
	input [3:0] adca_p,
	input [3:0] adca_n,
	input [3:0] adcb_p,
	input [3:0] adcb_n,
	output [15:0] adc1,
	output [15:0] adc2,
	output [15:0] adc3,
	output [15:0] adc4,
	output [15:0] frame_out,
	input [3:0] reva_flag,
	input [3:0] revb_flag,
	input rev_fr_flag,

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
//spi regs and wires
assign adc_clk=clkdiv;
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

//iserdes2 clocks
wire clk_p;
wire clk_n;
wire clkdiv;
wire ioce;

wire dco;

assign adc_clk=clkdiv;

IBUFGDS clk_buf_dco (
	.O(dco),
	.I(dco_p),
	.IB(dco_n)
);

//br bl tr tl standfor the bufio clocking regions

sp6_dco_gen #(
	.clk_divide(8),.divide_bypass("FALSE")
) dco_gen_i (
   	.dco(dco), .clkdiv_o(clkdiv), .clk_p_o(clk_p), .clk_n_o(clk_n), .ioce_o(ioce)
);


// Bank configuration for test-ltc2174 pcb board
// FRAME_T  TR	Bitslip Pattern input
// FRAME_B  BL  Bitslip Pattern input
//
// ADCA[0]  BR	Bitslip Pattern input
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

// FRAME_T  TR	Bitslip Pattern input
wire [15:0] pattern_input=frame_out;
// ADCB[2]  TL Bitslip Pattern input
//wire [15:0] pattern_input_tl=frame_out_t;
// ADCA[0]  BR	Bitslip Pattern input
//wire [15:0] pattern_input_br=frame_out_b;
// FRAME_B  BL  Bitslip Pattern input

wire bitslip;



// For half bank TR using frame_out_t as pattern input
bitslip_gen bitslip_gen (
	.fclk(clkdiv_tr),.rst(1'b1),.bsp_clr(reset),
	.bsp_start(bitslip_start),.data_in(pattern_input),
	.bsp_gen(bitslip),.bsp_err(bitslip_err),.bsp_cmp(bitslip_cmp)
);

//wire clk=clkdiv_tr;
wire clk=clk_fpga;
wire [3:0] adca,adcb;
genvar ix;
generate
for (ix=0;ix<4;ix=ix+1) begin: iserdes
	IBUFDS #(.DIFF_TERM("TRUE")) buf_adca(.I(adca_p[ix]), .IB(adca_n[ix]), .O(adca[ix]));
	IBUFDS #(.DIFF_TERM("TRUE")) buf_adcb(.I(adcb_p[ix]), .IB(adcb_n[ix]), .O(adcb[ix]));
	wire [15:0] adc_out;

	iserdes2_phy iserdes2_phy(
		.clk_p_1(clk_p),.clk_n_1(clk_n),.ioce_1(ioce),.clkdiv_1(clkdiv),.bitslip_1(bitslip),
		.clk_p_2(clk_p),.clk_n_2(clk_n),.ioce_2(ioce),.clkdiv_2(clkdiv),.bitslip_2(bitslip),
		.da(adca[ix]),.db(adcb[ix]),.dout(adc_out),
		.reset(reset),.reva_flag(reva_flag[ix]),.revb_flag(revb_flag[ix])
	);
	case (ix)
		0: assign adc1=adc_out;
		1: assign adc2=adc_out;
		2: assign adc3=adc_out;
		3: assign adc4=adc_out;
		default: 
		begin 
			assign adc1=16'b0;
			assign adc2=16'b0;
			assign adc3=16'b0;
			assign adc4=16'b0;
		end
	endcase
end
endgenerate
wire frame;
IBUFDS #(.DIFF_TERM("TRUE")) buf_frame(.I(frame_p), .IB(frame_n), .O(frame));
iserdes2_fr_phy iserdes2_fr_phy(
	.clk_p(clk_p),.clk_n(clk_n),.ioce(ioce),.clkdiv(clkdiv),
	.bitslip(bitslip),.da(frame),.dout(frame_out),
	.reset(reset),.reva_flag(rev_fr_flag)
);

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
//	if (cs_rising_edge & spi_read_m) begin
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
