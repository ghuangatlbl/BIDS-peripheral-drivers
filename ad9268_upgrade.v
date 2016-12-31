`timescale 1ns / 1ns

module ad9268_upgrade #
(
	parameter OUTPUT_MODE="CMOS_SDR",
	parameter BIT_REVERSE=18'b0, //{dco,data[15:0],or}
	parameter tsckw=5,
	parameter ADC_DATA_WIDTH=16
)
(
	// input clocks
	input [35:0] ad9268_pins,
	input clk_fpga,

	input spi_rw,
	//input [8:0] spi_addr,
	//input [7:0] spi_data,
	//output spi_ack,
	input spi_start,
	output [7:0] spi_rdbk,

	inout sdio_dcs, // pin 44
	output sclk_dfs, // pin 45
	output csb, // pin 46
	output oeb, // pin 47
	output pdwn, // pin 48

	output adc_clk,

// input lvds_cmos,

	output [ADC_DATA_WIDTH-1:0] data_a,
	output [ADC_DATA_WIDTH-1:0] data_b,

	output [7:0] read_r,

	// register setting
	input lsb_first,
	input soft_reset,
	input data_channel_b,
	input data_channel_a,
	input transfer,
	input ext_pow_down_fun,
	input [1:0] int_pow_down_fun,
	input duty_cycle_stab,
	input [2:0]  clock_divide_ratio,
	input reset_pn_long_gen,
	input reset_pn_short_gen,
	input [2:0] output_test_mode,
	input reset_bist_sequence,
	input bist_enable,
	input common_mode_servo_enable,
	input [7:0] offset_adjust,
	input drive_strength,
	input output_type,
	input cmos_output_interleave_enable,
	input output_enable_bar,
	input output_inverter,
	input [1:0] output_format,
	input invert_dco_clock,
	input [2:0] input_clock_divider_phase_adjust,
	input [4:0] dco_clock_delay,
	input [1:0]  reference_voltage_selection,
// input [7:0] bist_signature_lsb,
// input [7:0] bist_signature_msb,
	input dither_enable,
	input clock_divider_next_sync_only,
	input clock_divider_sync_enable,
	input master_sync_enable,


	output RB_lsb_first,
	output RB_soft_reset,
	output [7:0] RB_chip_id,
	output [1:0] RB_speed_grade_id,
	output RB_data_channel_b,
	output RB_data_channel_a,
	output RB_transfer,
	output RB_ext_pow_down_fun,
	output [1:0] RB_int_pow_down_fun,
	output RB_duty_cycle_stab,
	output [2:0]  RB_clock_divide_ratio,
	output RB_reset_pn_long_gen,
	output RB_reset_pn_short_gen,
	output [2:0] RB_output_test_mode,
	output RB_reset_bist_sequence,
	output RB_bist_enable,
	output RB_common_mode_servo_enable,
	output [7:0] RB_offset_adjust,
	output RB_drive_strength,
	output RB_output_type,
	output RB_cmos_output_interleave_enable,
	output RB_output_enable_bar,
	output RB_output_inverter,
	output [1:0] RB_output_format,
	output RB_invert_dco_clock,
	output [2:0] RB_input_clock_divider_phase_adjust,
	output [4:0] RB_dco_clock_delay,
	output [1:0]  RB_reference_voltage_selection,
	output [7:0] RB_bist_signature_lsb,
	output [7:0] RB_bist_signature_msb,
	output RB_dither_enable,
	output RB_clock_divider_next_sync_only,
	output RB_clock_divider_sync_enable,
	output RB_master_sync_enable
);
// add comments for register auto generation define register at upper level
// REG_reg_name   // [u/s] width default_value
// REG_lsb_first  // u 1 0
// REG_soft_reset // u 1 1

localparam REG_00=9'h00, REG_01_R=9'h01, REG_02_R=9'h02, REG_05=9'h05, REG_FF=9'hff,
		   REG_08=9'h08, REG_09=9'h09, REG_0B=9'h0b, REG_0D=9'h0d, REG_0E=9'h0e,
		   REG_0F=9'h0f, REG_10=9'h10, REG_14=9'h14, REG_16=9'h16, REG_17=9'h17,
		   REG_18=9'h18, REG_24_R=9'h24, REG_25_R=9'h25, REG_30=9'h30, REG_100=9'h100,
		   REG_IDLE=9'h1ff;
//parameter ADC_DATA_WIDTH=16,

wire sclk, sdio;
wire [8:0] spi_addr;
reg [7:0] spi_data;
wire spi_ack;

assign pdwn=1'b0;
assign oeb=1'b0;
assign sdio=sdio_dcs; // pin 44

wire [7:0] reg_00_spi_port_cfg={1'b0,lsb_first,soft_reset,2'b11,soft_reset,lsb_first,1'b0};
wire [7:0] reg_05_channel_index={6'b0,data_channel_b,data_channel_a};
wire [7:0] reg_ff_transfer_reg={7'b0,transfer};
wire [7:0] reg_08_power_mode={2'b10,ext_pow_down_fun,3'b100,int_pow_down_fun};
wire [7:0] reg_09_global_clock ={7'b0,duty_cycle_stab};
wire [7:0] reg_0b_clock_divide={5'b0,clock_divide_ratio};
wire [7:0] reg_0d_test_mode={2'b0,reset_pn_long_gen,reset_pn_short_gen,1'b0,output_test_mode};
wire [7:0] reg_0e_bist_enable_reg={5'b0,reset_bist_sequence,1'b0,bist_enable};
wire [7:0] reg_0f_adc_input={7'b0,common_mode_servo_enable};
wire [7:0] reg_10_offset_adjust=offset_adjust;
wire [7:0] reg_14_output_mode={drive_strength,output_type,cmos_output_interleave_enable,output_enable_bar,1'b0,output_inverter,output_format};
wire [7:0] reg_16_clock_phase_control={invert_dco_clock,4'b0,input_clock_divider_phase_adjust};
wire [7:0] reg_17_dco_output_delay={3'b0,dco_clock_delay};
wire [7:0] reg_18_vref_slect={reference_voltage_selection,6'b0};
wire [7:0] reg_30_dither_enable_reg={3'b0,dither_enable,4'b0};
wire [7:0] reg_100_sync_control={5'b0,clock_divider_next_sync_only,clock_divider_sync_enable,master_sync_enable};


reg [7:0] rb_reg_00_spi_port_cfg=8'h00;
reg [7:0] rb_reg_01_chip_id_reg=8'h00;
reg [7:0] rb_reg_02_chip_grade=8'h00;
reg [7:0] rb_reg_05_channel_index=8'h00;
reg [7:0] rb_reg_ff_transfer_reg=8'h00;
reg [7:0] rb_reg_08_power_mode=8'h00;
reg [7:0] rb_reg_09_global_clock =8'h00;
reg [7:0] rb_reg_0b_clock_divide=8'h00;
reg [7:0] rb_reg_0d_test_mode=8'h00;
reg [7:0] rb_reg_0e_bist_enable_reg=8'h00;
reg [7:0] rb_reg_0f_adc_input=8'h00;
reg [7:0] rb_reg_10_offset_adjust=8'h00;
reg [7:0] rb_reg_14_output_mode=8'h00;
reg [7:0] rb_reg_16_clock_phase_control=8'h00;
reg [7:0] rb_reg_17_dco_output_delay=8'h00;
reg [7:0] rb_reg_18_vref_slect=8'h00;
reg [7:0] rb_reg_24_bist_signature_lsb=8'h00;
reg [7:0] rb_reg_25_bist_signature_msb=8'h00;
reg [7:0] rb_reg_30_dither_enable_reg=8'h00;
reg [7:0] rb_reg_100_sync_control=8'h00;

assign RB_lsb_first=rb_reg_00_spi_port_cfg[1];
assign RB_soft_reset=rb_reg_00_spi_port_cfg[1];
assign RB_chip_id=rb_reg_01_chip_id_reg;
assign RB_speed_grade_id=rb_reg_02_chip_grade[5:4];
assign RB_data_channel_b=rb_reg_05_channel_index[1];
assign RB_data_channel_a=rb_reg_05_channel_index[0];
assign RB_transfer=rb_reg_ff_transfer_reg[0];
assign RB_ext_pow_down_fun=rb_reg_08_power_mode[5];
assign RB_int_pow_down_fun=rb_reg_08_power_mode[1:0];
assign RB_duty_cycle_stab=rb_reg_09_global_clock[0];
assign RB_clock_divide_ratio=rb_reg_0b_clock_divide[2:0];
assign RB_reset_pn_long_gen=rb_reg_0d_test_mode[5];
assign RB_reset_pn_short_gen=rb_reg_0d_test_mode[4];
assign RB_output_test_mode=rb_reg_0d_test_mode[2:0];
assign RB_reset_bist_sequence=rb_reg_0e_bist_enable_reg[2];
assign RB_bist_enable=rb_reg_0e_bist_enable_reg[0];
assign RB_common_mode_servo_enable=rb_reg_0f_adc_input[0];
assign RB_offset_adjust=rb_reg_10_offset_adjust;
assign RB_drive_strength=rb_reg_14_output_mode[7];
assign RB_output_type=rb_reg_14_output_mode[6];
assign RB_cmos_output_interleave_enable=rb_reg_14_output_mode[5];
assign RB_output_enable_bar=rb_reg_14_output_mode[4];
assign RB_output_inverter=rb_reg_14_output_mode[2];
assign RB_output_format=rb_reg_14_output_mode[1:0];
assign RB_invert_dco_clock=rb_reg_16_clock_phase_control[7];
assign RB_input_clock_divider_phase_adjust=rb_reg_16_clock_phase_control[2:0];
assign RB_dco_clock_delay=rb_reg_17_dco_output_delay[4:0];
assign RB_reference_voltage_selection=rb_reg_18_vref_slect[7:6];
assign RB_bist_signature_lsb=rb_reg_24_bist_signature_lsb;
assign RB_bist_signature_msb=rb_reg_25_bist_signature_msb;
assign RB_dither_enable=rb_reg_30_dither_enable_reg[4];
assign RB_clock_divider_next_sync_only=rb_reg_100_sync_control[2];
assign RB_clock_divider_sync_enable=rb_reg_100_sync_control[1];
assign RB_master_sync_enable=rb_reg_100_sync_control[0];


reg [8:0] addr=REG_IDLE;
reg [8:0] addr_next=REG_IDLE;
reg spi_start_to_driver=0;
wire spi_ack_strobe;
wire spi_start_mux;

/*
 ORA_ORP,  // pin 43 35
 D15A_ORN,  // pin 42 34
 D14A_D15P,  // pin 41 33
 D13A_D15N,  // pin 40 32
 D12A_D14P,  // pin 39 31
 D11A_D14N,  // pin 38 30
 D10A_D13P,  // pin 36 29
 D9A_D13N,  // pin 35 28
 D8A_D12P,  // pin 34 27
 D7A_D12N,  // pin 33 26
 D6A_D11P,  // pin 32 25
 D5A_D11N,  // pin 31 24
 D4A_D10P,  // pin 30 23
 D3A_D10N,  // pin 29 22
 D2A_D9P,  // pin 27 21
 D1A_D9N,  // pin 26 20
 D0A_DCOP,  // pin 25 19
 DCOA_DCON,  // pin 24 18
 DCOB_D8P,  // pin 23 17
 ORB_D8N,  // pin 22 16
 D15B_D7P,  // pin 21 15
 D14B_D7N,  // pin 20 14
 D13B_D6P,  // pin 18 13
 D12B_D6N,  // pin 17 12
 D11B_D5P,  // pin 16 11
 D10B_D5N,  // pin 15 10
 D9B_D4P,  // pin 14 9
 D8B_D4N,  // pin 13 8
 D7B_D3P,  // pin 12 7
 D6B_D3N,  // pin 11 6
 D5B_D2P,  // pin 9 5
 D4B_D2N,  // pin 8 4
 D3B_D1P,  // pin 7 3
 D2B_D1N,  // pin 6 2
 D1B_D0P,  // pin 5 1
 D0B_D0N,  // pin 4 0
*/

wire [ADC_DATA_WIDTH:0] a_out;
wire [ADC_DATA_WIDTH:0] b_out;

reg [ADC_DATA_WIDTH:0] a_out_r;
reg [ADC_DATA_WIDTH:0] b_out_r;

assign data_a=a_out_r[ADC_DATA_WIDTH:1];
assign data_b=b_out_r[ADC_DATA_WIDTH:1];
always @(posedge adc_clk) begin
	a_out_r<=a_out;
	b_out_r<=b_out;
end
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


assign spi_start_mux=spi_start|spi_start_to_driver;
spi_ad9268 #(.tsckw(tsckw)) spi_port(
    .clk(clk_fpga),.strobe(spi_start_mux),.ce(1'b1),.rd(spi_rw),
    .ack(spi_ack),.addr(addr),.din(spi_data),
    .csb(csb),.sclk(sclk_dfs),.sdio(sdio_dcs),
    .read_r(spi_rdbk)
//    .read_r(),.spi_state(spi_rdbk)
);

// spi addr state machine
always @(posedge clk_fpga) begin
	addr<=addr_next;
end

always @(*) begin
	case(addr)
		REG_IDLE: addr_next = spi_start ? REG_00 : REG_IDLE;
		REG_00: addr_next = spi_ack_strobe ? (spi_rw ? REG_01_R : REG_05) : REG_00;
		REG_01_R: addr_next = spi_ack_strobe ? REG_02_R : REG_01_R;
		REG_02_R: addr_next = spi_ack_strobe ? REG_05 : REG_02_R;
		REG_05: addr_next = spi_ack_strobe ? REG_08 : REG_05;
		REG_08: addr_next = spi_ack_strobe ? REG_09 : REG_08;
		REG_09: addr_next = spi_ack_strobe ? REG_0B : REG_09;
		REG_0B: addr_next = spi_ack_strobe ? REG_0D : REG_0B;
		REG_0D: addr_next = spi_ack_strobe ? REG_0E : REG_0D;
		REG_0E: addr_next = spi_ack_strobe ? REG_0F : REG_0E;
		REG_0F: addr_next = spi_ack_strobe ? REG_10 : REG_0F;
		REG_10: addr_next = spi_ack_strobe ? REG_14 : REG_10;
		REG_14: addr_next = spi_ack_strobe ? REG_16 : REG_14;
		REG_16: addr_next = spi_ack_strobe ? REG_17 : REG_16;
		REG_17: addr_next = spi_ack_strobe ? REG_18 : REG_17;
		REG_18: addr_next = spi_ack_strobe ? (spi_rw ? REG_24_R : REG_30) : REG_18;
		REG_24_R: addr_next = spi_ack_strobe ? REG_25_R : REG_24_R;
		REG_25_R: addr_next = spi_ack_strobe ? REG_30 : REG_25_R;
		REG_30: addr_next = spi_ack_strobe ? REG_FF : REG_30;
		REG_FF: addr_next = spi_ack_strobe ? REG_100 : REG_FF;
		REG_100: addr_next = spi_ack_strobe ? REG_IDLE : REG_100;
		default: addr_next = REG_IDLE;
	endcase
end
// End spi addr state machine

// multiplexer: slect the spi writing data
always @(*) begin
	case(addr)
		REG_IDLE: spi_data=8'h0;
		REG_00: spi_data=reg_00_spi_port_cfg;
		REG_05: spi_data=reg_05_channel_index;
		REG_FF: spi_data=reg_ff_transfer_reg;
		REG_08: spi_data=reg_08_power_mode;
		REG_09: spi_data=reg_09_global_clock;
		REG_0B: spi_data=reg_0b_clock_divide;
		REG_0D: spi_data=reg_0d_test_mode;
		REG_0E: spi_data=reg_0e_bist_enable_reg;
		REG_0F: spi_data=reg_0f_adc_input;
		REG_10: spi_data=reg_10_offset_adjust;
		REG_14: spi_data=reg_14_output_mode;
		REG_16: spi_data=reg_16_clock_phase_control;
		REG_17: spi_data=reg_17_dco_output_delay;
		REG_18: spi_data=reg_18_vref_slect;
		REG_30: spi_data=reg_30_dither_enable_reg;
		REG_100:spi_data=reg_100_sync_control;
		default: spi_data=8'h0;
	endcase
end

// Registers Readback
always @(posedge clk_fpga) begin
	if (spi_rw&&spi_ack_strobe) begin
		case(addr)
			REG_IDLE:  begin end
			REG_00:    rb_reg_00_spi_port_cfg <= spi_rdbk;
			REG_01_R:  rb_reg_01_chip_id_reg <= spi_rdbk;
			REG_02_R:    rb_reg_02_chip_grade <= spi_rdbk;
			REG_05:    rb_reg_05_channel_index <= spi_rdbk;
			REG_FF:    rb_reg_ff_transfer_reg <= spi_rdbk;
			REG_08:    rb_reg_08_power_mode <= spi_rdbk;
			REG_09:    rb_reg_09_global_clock  <= spi_rdbk;
			REG_0B:    rb_reg_0b_clock_divide <= spi_rdbk;
			REG_0D:    rb_reg_0d_test_mode <= spi_rdbk;
			REG_0E:    rb_reg_0e_bist_enable_reg <= spi_rdbk;
			REG_0F:    rb_reg_0f_adc_input <= spi_rdbk;
			REG_10:    rb_reg_10_offset_adjust <= spi_rdbk;
			REG_14:    rb_reg_14_output_mode <= spi_rdbk;
			REG_16:    rb_reg_16_clock_phase_control <= spi_rdbk;
			REG_17:    rb_reg_17_dco_output_delay <= spi_rdbk;
			REG_18:    rb_reg_18_vref_slect <= spi_rdbk;
			REG_24_R:  rb_reg_24_bist_signature_lsb <= spi_rdbk;
			REG_25_R:  rb_reg_25_bist_signature_msb <= spi_rdbk;
			REG_30:    rb_reg_30_dither_enable_reg <= spi_rdbk;
			REG_100:   rb_reg_100_sync_control <= spi_rdbk;
			default: ;
		endcase
	end
end

strobe_gen #(
	.TYPE("FAIL_EDGE")
) spi_ack_strobe_gen(
	.I_clk(clk_fpga),.I_signal(~spi_ack),.O_strobe(spi_ack_strobe)
);

always @(posedge clk_fpga) begin
	spi_start_to_driver<=spi_ack_strobe&&(addr!=REG_100);
end


endmodule

// some using stuff
/*
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

wire m_00_spi_port_cfg=&{1'b0,M_lsb_first,M_soft_reset,2'b00,M_soft_reset,M_lsb_first,1'b0};
wire m_05_channel_index=&{6'b0,M_data_channel_b,M_data_channel_a};
wire m_ff_transfer_reg=&{7'b0,M_transfer};
wire m_08_power_mode=&{2'b00,M_ext_pow_down_fun,3'b000,M_int_pow_down_fun};
wire m_09_global_clock =&{7'b0,M_duty_cycle_stab};
wire m_0b_clock_divide=&{5'b0,M_clock_divide_ratio};
wire m_0d_test_mode=&{2'b0,M_reset_pn_long_gen,M_reset_pn_short_gen,1'b0,M_output_test_mode};
wire m_0e_bist_enable_reg=&{5'b0,M_reset_bist_sequence,1'b0,M_bist_enable};
wire m_0f_adc_input=&{7'b0,M_common_mode_servo_enable};
wire m_10_offset_adjust=M_offset_adjust;
wire m_14_output_mode=&{M_drive_strength,M_output_type,M_output_enable_bar,1'b0,M_output_inverter,M_output_format};
wire m_16_clock_phase_control=&{M_invert_dco_clock,4'b0,M_input_clock_divider_phase_adjust};
wire m_17_dco_output_delay=&{3'b0,M_dco_clock_delay};
wire m_18_vref_slect=&{M_reference_voltage_selection,6'b0};
wire m_30_dither_enable_reg=&{3'b0,M_dither_enable,4'b0};
wire m_100_sync_control=&{5'b0,M_clock_divider_next_sync_only,M_clock_divider_sync_enable,M_master_sync_enable};

 spi_master wires
reg spi_rw;
reg [8:0] spi_addr;
reg [7:0] spi_data;
wire spi_start;
wire spi_ack;
wire csb, sclk, sdio;
wire [7:0] spi_rdbk;

	// Mask means need to be modified
	input M_lsb_first,
	input M_soft_reset,
	//input [7:0] M_chip_id,
	//input [1:0] M_speed_grade_id,
	input M_data_channel_b,
	input M_data_channel_a,
	input M_transfer,
	input M_ext_pow_down_fun,
	input [1:0] M_int_pow_down_fun,
	input M_duty_cycle_stab,
	input [2:0]  M_clock_divide_ratio,
	input M_reset_pn_long_gen,
	input M_reset_pn_short_gen,
	input [2:0] M_output_test_mode,
	input M_reset_bist_sequence,
	input M_bist_enable,
	input M_common_mode_servo_enable,
	input [7:0] M_offset_adjust,
	input M_drive_strength,
	input M_output_type,
	input M_cmos_output_interleave_enable,
	input M_output_enable_bar,
	input M_output_inverter,
	input [1:0] M_output_format,
	input M_invert_dco_clock,
	input [2:0] M_input_clock_divider_phase_adjust,
	input [4:0] M_dco_clock_delay,
	input [1:0]  M_reference_voltage_selection,
	input [7:0] M_bist_signature_lsb,
	input [7:0] M_bist_signature_msb,
	input M_dither_enable,
	input M_clock_divider_next_sync_only,
	input M_clock_divider_sync_enable,
	input M_master_sync_enable

*/


