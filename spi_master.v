module spi_master(
	// input clocks
	input clk,
	input spi_start,
	input spi_read,
	input [6:0] spi_addr,
	input [7:0] spi_data,
	output cs,
	output sck,
	output sdi,
	input sdo,
	output reg [6:0] sdo_addr,
	output reg [7:0] spi_rdbk,
	output spi_ready
);
parameter tsckw=5; //tsck is 2^5 time ts
reg cs_r=0,cs_r_d=0;
reg [tsckw-1:0] tckcnt=0;
reg sck_r=0;
reg [4:0] sck_cnt=5'h1f;
reg sck_r_d=0;
wire [tsckw-1:0] halftckcnt={1'b1,{{tsckw-1{1'b0}}}};
reg spi_read_r=0;

reg [6:0] sdi_addr=0;
always @(posedge clk) begin
	tckcnt <= cs_r ? tckcnt +1 :halftckcnt ;
	sck_r <= tckcnt[tsckw-1];
	sck_r_d <= sck_r;
	if (spi_start)
		cs_r <= 1;
	else if (sck_cnt==16)
		cs_r <= 0;

	if (spi_start) begin
		spi_read_r <= spi_read;
		sdi_addr <= spi_addr;
	end
	if (sck_r & ~sck_r_d) begin
		sck_cnt <= sck_cnt+1 ;
	end else begin
		sck_cnt <= cs_r ? sck_cnt :5'h1f;
	end
		cs_r_d <= cs_r;
end
assign cs=~cs_r;
assign sck=sck_r;

wire cs_edge=~cs_r&cs_r_d;
reg [15:0] sdi_value=0;
reg [7:0] sdo_rdbk_sr=0;
reg temp_rdbk=0;
reg [7:0] sdi_test=0;
always @(negedge sck) begin
	if (~spi_read_r) begin
		if (sck_cnt==5'h1f) begin
			sdi_value <= {1'b0,sdi_addr,spi_data};
		end else begin
			sdi_value <= {sdi_value[14:0],1'b0};
		end
	end else begin
		if (sck_cnt==5'h1f) begin
				sdi_value<={1'b1,sdi_addr,8'hc0};
		end else begin
			sdi_value <= {sdi_value[14:0],1'b0};
		end
	end
end
always @(posedge sck) begin
	if (sck_cnt >=5'd7 & sck_cnt <=5'd14) begin
		sdo_rdbk_sr <= {sdo_rdbk_sr[6:0],sdo};
	end
end
reg [7:0] sdo_test=0;
reg spi_ready_r=0;
always @(posedge clk) begin
	if (cs_edge&spi_read_r) begin
		sdo_addr <= sdi_addr;
		spi_rdbk <= sdo_rdbk_sr;
		spi_ready_r <= 1;
	end
	else
		spi_ready_r <=0;
end
assign sdi= cs_r & sdi_value[15];
assign spi_ready = spi_ready_r;

endmodule
