`timescale 1ns / 10ps
module iserdes2_phy #(
	parameter DATA_WIDTH=8,
	parameter SIM_TAP_DELAY = 49
)
(
	clk_p_1,clk_n_1,ioce_1,clkdiv_1,bitslip_1,
	clk_p_2,clk_n_2,ioce_2,clkdiv_2,bitslip_2,
	da,db,dout,
	reset,reva_flag,revb_flag
);
input clk_p_1;
input clk_n_1;
input ioce_1;
input clkdiv_1;
input clk_p_2;
input clk_n_2;
input ioce_2;
input clkdiv_2;
//input ioce2;
input bitslip_1;
input bitslip_2;
input da;
input db;
input reva_flag;
input revb_flag;
input reset;
output [15:0] dout;
//ltc2174 driver(.frame_p(frame_p),.frame_n(frame_n),.dco_p(dco_p),.dco_n(dco_n),.adca_p(adca_p),.adca_n(adca_n),.adcb_p(adcb_p),.adcb_n(adcb_n),.adc1(adc1),.adc2(adc2),.adc3(adc3),.adc4(adc4),.cs(cs),.sck(sck),.sdi(sdi),.sdo(sdo),.parser(parser),.dscoff(dscoff),.rand(rand),.twoscomp(twoscomp),.sleep(sleep),.ilvds(ilvds),.termon(termon),.outoff(outoff),.outmode(outmode),.outtest(outtest),.testpattern(testpattern),.spi_start(spi_start),.spi_read(spi_read));

// FR + 4A + 4B
wire shift_wire_a,shift_wire_b;

wire [7:0] data_a, data_b;
reg cal_data_master=0;
reg inc_data=0;
reg cd_data_a=0;
reg rst_data=0;
wire ddly_a_m,ddly_a_s,ddly_b_m,ddly_b_s;
wire busys_a,busys_b;
wire ce_data_a;
wire ce_data_b;
wire cal_data_slave;
IODELAY2 #(
        .DATA_RATE              ("DDR"),                // <SDR>, DDR
        .IDELAY_VALUE           (0),                    // {0 ... 255}
        .IDELAY2_VALUE          (0),                    // {0 ... 255}
        .IDELAY_MODE            ("NORMAL" ),            // NORMAL, PCI
        .ODELAY_VALUE           (0),                    // {0 ... 255}
        .IDELAY_TYPE            ("DIFF_PHASE_DETECTOR"),// "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
        .COUNTER_WRAPAROUND     ("WRAPAROUND" ),        // <STAY_AT_LIMIT>, WRAPAROUND
        .DELAY_SRC              ("IDATAIN" ),           // "IO", "IDATAIN", "ODATAIN"
        .SERDES_MODE            ("MASTER"),             // <NONE>, MASTER, SLAVE
        .SIM_TAPDELAY_VALUE     (SIM_TAP_DELAY))        //
iodelay_a_m (
        .IDATAIN                (da),    // data from primary IOB
        .TOUT                   (),                     // tri-state signal to IOB
        .DOUT                   (),                     // output data to IOB
        .T                      (1'b1),                 // tri-state control from OLOGIC/OSERDES2
        .ODATAIN                (1'b0),                 // data from OLOGIC/OSERDES2
        .DATAOUT                (ddly_a_m),            // Output data 1 to ILOGIC/ISERDES2
        .DATAOUT2               (),                     // Output data 2 to ILOGIC/ISERDES2
        .IOCLK0                 (clk_p_1),             // High speed clock for calibration
        .IOCLK1                 (clk_n_1),             // High speed clock for calibration
        .CLK                    (clkdiv_1),                 // Fabric clock (GCLK) for control signals
        .CAL                    (cal_data_master),      // Calibrate control signal
        .INC                    (inc_data),             // Increment counter
        .CE                     (ce_data_a),           // Clock Enable
        .RST                    (rst_data),             // Reset delay line
        .BUSY                   ()) ;                   // output signal indicating sync circuit has finished / calibration has finished


IODELAY2 #(
        .DATA_RATE              ("DDR"),                // <SDR>, DDR
        .IDELAY_VALUE           (0),                    // {0 ... 255}
        .IDELAY2_VALUE          (0),                    // {0 ... 255}
        .IDELAY_MODE            ("NORMAL" ),            // NORMAL, PCI
        .ODELAY_VALUE           (0),                    // {0 ... 255}
        .IDELAY_TYPE            ("DIFF_PHASE_DETECTOR"),// "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
        .COUNTER_WRAPAROUND     ("WRAPAROUND" ),        // <STAY_AT_LIMIT>, WRAPAROUND
        .DELAY_SRC              ("IDATAIN" ),           // "IO", "IDATAIN", "ODATAIN"
        .SERDES_MODE            ("SLAVE"),              // <NONE>, MASTER, SLAVE
        .SIM_TAPDELAY_VALUE     (SIM_TAP_DELAY))        //
iodelay_a_s (
        .IDATAIN                (da),    // data from primary IOB
        .TOUT                   (),                     // tri-state signal to IOB
        .DOUT                   (),                     // output data to IOB
        .T                      (1'b1),                 // tri-state control from OLOGIC/OSERDES2
        .ODATAIN                (1'b0),                 // data from OLOGIC/OSERDES2
        .DATAOUT                (ddly_a_s),            // Output data 1 to ILOGIC/ISERDES2
        .DATAOUT2               (),                     // Output data 2 to ILOGIC/ISERDES2
        .IOCLK0                 (clk_p_1),             // High speed clock for calibration
        .IOCLK1                 (clk_n_1),             // High speed clock for calibration
        .CLK                    (clkdiv_1),                 // Fabric clock (GCLK) for control signals
        .CAL                    (cal_data_slave),       // Calibrate control signal
        .INC                    (inc_data),             // Increment counter
        .CE                     (ce_data_b),           // Clock Enable
        .RST                    (rst_data),             // Reset delay line
        .BUSY                   (busys_a)) ;           // output signal indicating sync circuit has finished / calibration has finished


IODELAY2 #(
        .DATA_RATE              ("DDR"),                // <SDR>, DDR
        .IDELAY_VALUE           (0),                    // {0 ... 255}
        .IDELAY2_VALUE          (0),                    // {0 ... 255}
        .IDELAY_MODE            ("NORMAL" ),            // NORMAL, PCI
        .ODELAY_VALUE           (0),                    // {0 ... 255}
        .IDELAY_TYPE            ("DIFF_PHASE_DETECTOR"),// "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
        .COUNTER_WRAPAROUND     ("WRAPAROUND" ),        // <STAY_AT_LIMIT>, WRAPAROUND
        .DELAY_SRC              ("IDATAIN" ),           // "IO", "IDATAIN", "ODATAIN"
        .SERDES_MODE            ("MASTER"),             // <NONE>, MASTER, SLAVE
        .SIM_TAPDELAY_VALUE     (SIM_TAP_DELAY))        //
iodelay_b_m (
        .IDATAIN                (db),    // data from primary IOB
        .TOUT                   (),                     // tri-state signal to IOB
        .DOUT                   (),                     // output data to IOB
        .T                      (1'b1),                 // tri-state control from OLOGIC/OSERDES2
        .ODATAIN                (1'b0),                 // data from OLOGIC/OSERDES2
        .DATAOUT                (ddly_b_m),            // Output data 1 to ILOGIC/ISERDES2
        .DATAOUT2               (),                     // Output data 2 to ILOGIC/ISERDES2
        .IOCLK0                 (clk_p_2),             // High speed clock for calibration
        .IOCLK1                 (clk_n_2),             // High speed clock for calibration
        .CLK                    (clkdiv_2),                 // Fabric clock (GCLK) for control signals
        .CAL                    (cal_data_master),      // Calibrate control signal
        .INC                    (inc_data),             // Increment counter
        .CE                     (ce_data_a),           // Clock Enable
        .RST                    (rst_data),             // Reset delay line
        .BUSY                   ()) ;                   // output signal indicating sync circuit has finished / calibration has finished


IODELAY2 #(
        .DATA_RATE              ("DDR"),                // <SDR>, DDR
        .IDELAY_VALUE           (0),                    // {0 ... 255}
        .IDELAY2_VALUE          (0),                    // {0 ... 255}
        .IDELAY_MODE            ("NORMAL" ),            // NORMAL, PCI
        .ODELAY_VALUE           (0),                    // {0 ... 255}
        .IDELAY_TYPE            ("DIFF_PHASE_DETECTOR"),// "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
        .COUNTER_WRAPAROUND     ("WRAPAROUND" ),        // <STAY_AT_LIMIT>, WRAPAROUND
        .DELAY_SRC              ("IDATAIN" ),           // "IO", "IDATAIN", "ODATAIN"
        .SERDES_MODE            ("SLAVE"),              // <NONE>, MASTER, SLAVE
        .SIM_TAPDELAY_VALUE     (SIM_TAP_DELAY))        //
iodelay_b_s (
        .IDATAIN                (db),    // data from primary IOB
        .TOUT                   (),                     // tri-state signal to IOB
        .DOUT                   (),                     // output data to IOB
        .T                      (1'b1),                 // tri-state control from OLOGIC/OSERDES2
        .ODATAIN                (1'b0),                 // data from OLOGIC/OSERDES2
        .DATAOUT                (ddly_b_s),            // Output data 1 to ILOGIC/ISERDES2
        .DATAOUT2               (),                     // Output data 2 to ILOGIC/ISERDES2
        .IOCLK0                 (clk_p_2),             // High speed clock for calibration
        .IOCLK1                 (clk_n_2),             // High speed clock for calibration
        .CLK                    (clkdiv_2),                 // Fabric clock (GCLK) for control signals
        .CAL                    (cal_data_slave),       // Calibrate control signal
        .INC                    (inc_data),             // Increment counter
        .CE                     (ce_data_b),           // Clock Enable
        .RST                    (rst_data),             // Reset delay line
        .BUSY                   (busys_b)) ;           // output signal indicating sync circuit has finished / calibration has finished





ISERDES2 #(
	.DATA_RATE("DDR"),
	.DATA_WIDTH(DATA_WIDTH),
	.BITSLIP_ENABLE("TRUE"),
	.SERDES_MODE("MASTER"),
	.INTERFACE_TYPE("RETIMED")
) isd_m_a (
	.Q1(data_a[3]),.Q2(data_a[2]),.Q3(data_a[1]),.Q4(data_a[0]),
	.SHIFTIN(1'b0),
	.SHIFTOUT(shift_wire_a),
	.BITSLIP(bitslip_1),
	.CE0(1'b1),
	.CLK0(clk_p_1),.CLK1(clk_n_1),.CLKDIV(clkdiv_1),.D(ddly_a_m),.IOCE(ioce_1),.RST(reset)
);
// slave
ISERDES2 #(
	.DATA_RATE("DDR"),
	.DATA_WIDTH(DATA_WIDTH),
	.BITSLIP_ENABLE("TRUE"),
	.SERDES_MODE("SLAVE"),
	.INTERFACE_TYPE("RETIMED")
) isd_s_a (
	.Q1(data_a[7]),.Q2(data_a[6]),.Q3(data_a[5]),.Q4(data_a[4]),
	.SHIFTIN(shift_wire_a),
	.BITSLIP(bitslip_1),
	.CE0(1'b1),
	.CLK0(clk_p_1),.CLK1(clk_n_1),.CLKDIV(clkdiv_1),.D(ddly_a_s),.IOCE(ioce_1),.RST(reset)
);


// master
ISERDES2 #(
	.DATA_RATE("DDR"),
	.DATA_WIDTH(DATA_WIDTH),
	.BITSLIP_ENABLE("TRUE"),
	.SERDES_MODE("MASTER"),
	.INTERFACE_TYPE("RETIMED")
) isd_m_b (
	.Q1(data_b[3]),.Q2(data_b[2]),.Q3(data_b[1]),.Q4(data_b[0]),
	.SHIFTIN(1'b0),
	.SHIFTOUT(shift_wire_b),
	.BITSLIP(bitslip_2),
	.CE0(1'b1),
	.CLK0(clk_p_2),.CLK1(clk_n_2),.CLKDIV(clkdiv_2),.D(ddly_b_m),.IOCE(ioce_2),.RST(reset)
);
// slave
ISERDES2 #(
	.DATA_RATE("DDR"),
	.DATA_WIDTH(DATA_WIDTH),
	.BITSLIP_ENABLE("TRUE"),
	.SERDES_MODE("SLAVE"),
	.INTERFACE_TYPE("RETIMED")
) isd_s_b (
	.Q1(data_b[7]),.Q2(data_b[6]),.Q3(data_b[5]),.Q4(data_b[4]),
	.SHIFTIN(shift_wire_b),
	.BITSLIP(bitslip_2),
	.CE0(1'b1),
	.CLK0(clk_p_2),.CLK1(clk_n_2),.CLKDIV(clkdiv_2),.D(1'b0),.IOCE(ioce_2),.RST(reset)
);

reg [15:0] dout;
wire [15:0]  out_mask;
assign out_mask={{2*DATA_WIDTH{1'b1}},{16-2*DATA_WIDTH{1'b0}}};
always @(posedge clkdiv_1) begin
	if (reset)
		dout <= 16'b0;
	else begin
		case ({reva_flag,revb_flag})
			2'b00:
dout <= {
	data_a[7], data_b[7],
	data_a[6], data_b[6],
	data_a[5], data_b[5],
	data_a[4], data_b[4],
	data_a[3], data_b[3],
	data_a[2], data_b[2],
	data_a[1], data_b[1],
	data_a[0], data_b[0]}&out_mask;
			2'b01:
dout <= {
	data_a[7], ~data_b[7],
	data_a[6], ~data_b[6],
	data_a[5], ~data_b[5],
	data_a[4], ~data_b[4],
	data_a[3], ~data_b[3],
	data_a[2], ~data_b[2],
	data_a[1], ~data_b[1],
	data_a[0], ~data_b[0]}&out_mask;
			2'b10:
dout <= {
	~data_a[7], data_b[7],
	~data_a[6], data_b[6],
	~data_a[5], data_b[5],
	~data_a[4], data_b[4],
	~data_a[3], data_b[3],
	~data_a[2], data_b[2],
	~data_a[1], data_b[1],
	~data_a[0], data_b[0]}&out_mask;
			2'b11:
dout <= {
	~data_a[7], ~data_b[7],
	~data_a[6], ~data_b[6],
	~data_a[5], ~data_b[5],
	~data_a[4], ~data_b[4],
	~data_a[3], ~data_b[3],
	~data_a[2], ~data_b[2],
	~data_a[1], ~data_b[1],
	~data_a[0], ~data_b[0]}&out_mask;
		endcase
	end
end
endmodule
