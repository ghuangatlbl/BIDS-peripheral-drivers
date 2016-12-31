module bitslip_gen_upgrade (
fclk,
rst,
bsp_clr,
bsp_start,
data_in,
bsp_gen,
bsp_cmp,
bsp_err,
bsp_pattern0,
bsp_pattern1
);

input fclk;
input rst;
input bsp_clr;
input bsp_start;
input [15:0] data_in;
input [15:0] bsp_pattern0;
input [15:0] bsp_pattern1;
output bsp_gen;
output bsp_cmp;
output bsp_err;

parameter IDLE_STAT     = 4'b0000;
parameter BSP1_STAT     = 4'b0001;
parameter BSP2_STAT     = 4'b0010;
parameter BSP3_STAT     = 4'b0011;
parameter BSP4_STAT     = 4'b0100;
parameter BSP5_STAT     = 4'b0101;
parameter BSP6_STAT     = 4'b0110;
parameter BSP7_STAT     = 4'b0111;
parameter BSP8_STAT     = 4'b1000;
parameter BSP9_STAT     = 4'b1001;

parameter BSP_ENABLE    = 1'b1;
parameter BSP_DISENABLE = 1'b0;
parameter BSP_MATCH     = 1'b1;
parameter BSP_DISMATCH  = 1'b0;
parameter BSP_FAULT     = 1'b1;
parameter BSP_NORMAL    = 1'b0;

//parameter BSP_PATTERN   = 16'h1669;
//parameter BSP_PATTERN   = 16'h16a9;
//parameter BSP_PATTERN   = 16'h2ec4;
//parameter BSP_PATTERN   = 16'h1234;
//parameter BSP_PATTERN   = 16'h3fd5;
//parameter BSP_PATTERN   = 16'h2a95;
reg [3:0] next_state;
reg bsp_gen;
reg bsp_cmp;
reg bsp_err;
reg [3:0] bsp_cnt;

wire state_rst = (~bsp_clr) & rst;
always @ (posedge fclk or negedge state_rst)
  if (~state_rst)
  begin
    next_state <= IDLE_STAT;
    bsp_gen    <= BSP_DISENABLE;
    bsp_cnt    <= 1'b0;
    bsp_cmp    <= BSP_DISMATCH;
    bsp_err    <= BSP_NORMAL;
  end
  else
  begin
    bsp_cnt    <= bsp_cnt + 1;
    case(next_state)
    IDLE_STAT : begin
                  if (bsp_start)
                  begin
                    next_state <= BSP1_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  else
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                end
    BSP1_STAT : begin
                  if (bsp_cnt)
                  begin
                    next_state <= next_state;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  else if ((data_in == bsp_pattern0)||(data_in == bsp_pattern1))
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_MATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                  else
                  begin
                    next_state <= BSP2_STAT;
                    bsp_gen    <= BSP_ENABLE;
                    bsp_cmp    <= BSP_DISMATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                end
    BSP2_STAT : begin
                  if (bsp_cnt)
                  begin
                    next_state <= next_state;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  //else if (data_in == bsp_pattern)
                  else if ((data_in == bsp_pattern0)||(data_in == bsp_pattern1))
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_MATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                  else
                  begin
                    next_state <= BSP3_STAT;
                    bsp_gen    <= BSP_ENABLE;
                    bsp_cmp    <= BSP_DISMATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                end
    BSP3_STAT : begin
                  if (bsp_cnt)
                  begin
                    next_state <= next_state;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  //else if (data_in == bsp_pattern)
                  else if ((data_in == bsp_pattern0)||(data_in == bsp_pattern1))
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_MATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                  else
                  begin
                    next_state <= BSP4_STAT;
                    bsp_gen    <= BSP_ENABLE;
                    bsp_cmp    <= BSP_DISMATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                end
    BSP4_STAT : begin
                  if (bsp_cnt)
                  begin
                    next_state <= next_state;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  //else if (data_in == bsp_pattern)
                  else if ((data_in == bsp_pattern0)||(data_in == bsp_pattern1))
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_MATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                  else
                  begin
                    next_state <= BSP5_STAT;
                    bsp_gen    <= BSP_ENABLE;
                    bsp_cmp    <= BSP_DISMATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                end
    BSP5_STAT : begin
                  if (bsp_cnt)
                  begin
                    next_state <= next_state;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  //else if (data_in == bsp_pattern)
                  else if ((data_in == bsp_pattern0)||(data_in == bsp_pattern1))
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_MATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                  else
                  begin
                    next_state <= BSP6_STAT;
                    bsp_gen    <= BSP_ENABLE;
                    bsp_cmp    <= BSP_DISMATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                end
    BSP6_STAT : begin
                  if (bsp_cnt)
                  begin
                    next_state <= next_state;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  //else if (data_in == bsp_pattern)
                  else if ((data_in == bsp_pattern0)||(data_in == bsp_pattern1))
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_MATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                  else
                  begin
                    next_state <= BSP7_STAT;
                    bsp_gen    <= BSP_ENABLE;
                    bsp_cmp    <= BSP_DISMATCH;
                    bsp_err    <= BSP_NORMAL;
                   end
                end
    BSP7_STAT : begin
                  if (bsp_cnt)
                  begin
                    next_state <= next_state;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  //else if (data_in == bsp_pattern)
                  else if ((data_in == bsp_pattern0)||(data_in == bsp_pattern1))
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_MATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                  else
                  begin
                    next_state <= BSP8_STAT;
                    bsp_gen    <= BSP_ENABLE;
                    bsp_cmp    <= BSP_DISMATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                end
    BSP8_STAT : begin
                  if (bsp_cnt)
                  begin
                    next_state <= next_state;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  //else if (data_in == bsp_pattern)
                  else if ((data_in == bsp_pattern0)||(data_in == bsp_pattern1))
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_MATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                  else
                  begin
                    next_state <= BSP9_STAT;
                    bsp_gen    <= BSP_ENABLE;
                    bsp_cmp    <= BSP_DISMATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                end
    BSP9_STAT : begin
                  if (bsp_cnt)
                  begin
                    next_state <= next_state;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= bsp_cmp;
                    bsp_err    <= bsp_err;
                  end
                  //else if (data_in == bsp_pattern)
                  else if ((data_in == bsp_pattern0)||(data_in == bsp_pattern1))
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_MATCH;
                    bsp_err    <= BSP_NORMAL;
                  end
                  else
                  begin
                    next_state <= IDLE_STAT;
                    bsp_gen    <= BSP_DISENABLE;
                    bsp_cmp    <= BSP_DISMATCH;
                    bsp_err    <= BSP_FAULT;
                  end
                end
    default   : begin
                  next_state <= next_state;
                  bsp_gen    <= bsp_gen;
                  bsp_cmp    <= bsp_cmp;
                  bsp_err    <= bsp_err;
                end
    endcase
  end
endmodule

