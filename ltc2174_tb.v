`timescale 1ns / 10ps

module ltc2174_tb;

reg clk;
integer cc, errors;
parameter ts=10; // clock 100MHz, 10ns period
real tclk_h=ts/2;
real tclk_l=ts/2;
initial begin
	if ($test$plusargs("vcd")) begin
		$dumpfile("ltc2174.vcd");
		$dumpvars(5,ltc2174_tb);
	end
	errors=0;
	for (cc=0; cc<10000; cc=cc+1) begin
		clk=0; #tclk_l;
		clk=1; #tclk_h;
	end
	//$display("%s",errors==0?"PASS":"FAIL");
	$finish();
end
reg spi_start=0,spi_read=0;
reg [2:0] outmode_set=0;
wire [2:0] outmode;
reg reset;
always @(posedge clk) begin
	if (cc>10) chip_sim.outmode <= outmode_set;// <= (cc>100)? 0:3'd6;
		if (cc==150) begin
			spi_start <= 1;
			spi_read <= 1;
                        reset <=1;
		end else if (cc==4134) begin
			spi_start <= 1;
			spi_read <= 0;
		end else begin
			spi_start <= 0;
			spi_read <= 0;
                        reset <=0;
		end
end
reg [3:0] reva_flag=4'b0,revb_flag=4'b0;
reg dscoff=0,rand=0,twoscomp=0,termon=0,outoff=0,outtest=0;
reg  [4:0] sleep=0;
reg [2:0] ilvds=0;
reg [13:0] testpattern=14'h2cc;

reg [13:0] ain1=0,ain2=0,ain3=0,ain4=0;
wire cs,sck,sdi,sdo,frame_p,frame_n,dco_p,dco_n;
reg parser=0;
wire [3:0] adca_p,adca_n;
wire [3:0] adcb_p,adcb_n;
wire [13:0] adc1,adc2,adc3,adc4;
always @(posedge clk) begin
	ain1 <= ain1 +13'd1;
	ain2 <= 14'h1;
	ain3 <= 14'h2;
	ain4 <= 14'h4;
end
ltc2174_sim #(.ts(ts)) chip_sim(.ain1(ain1),.ain2(ain2),.ain3(ain3),.ain4(ain4),.enc(clk),.cs(cs),.sck(sck),.sdi(sdi),.sdo(sdo),.frame_p(frame_p),.frame_n(frame_n),.dco_p(dco_p),.dco_n(dco_n),.adca_p(adca_p),.adca_n(adca_n),.adcb_p(adcb_p),.adcb_n(adcb_n),.outmode(outmode),.parser(parser));

ltc2174 #(.tsckw(2)) driver(
	.frame_p_t(frame_p),.frame_n_t(frame_n),.dco_p_t(dco_p),.dco_n_t(dco_n),
	.frame_p_b(frame_p),.frame_n_b(frame_n),.dco_p_b(dco_p),.dco_n_b(dco_n),
	.adca_p(adca_p),.adca_n(adca_n),.adcb_p(adcb_p),.adcb_n(adcb_n),.adc1(adc1),.adc2(adc2),.adc3(adc3),.adc4(adc4),.CS(cs),.SCK(sck),.SDI(sdi),.SDO(sdo),.parser(parser),.dscoff(dscoff),.rand(rand),.twoscomp(twoscomp),.sleep(sleep),.ilvds(ilvds),.termon(termon),.outoff(outoff),.outmode(outmode),.outtest(outtest),.testpattern(testpattern),.spi_start(spi_start),.spi_read_only(spi_read),.reset(reset),.reva_flag(reva_flag),.revb_flag(revb_flag));
/*
// test of iserdes:
wire clkdiv_dco, clk0_dco, clk1_dco, ioce_dco;

dco_gen #(
    .clk_divide(8),
    .divide_bypass("FALSE")
) dco_gen_i (
    .dco_p(dco_p),
    .dco_n(dco_n),
    .clkdiv_o(clkdiv_dco),
    .clk0_o(clk0_dco),
    .clk1_o(clk1_dco),
    .ioce_o(ioce_dco)
);



// FR + 4A + 4B
wire [8:0] isds_d_p = {adca_p[3:0], adcb_p[3:0],frame_p};
wire [8:0] isds_d_n = {adca_n[3:0], adcb_n[3:0],frame_n};
wire [8:0] isd_d;
wire [8:0] shift_wire;

wire [7:0] data [0:8];

wire [7:0] fr_out=data[0];
wire bitslip;
always @(posedge clkdiv_dco) begin
    //bitslip<=(fr_out!=8'h0f);
end

wire [15:0] dframe ={
                    data[0][7], data[0][7],
                    data[0][6], data[0][6],
                    data[0][5], data[0][5],
                    data[0][4], data[0][4],
                    data[0][3], data[0][3],
                    data[0][2], data[0][2],
                    data[0][1], data[0][1],
                    data[0][0], data[0][0]};
bitslip_gen bitslip_gen (.fclk(clkdiv_dco),.rst(1'b1),.bsp_clr(reset_bitslip),.bsp_start(~reset_bitslip),.data_in(dframe),.bsp_gen(bitslip));
genvar ix;
generate
    for (ix=0; ix<9; ix=ix+1) begin: isds
    IBUFDS bufgds_i(
        .I(isds_d_p[ix]),
        .IB(isds_d_n[ix]),
        .O(isd_d[ix])
    );

    // master
    ISERDES2 #(
        .DATA_RATE("DDR"),
        .DATA_WIDTH(8),
        .BITSLIP_ENABLE("TRUE"),
        .SERDES_MODE("MASTER"),
        .INTERFACE_TYPE("RETIMED")
    ) isd_m (
        .Q1(data[ix][3]),.Q2(data[ix][2]),.Q3(data[ix][1]),.Q4(data[ix][0]),
        .SHIFTOUT(shift_wire[ix]),
        .BITSLIP(bitslip),
        .CE0(1'b1),
        .CLK0(clk0_dco),.CLK1(clk1_dco),.CLKDIV(clkdiv_dco),.D(isd_d[ix]),.IOCE(ioce_dco),.RST(1'b0)
    );
    // slave
    ISERDES2 #(
        .DATA_RATE("DDR"),
        .DATA_WIDTH(8),
        .BITSLIP_ENABLE("TRUE"),
        .SERDES_MODE("SLAVE"),
        .INTERFACE_TYPE("RETIMED")
    ) isd_s (
        .Q1(data[ix][7]),.Q2(data[ix][6]),.Q3(data[ix][5]),.Q4(data[ix][4]),
        .SHIFTIN(shift_wire[ix]),
        .BITSLIP(bitslip),
        .CE0(1'b1),
        .CLK0(clk0_dco),.CLK1(clk1_dco),.CLKDIV(clkdiv_dco),.D(1'b0),.IOCE(ioce_dco),.RST(1'b0)
    );
    end
endgenerate

// parallel data out, 2-lane 14 bit des
// out_a: d13, d11 ... d1
// out_b: d12, d10 ... d0
// d13-d0: q4as, q4bs, q3as, q3bs, q2as, q2bs, q4am, q4bm, q3am, q3bm, q2am, q2bm, q1am, q1bm
wire [15:0] dout0 = {
	2'b0,
                     data[5][7], data[1][7],
                     data[5][6], data[1][6],
                     data[5][5], data[1][5],
                     data[5][4], data[1][4],
                     data[5][3], data[1][3],
                     data[5][2], data[1][2],
                     data[5][1], data[1][1]};
//                     data[5][0], data[1][0]};
wire [15:0] dout1 = {
	2'b0,
                     data[6][7], data[2][7],
                     data[6][6], data[2][6],
                     data[6][5], data[2][5],
                     data[6][4], data[2][4],
                     data[6][3], data[2][3],
                     data[6][2], data[2][2],
                     data[6][1], data[2][1]};
//                     data[6][0], data[2][0]};
wire [15:0] dout2 = {
	2'b0,
                     data[7][7], data[3][7],
                     data[7][6], data[3][6],
                     data[7][5], data[3][5],
                     data[7][4], data[3][4],
                     data[7][3], data[3][3],
                     data[7][2], data[3][2],
                     data[7][1], data[3][1]};
//                     data[7][0], data[3][0]};
wire [15:0] dout3 = {
	2'b0,
                     data[8][7], data[4][7],
                     data[8][6], data[4][6],
                     data[8][5], data[4][5],
                     data[8][4], data[4][4],
                     data[8][3], data[4][3],
                     data[8][2], data[4][2],
                     data[8][1], data[4][1]};
//                     data[8][0], data[4][0]};
*/
endmodule
