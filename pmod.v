module pmod (inout P1,inout P10,inout P2,inout P3,inout P4,inout P7,inout P8,inout P9, inout [3:0] pmod_4321,inout [3:0] pmod_a987);
// pin    P1 is IO_L1P_T0_D00_MOSI_14 bank  14 bus_digitizer_J17[6]        B24
// pin    P2 is     IO_L5P_T0_D06_14 bank  14 bus_digitizer_J17[7]        D26
// pin    P3 is     IO_L9P_T1_DQS_14 bank  14 bus_digitizer_J17[4]        E21
// pin    P4 is IO_L15P_T2_DQS_RDWR_B_14 bank  14 bus_digitizer_J17[5]        E25
// pin    P7 is IO_L1N_T0_D01_DIN_14 bank  14 bus_digitizer_J17[2]        A25
// pin    P8 is     IO_L5N_T0_D07_14 bank  14 bus_digitizer_J17[3]        C26
// pin    P9 is IO_L9N_T1_DQS_D13_14 bank  14 bus_digitizer_J17[0]        E22
// pin   P10 is IO_L15N_T2_DQS_DOUT_CSO_B_14 bank  14 bus_digitizer_J17[1]        D25
via pmod1_via(.a(P4),.b(pmod_4321[3]));
via pmod2_via(.a(P3),.b(pmod_4321[2]));
via pmod3_via(.a(P2),.b(pmod_4321[1]));
via pmod4_via(.a(P1),.b(pmod_4321[0]));
via pmod7_via(.a(P10),.b(pmod_a987[3]));
via pmod8_via(.a(P9),.b(pmod_a987[2]));
via pmod9_via(.a(P8),.b(pmod_a987[1]));
via pmoda_via(.a(P7),.b(pmod_a987[0]));
//assign {P1,P2,P3,P4}=pmod_4321;
//assign {P7,P8,P9,P10}=pmod_a987;
endmodule
