module TPS62110 (inout EN,inout SYNC
,pwr_sync
,pwr_en
);
// pin    EN is         IO_L7N_T1_32 bank  32 bus_digitizer_U33U1[1]       AA15
// pin  SYNC is         IO_L7P_T1_32 bank  32 bus_digitizer_U33U1[0]       AA14
assign SYNC=pwr_sync;
assign EN=pwr_en;
endmodule

