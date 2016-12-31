`timescale 1ns/10ps
module ltc2174_sim(
	input [13:0] ain1,
	input [13:0] ain2,
	input [13:0] ain3,
	input [13:0] ain4,
	input enc,

	input cs,
	input sck,
	input sdi,
	output sdo,

	output frame_p,
	output frame_n,
	output dco_p,
	output dco_n,
	output [3:0] adca_p,
	output [3:0] adca_n,
	output [3:0] adcb_p,
	output [3:0] adcb_n,
	output reg [2:0] outmode=0,
	input parser
);
parameter REVERSE_A=4'b1111;
parameter REVERSE_B=4'b1111;
parameter REVERSE_F=1'b1;
parameter REVERSE_DCO=1'b0;

parameter ts=10;
reg dscoff=1;
reg rand=1;
reg twoscomp=0;
reg [4:0] sleep=0;
reg [2:0] ilvds=0;
reg termon=0;
reg outoff=0;
//reg [2:0] outmode=0;
reg outtest=0;
reg [13:0] testpattern=14'h3e;

wire [3:0] adca,adcb;
real  tser;//=ts/8.0;
real tser_h;
real tser_l;
real tpd;
real tpd_tser;
real tframe;
initial begin
	tpd=1.1+2.0*tser;
	tser=ts/8.0;
	tser_h=tser/2.0;
	tser_l=tser-tser_h;
	tframe=0.5*tser;
	tpd_tser=1.1+1.0*tser;
end
reg [4:0] sck_cnt=0;
reg spi_read=0;
always @(negedge cs)
		sck_cnt<=5'h0;
always @( posedge sck) begin
		sck_cnt <=  sck_cnt+1;
end
reg [6:0] sdi_addr=0;
reg [7:0] sdi_in=0;
reg [7:0] sdo_value=0;
reg temp=0;
wire new_sck=(sck_cnt==0);
reg [7:0] sdi_data=0;
wire load_sdo=(sck_cnt==8);
always @(posedge sck) begin
	if (sck_cnt==0) begin
		spi_read <= sdi;
	end else if (sck_cnt <=7) begin
		sdi_addr<={sdi_addr[5:0],sdi};
	end else if (sck_cnt <=15) begin
		if (spi_read) begin
			sdo_value <= {sdo_value[6:0],1'b0};
		end else begin
			sdi_in<={sdi_in[6:0],sdi};
		end
    end

end
assign sdo=sdo_value[7];
reg cs_d=0;
always @(posedge dco_p) begin
	cs_d <= cs;
	if (~spi_read & cs & ~cs_d) begin
		case (sdi_addr)
			4'd1: {dscoff,rand,twoscomp,sleep} <= sdi_in;
			4'd2: {ilvds,termon,outoff,outmode} <= sdi_in;
			4'd3: {outtest,temp,testpattern[13:8]} <= sdi_in;
			4'd4: {testpattern[7:0]} <= sdi_in;
		endcase
		sdi_data <= sdi_in;
	end
	if (spi_read & sck_cnt==8) begin
		case (sdi_addr)
			4'd1: sdo_value<={dscoff,rand,twoscomp,sleep};
			4'd2: sdo_value<={ilvds,termon,outoff,outmode};
			4'd3: sdo_value<={outtest,1'b0,testpattern[13:8]};
			4'd4: sdo_value<={testpattern[7:0]};
		endcase
	end
end

reg frame_r_pre=0; // One tser period ahead of frame_r
wire #tser frame_r=frame_r_pre;

always @(*) begin
	tpd=1.1+2*tser;
	tser_h=tser/2.0;
	tser_l=tser-tser_h;
	tframe=0.5*tser;
	tpd_tser=1.1+1.0*tser;
end

// Load the 'analog input' to regs
reg [13:0] adc1_r=0,adc2_r=0,adc3_r=0,adc4_r=0;
always @ (posedge enc) begin
#0.01  adc1_r <= ain1;
#0.02  adc2_r <= ain2;
#0.03  adc3_r <= ain3;
#0.04  adc4_r <= ain4;
end

// I don't want to miss the frame_r edge for the dco generation
// so I make the delay a little shorter, by make the divider a
// little bigger for instance: 8.00-->8.01
always @(posedge enc) begin
	case(outmode)
		0:tser=ts/8.0;
		1:tser=ts/7.0;
		2:tser=ts/6.0;
		5:tser=ts/16.0;
		6:tser=ts/14.0;
		7:tser=ts/12.0;
		default: tser=ts/8.0;
	endcase
end
reg dco_ideal_p_r=0,dco_p_r=0;

// because we want to use ENC as the primary clock source
// we must generator the higher frequency clock DCO by
// using delayed toggle in always block.
// Here try to figure out how many toggles need in one
// always block for generation DCO
integer dco_i=8; // dco_i is the number of toggle
integer dco_var_i=0;
always @(*) begin
	case(outmode)
		0:dco_i=8;
		1:dco_i=7;
		2:dco_i=6;
		5:dco_i=16;
		6:dco_i=14;
		7:dco_i=12;
	endcase
end

// generating DCO
always @(posedge frame_r or negedge frame_r) begin
	if (outmode==1) begin
		if (frame_r) begin // This is the rising edge
			dco_ideal_p_r=1;
		end else begin
			dco_ideal_p_r=0;
		end
		for (dco_var_i=1;dco_var_i<dco_i;dco_var_i=dco_var_i+1) begin
			#tser; dco_ideal_p_r=~dco_ideal_p_r;
		end
	end else begin
		if (frame_r) begin // This is the rising edge
			dco_ideal_p_r=1;
			for (dco_var_i=1;dco_var_i<dco_i;dco_var_i=dco_var_i+1) begin
				#tser; dco_ideal_p_r=~dco_ideal_p_r;
			end
		end
	end
end

//always begin
always @(*) begin
	#tframe dco_p_r = dco_ideal_p_r;
end

assign dco_p = dco_p_r;
assign dco_n = ~dco_p_r;
reg [13:0] adc1_sr=0,adc2_sr=0,adc3_sr=0,adc4_sr=0;
/*always @(posedge frame_p) begin
	#tpd  adc1_sr <= adc1_r;
	#tpd  adc2_sr <= adc2_r;
	#tpd  adc3_sr <= adc3_r;
	#tpd  adc4_sr <= adc4_r;
end
*/
//reg frame_p_d=0;
//wire new_frame=frame_p^frame_p_d;
wire new_frame=(outmode==1)?(frame_r ^ frame_r_pre):((~frame_r)&frame_r_pre);
// frame_r_pre is #tser ahead of frame_r
always @(posedge dco_ideal_p_r or negedge dco_ideal_p_r) begin
// frame_p_d <= frame_p;
	if (new_frame) begin
		adc1_sr <= adc1_r;
		adc2_sr <= adc2_r;
		adc3_sr <= adc3_r;
		adc4_sr <= adc4_r;
	end else begin
		if (~outmode[2]) begin
			adc1_sr <= {adc1_sr[11:0],2'b0};
			adc2_sr <= {adc2_sr[11:0],2'b0};
			adc3_sr <= {adc3_sr[11:0],2'b0};
			adc4_sr <= {adc4_sr[11:0],2'b0};
		end else begin
			adc1_sr <= {adc1_sr[12:0],1'b0};
			adc2_sr <= {adc2_sr[12:0],1'b0};
			adc3_sr <= {adc3_sr[12:0],1'b0};
			adc4_sr <= {adc4_sr[12:0],1'b0};
		end
	end
end

// frame_r generation
// for outmode 1: frame period is twice of enc
// for other mode: frame has same period as enc
reg enc_div2=0;
always @(posedge enc) begin
	enc_div2=~enc_div2;
end
wire enc_using=(outmode==1) ? enc_div2 : enc;


always @(*) begin
	#tpd_tser frame_r_pre = enc_using;
end


wire adc1_a=adc1_sr[13];
wire adc1_b=adc1_sr[12];
wire adc2_a=adc2_sr[13];
wire adc2_b=adc2_sr[12];
wire adc3_a=adc3_sr[13];
wire adc3_b=adc3_sr[12];
wire adc4_a=adc4_sr[13];
wire adc4_b=adc4_sr[12];

assign adca_p=REVERSE_A^{adc4_sr[13],adc3_sr[13],adc2_sr[13],adc1_sr[13]};
assign adca_n=~adca_p;
assign adcb_p=REVERSE_B^{adc4_sr[12],adc3_sr[12],adc2_sr[12],adc1_sr[12]};
assign adcb_n=~adcb_p;
assign frame_p = REVERSE_F^frame_r;
assign frame_n =~frame_p;
endmodule
