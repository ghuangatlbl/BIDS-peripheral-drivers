`timescale 1ns / 1ns

module mcp3208_wrap_tb;

reg clk;
integer cc, errors;
initial begin
	if ($test$plusargs("vcd")) begin
		$dumpfile("mcp3208_wrap.vcd");
		$dumpvars(5,mcp3208_wrap_tb);
	end
	errors=0;
	for (cc=0; cc<24000; cc=cc+1) begin
		clk=0; #11;
		clk=1; #11;
	end
	//$display("%s",errors==0?"PASS":"FAIL");
	$finish();
end

// Local bus emulation
integer file1;
reg [255:0] file1_name;
initial begin
	if (!$value$plusargs("reg_default_sim_file=%s", file1_name)) file1_name="reg_top_default_sim";
	file1 = $fopen(file1_name,"r");
end

integer rc=2;
reg [31:0] control_data, cd;
reg [6:0] control_addr, ca;
reg control_strobe;
integer control_cnt=0;
always @(posedge clk) begin
	control_cnt <= control_cnt+1;
	if (control_cnt > 5 && control_cnt%3==1 && rc==2) begin
		rc=$fscanf(file1,"%d %d\n",ca,cd);
		if (rc==2) begin
			$display("local bus[%d] = 0x%x (%d)", ca, cd, cd);
			control_data <= cd;
			control_addr <= ca;
			control_strobe <= 1;
		end
	end else begin
		control_data <= 32'hx;
		control_addr <= 7'hx;
		control_strobe <= 0;
	end
end

reg [11:0] count=0;
always @(posedge clk) count <= count+1;
wire [3:0] address=count[11:8];

wire [7:0] result;
wire adc_cs, adc_clk, adc_dout, adc_din;
mcp3208_wrap dut(.clk(clk),
	.lb_data(control_data), .lb_addr(control_addr), .lb_write(control_strobe),
	.address(address), .result(result),
	.adc_cs(adc_cs), .adc_clk(adc_clk), .adc_dout(adc_dout), .adc_din(adc_din)
);

mcp3208_behav ic(adc_cs, adc_clk, adc_dout, adc_din);

endmodule
