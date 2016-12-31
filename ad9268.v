`timescale 1ns / 1ns

module ad9268 #
(
	parameter OUTPUT_MODE="CMOS_SDR",
	parameter ADC_DATA_WIDTH=16,
	parameter BIT_REVERSE=18'b0 //{dco,data[15:0],or}
)
(
	// input clocks
	input sync,
	input [35:0] ad9268_pins,
	input clk_fpga,

// input [15:0] da_pin,
// input ora,
// input [15:0] db_pin,
// input orb,
// input dcoa,
// input dcob,
	input spi_rw,
	input [8:0] spi_addr,
	input [7:0] spi_data,
	input spi_start,
	output spi_ack,
	output [7:0] spi_rdbk,

	inout sdio_dcs,    // pin 44
	output sclk_dfs,   // pin 45
	output csb,        // pin 46
	output oeb,        // pin 47
	output pdwn,       // pin 48

	output adc_clk,

// input lvds_cmos,

	output [ADC_DATA_WIDTH-1:0] data_a,
	output [ADC_DATA_WIDTH-1:0] data_b,

	input [8:0] addr,
	input [7:0] din,
	output [7:0] read_r
);

wire sclk, sdio;

//assign sdio_dcs=1'bz;
//assign sclk_dfs=1'b0;
//assign csb=1'b1;
assign pdwn=1'b0;
assign oeb=1'b0;
//assign sclk=sclk_dfs;
assign sdio=sdio_dcs; // pin 44
/*
  ORA_ORP,    // pin 43  35
  D15A_ORN,    // pin 42  34
  D14A_D15P,    // pin 41  33
  D13A_D15N,    // pin 40  32
  D12A_D14P,    // pin 39  31
  D11A_D14N,    // pin 38  30
  D10A_D13P,    // pin 36  29
  D9A_D13N,    // pin 35  28
  D8A_D12P,    // pin 34  27
  D7A_D12N,    // pin 33  26
  D6A_D11P,    // pin 32  25
  D5A_D11N,    // pin 31  24
  D4A_D10P,    // pin 30  23
  D3A_D10N,    // pin 29  22
  D2A_D9P,    // pin 27  21
  D1A_D9N,    // pin 26  20
  D0A_DCOP,    // pin 25  19
  DCOA_DCON,    // pin 24  18
  DCOB_D8P,    // pin 23  17
  ORB_D8N,    // pin 22  16
  D15B_D7P,    // pin 21  15
  D14B_D7N,    // pin 20  14
  D13B_D6P,    // pin 18  13
  D12B_D6N,    // pin 17  12
  D11B_D5P,    // pin 16  11
  D10B_D5N,    // pin 15  10
  D9B_D4P,    // pin 14  9
  D8B_D4N,    // pin 13  8
  D7B_D3P,    // pin 12  7
  D6B_D3N,    // pin 11  6
  D5B_D2P,    // pin 9  5
  D4B_D2N,    // pin 8  4
  D3B_D1P,    // pin 7  3
  D2B_D1N,    // pin 6  2
  D1B_D0P,    // pin 5  1
  D0B_D0N,    // pin 4  0
*/

wire [ADC_DATA_WIDTH:0] a_out;
wire [ADC_DATA_WIDTH:0] b_out;

assign data_a=a_out[ADC_DATA_WIDTH:1];
assign data_b=b_out[ADC_DATA_WIDTH:1];

generate
if (OUTPUT_MODE=="LVDS") begin
// LVDS mode

	//============================================================
	// data input pins
	//============================================================
	// 16 bit data with 1 bit over range bit
	wire [2*ADC_DATA_WIDTH+1:0] lvds_din_raw={ad9268_pins[33:20],ad9268_pins[17:0],ad9268_pins[35:34]};
	wire [ADC_DATA_WIDTH:0] lvds_din_p;
	wire [ADC_DATA_WIDTH:0] lvds_din_n;
	wire [ADC_DATA_WIDTH:0] lvds_din;
	wire [ADC_DATA_WIDTH:0] lvds_din_reversed;
	assign lvds_din_reversed=BIT_REVERSE[16:0]^lvds_din;
	genvar gev_i;
	for (gev_i=0;gev_i<=ADC_DATA_WIDTH;gev_i=gev_i+1) begin
		assign lvds_din_n[gev_i]=lvds_din_raw[2*gev_i+1];
		assign lvds_din_p[gev_i]=lvds_din_raw[2*gev_i];
	end
	IBUFDS ibufds[ADC_DATA_WIDTH:0](
		.O(lvds_din),
		.I(lvds_din_p),
		.IB(lvds_din_n)
	);
	// clk pins
	wire dco_p=ad9268_pins[18];
	wire dco_n=ad9268_pins[19];
	wire dco_need_reverse;
	wire dco;
	assign dco=BIT_REVERSE[17]^dco_need_reverse;
	IBUFGDS ibufgds(
		.O(dco_need_reverse),
		.I(dco_p),
		.IB(dco_n)
	);
	assign adc_clk=dco;
	// DDR data capture
	// data format:
	// a_out={da[15:0],ora}
	// b_out={db[15:0],orb}
	IDDR2 iddrs[ADC_DATA_WIDTH:0](
		// input
		.C0(dco),
		.C1(~dco),
		.CE(1'b1),
		.D(lvds_din_reversed),
		.R(1'b0),
		.S(1'b0),
		// Output
		.Q0(a_out),
		.Q1(b_out)
	);
end
else if (OUTPUT_MODE=="CMOS_SDR") begin
// CMOS mode
// a_out={da[15:0],ora}
	assign a_out={ad9268_pins[34:19],ad9268_pins[35]};
	assign b_out={ad9268_pins[15:0],ad9268_pins[16]};
	IBUFG ibufg(
		.I(ad9268_pins[18]), // DCOA
		.O(adc_clk)
	);
end
else if (OUTPUT_MODE=="CMOS_DDR") begin
	wire [ADC_DATA_WIDTH:0] din_raw={ad9268_pins[34:19],ad9268_pins[35]};
	IDDR2 iddr_cmos[ADC_DATA_WIDTH:0](
		// input
		.C0(adc_clk),
		.C1(~adc_clk),
		.CE(1'b1),
		.D(din_raw),
		.R(1'b0),
		.S(1'b0),
		// Output
		.Q0(a_out),
		.Q1(b_out)
	);
	IBUFG ibufg(
		.I(ad9268_pins[18]), // DCOA
		.O(adc_clk)
	);
end
else begin
	assign a_out={ADC_DATA_WIDTH+1{1'b0}};
	assign b_out={ADC_DATA_WIDTH+1{1'b0}};
	assign adc_clk=1'b0;
end
endgenerate

// spi_master wires
//reg spi_rw;
//reg [8:0] spi_addr;
//reg [7:0] spi_data;
//wire spi_start;
//wire spi_ack;
//wire csb, sclk, sdio;
//wire [7:0] spi_rdbk;

spi_ad9268 #(.tsckw(9)) spi_port(
    .clk(clk_fpga),.strobe(spi_start),.ce(1'b1),.rd(spi_rw),
    .ack(spi_ack),.addr(spi_addr),.din(spi_data),
    .csb(csb),.sclk(sclk_dfs),.sdio(sdio_dcs),
    .read_r(spi_rdbk)
//    .read_r(),.spi_state(spi_rdbk)
);



reg lsb_first=0;
reg soft_reset=0;
reg [7:0] chip_id=8'h32;
reg [1:0] speed_grade_id=0;
reg data_channel_b=1'b1;
reg data_channel_a=1'b1;
reg transfer=0;
reg ext_pow_down_fun=0;
reg [1:0] int_pow_down_fun=0;
reg duty_cycle_stab=1'b1;
reg [2:0]  clock_divide_ratio=3'b0;
reg reset_pn_long_gen=0;
reg reset_pn_short_gen=0;
reg [2:0] output_test_mode=0;
reg reset_bist_sequence=1'b1;
reg bist_enable=0;
reg common_mode_servo_enable=0;
reg [7:0] offset_adjust=8'b0;
reg drive_strength=0;
reg output_type=0;
reg cmos_output_interleave_enable=0;
reg output_enable_bar=0;
reg output_inverter=0;
reg [1:0] output_format=0;
reg invert_dco_clock=0;
reg [2:0] input_clock_divider_phase_adjust=3'b0;
reg [4:0] dco_clock_delay=0;
reg [1:0]  reference_voltage_selection=2'b11;
reg [7:0] bist_signature_lsb;
reg [7:0] bist_signature_msb;
reg dither_enable=0;
reg clock_divider_next_sync_only=0;
reg clock_divider_sync_enable=0;
reg master_sync_enable=0;
wire [7:0] reg_00_spi_port_cfg={1'b0,lsb_first,soft_reset,2'b11,soft_reset,lsb_first,1'b0};
wire [7:0] reg_01_chip_id_reg=chip_id;
wire [7:0] reg_02_chip_grade={2'b0,speed_grade_id,4'b0};
wire [7:0] reg_05_channel_index={6'b0,data_channel_b,data_channel_a};
wire [7:0] reg_ff_transfer_reg={7'b0,transfer};
wire [7:0] reg_08_power_mode={2'b10,ext_pow_down_fun,3'b100,int_pow_down_fun};
wire [7:0] reg_09_global_clock ={7'b0,duty_cycle_stab};
wire [7:0] reg_0b_clock_divide={5'b0,clock_divide_ratio};
wire [7:0] reg_0d_test_mode={2'b0,reset_pn_long_gen,reset_pn_short_gen,1'b0,output_test_mode};
wire [7:0] reg_0e_bist_enable_reg={5'b0,reset_bist_sequence,1'b0,bist_enable};
wire [7:0] reg_0f_adc_input={7'b0,common_mode_servo_enable};
wire [7:0] reg_10_offset_adjust=offset_adjust;
wire [7:0] reg_14_output_mode={drive_strength,output_type,output_enable_bar,1'b0,output_inverter,output_format};
wire [7:0] reg_14_clock_phase_control={invert_dco_clock,4'b0,input_clock_divider_phase_adjust};
wire [7:0] reg_16_dco_output_delay={3'b0,dco_clock_delay};
wire [7:0] reg_00_vref_slect={reference_voltage_selection,6'b0};
wire [7:0] reg_00_dither_enable_reg={3'b0,dither_enable,4'b0};
wire [7:0] reg_00_sync_control={5'b0,clock_divider_next_sync_only,clock_divider_sync_enable,master_sync_enable};

endmodule
