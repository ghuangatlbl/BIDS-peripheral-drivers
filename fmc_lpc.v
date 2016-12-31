module fmc_lpc (output LA00_N_CC,output LA00_P_CC,output LA01_N_CC,output LA01_P_CC,output LA02_N,output LA02_P,output LA03_N,output LA03_P,output LA04_N,output LA04_P,output LA05_N,output LA05_P,output LA06_N,output LA06_P,output LA07_N,output LA07_P,output LA08_N,output LA08_P,output LA09_N,output LA09_P,output LA10_N,output LA10_P,output LA11_N,output LA11_P,output LA12_N,output LA12_P,output LA13_N,output LA13_P,output LA14_N,output LA14_P,output LA15_N,output LA15_P,output LA16_N,output LA16_P,output LA17_N_CC,output LA17_P_CC,output LA18_N_CC,output LA18_P_CC,output LA19_N,output LA19_P,output LA20_N,output LA20_P,output LA21_N,output LA21_P,output LA22_N,output LA22_P,output LA23_N,output LA23_P,output LA24_N,output LA24_P,output LA25_N,output LA25_P,output LA26_N,output LA26_P,output LA27_N,output LA27_P,output LA28_N,output LA28_P,output LA29_N,output LA29_P,output LA30_N,output LA30_P,output LA31_N,output LA31_P,output LA32_N,output LA32_P,output LA33_N,output LA33_P);
// pin LA00_N_CC is   IO_L13N_T2_MRCC_13 bank  13 bus_bmb7_J106[29]        P21
// pin LA00_P_CC is   IO_L13P_T2_MRCC_13 bank  13 bus_bmb7_J106[50]        R21
// pin LA01_N_CC is   IO_L12N_T1_MRCC_13 bank  13 bus_bmb7_J106[58]        N22
// pin LA01_P_CC is   IO_L12P_T1_MRCC_13 bank  13 bus_bmb7_J106[30]        N21
// pin LA02_N is    IO_L6N_T0_VREF_13 bank  13 bus_bmb7_J106[67]        P25
// pin LA02_P is         IO_L6P_T0_13 bank  13 bus_bmb7_J106[21]        R25
// pin LA03_N is         IO_L2N_T0_13 bank  13 bus_bmb7_J106[31]        P26
// pin LA03_P is         IO_L2P_T0_13 bank  13 bus_bmb7_J106[37]        R26
// pin LA04_N is        IO_L18N_T2_13 bank  13 bus_bmb7_J106[6]        U20
// pin LA04_P is        IO_L18P_T2_13 bank  13 bus_bmb7_J106[59]        U19
// pin LA05_N is        IO_L16N_T2_13 bank  13 bus_bmb7_J106[53]        R20
// pin LA05_P is        IO_L16P_T2_13 bank  13 bus_bmb7_J106[62]        T20
// pin LA06_N is         IO_L5N_T0_13 bank  13 bus_bmb7_J106[8]        M26
// pin LA06_P is         IO_L5P_T0_13 bank  13 bus_bmb7_J106[65]        N26
// pin LA07_N is   IO_L11N_T1_SRCC_13 bank  13 bus_bmb7_J106[64]        N23
// pin LA07_P is   IO_L11P_T1_SRCC_13 bank  13 bus_bmb7_J106[38]        P23
// pin LA08_N is        IO_L17N_T2_13 bank  13 bus_bmb7_J106[26]        T23
// pin LA08_P is        IO_L17P_T2_13 bank  13 bus_bmb7_J106[17]        T22
// pin LA09_N is         IO_L4N_T0_13 bank  13 bus_bmb7_J106[35]        N24
// pin LA09_P is         IO_L4P_T0_13 bank  13 bus_bmb7_J106[7]        P24
// pin LA10_N is     IO_L9N_T1_DQS_13 bank  13 bus_bmb7_J106[44]        P20
// pin LA10_P is     IO_L9P_T1_DQS_13 bank  13 bus_bmb7_J106[24]        P19
// pin LA11_N is        IO_L10N_T1_13 bank  13 bus_bmb7_J106[51]        M22
// pin LA11_P is        IO_L10P_T1_13 bank  13 bus_bmb7_J106[47]        M21
// pin LA12_N is        IO_L24N_T3_13 bank  13 bus_bmb7_J106[63]        P18
// pin LA12_P is        IO_L24P_T3_13 bank  13 bus_bmb7_J106[15]        R18
// pin LA13_N is         IO_L1N_T0_13 bank  13 bus_bmb7_J106[42]        K26
// pin LA13_P is         IO_L1P_T0_13 bank  13 bus_bmb7_J106[36]        K25
// pin LA14_N is        IO_L23N_T3_13 bank  13 bus_bmb7_J106[28]        T17
// pin LA14_P is        IO_L23P_T3_13 bank  13 bus_bmb7_J106[61]        U17
// pin LA15_N is         IO_L8N_T1_13 bank  13 bus_bmb7_J106[16]        L24
// pin LA15_P is         IO_L8P_T1_13 bank  13 bus_bmb7_J106[33]        M24
// pin LA16_N is     IO_L3N_T0_DQS_13 bank  13 bus_bmb7_J106[52]        L25
// pin LA16_P is     IO_L3P_T0_DQS_13 bank  13 bus_bmb7_J106[12]        M25
// pin LA17_N_CC is   IO_L12N_T1_MRCC_14 bank  14 bus_bmb7_J106[4]        E23
// pin LA17_P_CC is   IO_L12P_T1_MRCC_14 bank  14 bus_bmb7_J106[27]        F22
// pin LA18_N_CC is   IO_L13N_T2_MRCC_14 bank  14 bus_bmb7_J106[19]        F23
// pin LA18_P_CC is   IO_L13P_T2_MRCC_14 bank  14 bus_bmb7_J106[0]        G22
// pin LA19_N is IO_L16N_T2_A15_D31_14 bank  14 bus_bmb7_J106[22]        G26
// pin LA19_P is  IO_L16P_T2_CSI_B_14 bank  14 bus_bmb7_J106[46]        G25
// pin LA20_N is IO_L18N_T2_A11_D27_14 bank  14 bus_bmb7_J106[45]        H26
// pin LA20_P is IO_L18P_T2_A12_D28_14 bank  14 bus_bmb7_J106[34]        J26
// pin LA21_N is IO_L19N_T3_A09_D25_VREF_14 bank  14 bus_bmb7_J106[60]        G21
// pin LA21_P is IO_L19P_T3_A10_D26_14 bank  14 bus_bmb7_J106[13]        H21
// pin LA22_N is IO_L20N_T3_A07_D23_14 bank  14 bus_bmb7_J106[11]        H24
// pin LA22_P is IO_L20P_T3_A08_D24_14 bank  14 bus_bmb7_J106[3]        H23
// pin LA23_N is   IO_L14N_T2_SRCC_14 bank  14 bus_bmb7_J106[57]        F24
// pin LA23_P is   IO_L14P_T2_SRCC_14 bank  14 bus_bmb7_J106[32]        G24
// pin LA24_N is IO_L6N_T0_D08_VREF_14 bank  14 bus_bmb7_J106[48]        C24
// pin LA24_P is   IO_L6P_T0_FCS_B_14 bank  14 bus_bmb7_J106[40]        C23
// pin LA25_N is     IO_L5N_T0_D07_14 bank  14 bus_bmb7_J106[14]        C26
// pin LA25_P is     IO_L5P_T0_D06_14 bank  14 bus_bmb7_J106[5]        D26
// pin LA26_N is IO_L15N_T2_DQS_DOUT_CSO_B_14 bank  14 bus_bmb7_J106[20]        D25
// pin LA26_P is IO_L15P_T2_DQS_RDWR_B_14 bank  14 bus_bmb7_J106[2]        E25
// pin LA27_N is IO_L9N_T1_DQS_D13_14 bank  14 bus_bmb7_J106[39]        E22
// pin LA27_P is     IO_L9P_T1_DQS_14 bank  14 bus_bmb7_J106[54]        E21
// pin LA28_N is     IO_L4N_T0_D05_14 bank  14 bus_bmb7_J106[55]        A24
// pin LA28_P is     IO_L4P_T0_D04_14 bank  14 bus_bmb7_J106[25]        A23
// pin LA29_N is IO_L1N_T0_D01_DIN_14 bank  14 bus_bmb7_J106[66]        A25
// pin LA29_P is IO_L1P_T0_D00_MOSI_14 bank  14 bus_bmb7_J106[18]        B24
// pin LA30_N is     IO_L2N_T0_D03_14 bank  14 bus_bmb7_J106[56]        A22
// pin LA30_P is     IO_L2P_T0_D02_14 bank  14 bus_bmb7_J106[43]        B22
// pin LA31_N is     IO_L7N_T1_D10_14 bank  14 bus_bmb7_J106[49]        C22
// pin LA31_P is     IO_L7P_T1_D09_14 bank  14 bus_bmb7_J106[23]        D21
// pin LA32_N is     IO_L8N_T1_D12_14 bank  14 bus_bmb7_J106[9]        A20
// pin LA32_P is     IO_L8P_T1_D11_14 bank  14 bus_bmb7_J106[10]        B20
// pin LA33_N is    IO_L10N_T1_D15_14 bank  14 bus_bmb7_J106[1]        B21
// pin LA33_P is    IO_L10P_T1_D14_14 bank  14 bus_bmb7_J106[41]        C21
assign LA00_N_CC=0;
assign LA00_P_CC=0;
assign LA01_N_CC=0;
assign LA01_P_CC=0;
assign LA02_N=0;
assign LA02_P=0;
assign LA03_N=0;
assign LA03_P=0;
assign LA04_N=0;
assign LA04_P=0;
assign LA05_N=0;
assign LA05_P=0;
assign LA06_N=0;
assign LA06_P=0;
assign LA07_N=0;
assign LA07_P=0;
assign LA08_N=0;
assign LA08_P=0;
assign LA09_N=0;
assign LA09_P=0;
assign LA10_N=0;
assign LA10_P=0;
assign LA11_N=0;
assign LA11_P=0;
assign LA12_N=0;
assign LA12_P=0;
assign LA13_N=0;
assign LA13_P=0;
assign LA14_N=0;
assign LA14_P=0;
assign LA15_N=0;
assign LA15_P=0;
assign LA16_N=0;
assign LA16_P=0;
assign LA17_N_CC=0;
assign LA17_P_CC=0;
assign LA18_N_CC=0;
assign LA18_P_CC=0;
assign LA19_N=0;
assign LA19_P=0;
assign LA20_N=0;
assign LA20_P=0;
assign LA21_N=0;
assign LA21_P=0;
assign LA22_N=0;
assign LA22_P=0;
assign LA23_N=0;
assign LA23_P=0;
assign LA24_N=0;
assign LA24_P=0;
assign LA25_N=0;
assign LA25_P=0;
assign LA26_N=0;
assign LA26_P=0;
assign LA27_N=0;
assign LA27_P=0;
assign LA28_N=0;
assign LA28_P=0;
assign LA29_N=0;
assign LA29_P=0;
assign LA30_N=0;
assign LA30_P=0;
assign LA31_N=0;
assign LA31_P=0;
assign LA32_N=0;
assign LA32_P=0;
assign LA33_N=0;
assign LA33_P=0;

endmodule
