`timescale 1ns / 1ns
module spi_master_tb;

reg clk=0;

// spi_master wires
reg spi_rw;
reg [6:0] spi_addr;
reg [7:0] spi_data;
wire spi_start;
wire cs, sck, sdo;
wire [6:0] sdo_addr;
wire [7:0] spi_rdbk;

initial begin
	if($test$plusargs("vcd")) begin
		$dumpfile("spi_master.vcd");
		$dumpvars(5,spi_master_tb);
	end

	spi_rw=0;
	spi_addr=7'h04;
	spi_data=8'h21;
	while ($time<10000) begin
		#10;
	end
	$finish;
end

always #5 clk=~clk; // 100 MHz clk

reg start=0;
//============================================================
// spi start generater
//============================================================
always @(posedge clk) begin
	if (($time>50)&&($time<100))
		start<=1;
	else
		start<=0;
end

//============================================================
// spi master instantiation
//============================================================
spi_master #(.tsckw(5)) spi_port(
	.clk(clk),.spi_start(spi_start),.spi_read(spi_rw),
	.spi_addr(spi_addr),.spi_data(spi_data),
	.cs(cs),.sck(sck),.sdo(sdo),.sdi(sdi),
	.sdo_addr(sdo_addr),.spi_rdbk(spi_rdbk)
);

//============================================================
// strobe_gen instantiation
//============================================================
strobe_gen strobe_gen(
	.I_clk(clk), .I_signal(start), .O_strobe(spi_start)
);

endmodule


