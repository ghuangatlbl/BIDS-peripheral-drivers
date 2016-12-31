module fmc_hpc (output HA00_N_CC,output HA00_P_CC,output HA01_N_CC,output HA01_P_CC,output HA02_N,output HA02_P,output HA03_N,output HA03_P,output HA04_N,output HA04_P,output HA05_N,output HA05_P,output HA06_N,output HA06_P,output HA07_N,output HA07_P,output HA08_N,output HA08_P,output HA09_N,output HA09_P,output HA10_N,output HA10_P,output HA11_N,output HA11_P,output HA12_N,output HA12_P,output HA13_N,output HA13_P,output HA14_N,output HA14_P,output HA15_N,output HA15_P,output HA16_N,output HA16_P,output HA17_N_CC,output HA17_P_CC,output HA18_N,output HA18_P,output HA19_N,output HA19_P,output HA20_N,output HA20_P,output HA21_N,output HA21_P,output HA22_N,output HA22_P,output HA23_N,output HA23_P,output HB00_N_CC,output HB00_P_CC,output HB01_N,output HB01_P,output HB02_N,output HB02_P,output HB03_N,output HB03_P,output HB04_N,output HB04_P,output HB05_N,output HB05_P,output HB06_N_CC,output HB06_P_CC,output HB07_N,output HB07_P,output HB08_N,output HB08_P,output HB09_N,output HB09_P,output HB10_N,output HB10_P,output HB11_N,output HB11_P,output HB12_N,output HB12_P,output HB13_N,output HB13_P,output HB14_N,output HB14_P,output HB15_N,output HB15_P,output HB16_N,output HB16_P,output HB17_N_CC,output HB17_P_CC,output HB18_N,output HB18_P,output HB19_N,output HB19_P,output HB20_N,output HB20_P,output HB21_N,output HB21_P,output LA00_N_CC,output LA00_P_CC,output LA01_N_CC,output LA01_P_CC,output LA02_N,output LA02_P,output LA03_N,output LA03_P,output LA04_N,output LA04_P,output LA05_N,output LA05_P,output LA06_N,output LA06_P,output LA07_N,output LA07_P,output LA08_N,output LA08_P,output LA09_N,output LA09_P,output LA10_N,output LA10_P,output LA11_N,output LA11_P,output LA12_N,output LA12_P,output LA13_N,output LA13_P,output LA14_N,output LA14_P,output LA15_N,output LA15_P,output LA16_N,output LA16_P,output LA17_N_CC,output LA17_P_CC,output LA18_N_CC,output LA18_P_CC,output LA19_N,output LA19_P,output LA20_N,output LA20_P,output LA21_N,output LA21_P,output LA22_N,output LA22_P,output LA23_N,output LA23_P,output LA24_N,output LA24_P,output LA25_N,output LA25_P,output LA26_N,output LA26_P,output LA27_N,output LA27_P,output LA28_N,output LA28_P,output LA29_N,output LA29_P,output LA30_N,output LA30_P,output LA31_N,output LA31_P,output LA32_N,output LA32_P,output LA33_N,output LA33_P);
// pin HA00_N_CC is   IO_L12N_T1_MRCC_33 bank  33 bus_bmb7_J103[100]        AD9
// pin HA00_P_CC is   IO_L12P_T1_MRCC_33 bank  33 bus_bmb7_J103[92]        AC9
// pin HA01_N_CC is   IO_L11N_T1_SRCC_33 bank  33 bus_bmb7_J103[90]        AB9
// pin HA01_P_CC is   IO_L11P_T1_SRCC_33 bank  33 bus_bmb7_J103[55]        AA9
// pin HA02_N is     IO_L3N_T0_DQS_33 bank  33 bus_bmb7_J103[1]         W9
// pin HA02_P is     IO_L3P_T0_DQS_33 bank  33 bus_bmb7_J103[46]        W10
// pin HA03_N is         IO_L4N_T0_33 bank  33 bus_bmb7_J103[133]         Y7
// pin HA03_P is         IO_L4P_T0_33 bank  33 bus_bmb7_J103[3]         Y8
// pin HA04_N is         IO_L7N_T1_33 bank  33 bus_bmb7_J103[65]        AF7
// pin HA04_P is         IO_L7P_T1_33 bank  33 bus_bmb7_J103[30]        AE7
// pin HA05_N is         IO_L8N_T1_33 bank  33 bus_bmb7_J103[106]        AA7
// pin HA05_P is         IO_L8P_T1_33 bank  33 bus_bmb7_J103[122]        AA8
// pin HA06_N is        IO_L20N_T3_33 bank  33 bus_bmb7_J103[11]       AE10
// pin HA06_P is        IO_L20P_T3_33 bank  33 bus_bmb7_J103[32]       AD10
// pin HA07_N is        IO_L10N_T1_33 bank  33 bus_bmb7_J103[124]        AC7
// pin HA07_P is        IO_L10P_T1_33 bank  33 bus_bmb7_J103[126]        AB7
// pin HA08_N is     IO_L9N_T1_DQS_33 bank  33 bus_bmb7_J103[159]        AD8
// pin HA08_P is     IO_L9P_T1_DQS_33 bank  33 bus_bmb7_J103[82]        AC8
// pin HA09_N is        IO_L24N_T3_33 bank  33 bus_bmb7_J103[70]        AF9
// pin HA09_P is        IO_L24P_T3_33 bank  33 bus_bmb7_J103[114]       AF10
// pin HA10_N is         IO_L5N_T0_33 bank  33 bus_bmb7_J103[66]        Y10
// pin HA10_P is         IO_L5P_T0_33 bank  33 bus_bmb7_J103[26]        Y11
// pin HA11_N is        IO_L18N_T2_33 bank  33 bus_bmb7_J103[98]        Y12
// pin HA11_P is        IO_L18P_T2_33 bank  33 bus_bmb7_J103[105]        Y13
// pin HA12_N is   IO_L19N_T3_VREF_33 bank  33 bus_bmb7_J103[78]       AE11
// pin HA12_P is        IO_L19P_T3_33 bank  33 bus_bmb7_J103[60]       AD11
// pin HA13_N is        IO_L22N_T3_33 bank  33 bus_bmb7_J103[139]        AF8
// pin HA13_P is        IO_L22P_T3_33 bank  33 bus_bmb7_J103[69]        AE8
// pin HA14_N is        IO_L17N_T2_33 bank  33 bus_bmb7_J103[96]       AD13
// pin HA14_P is        IO_L17P_T2_33 bank  33 bus_bmb7_J103[131]       AC13
// pin HA15_N is        IO_L16N_T2_33 bank  33 bus_bmb7_J103[149]       AA12
// pin HA15_P is        IO_L16P_T2_33 bank  33 bus_bmb7_J103[20]       AA13
// pin HA16_N is    IO_L15N_T2_DQS_33 bank  33 bus_bmb7_J103[19]       AC12
// pin HA16_P is    IO_L15P_T2_DQS_33 bank  33 bus_bmb7_J103[35]       AB12
// pin HA17_N_CC is   IO_L13N_T2_MRCC_33 bank  33 bus_bmb7_J103[128]       AC11
// pin HA17_P_CC is   IO_L13P_T2_MRCC_33 bank  33 bus_bmb7_J103[143]       AB11
// pin HA18_N is   IO_L14N_T2_SRCC_33 bank  33 bus_bmb7_J103[27]       AB10
// pin HA18_P is   IO_L14P_T2_SRCC_33 bank  33 bus_bmb7_J103[64]       AA10
// pin HA19_N is        IO_L23N_T3_33 bank  33 bus_bmb7_J103[148]       AF13
// pin HA19_P is        IO_L23P_T3_33 bank  33 bus_bmb7_J103[125]       AE13
// pin HA20_N is    IO_L21N_T3_DQS_33 bank  33 bus_bmb7_J103[138]       AF12
// pin HA20_P is    IO_L21P_T3_DQS_33 bank  33 bus_bmb7_J103[68]       AE12
// pin HA21_N is         IO_L1N_T0_33 bank  33 bus_bmb7_J103[13]        W11
// pin HA21_P is         IO_L1P_T0_33 bank  33 bus_bmb7_J103[91]        V11
// pin HA22_N is    IO_L6N_T0_VREF_33 bank  33 bus_bmb7_J103[152]         W8
// pin HA22_P is         IO_L6P_T0_33 bank  33 bus_bmb7_J103[31]         V9
// pin HA23_N is         IO_L2N_T0_33 bank  33 bus_bmb7_J103[140]         V7
// pin HA23_P is         IO_L2P_T0_33 bank  33 bus_bmb7_J103[44]         V8
// pin HB00_N_CC is   IO_L13N_T2_MRCC_12 bank  12 bus_bmb7_J103[36]       AA22
// pin HB00_P_CC is   IO_L13P_T2_MRCC_12 bank  12 bus_bmb7_J103[113]        Y22
// pin HB01_N is   IO_L19N_T3_VREF_12 bank  12 bus_bmb7_J103[14]       AE21
// pin HB01_P is        IO_L19P_T3_12 bank  12 bus_bmb7_J103[25]       AD21
// pin HB02_N is    IO_L6N_T0_VREF_12 bank  12 bus_bmb7_J103[43]        W21
// pin HB02_P is         IO_L6P_T0_12 bank  12 bus_bmb7_J103[110]        V21
// pin HB03_N is         IO_L1N_T0_12 bank  12 bus_bmb7_J103[17]        V22
// pin HB03_P is         IO_L1P_T0_12 bank  12 bus_bmb7_J103[88]        U22
// pin HB04_N is        IO_L22N_T3_12 bank  12 bus_bmb7_J103[53]       AF23
// pin HB04_P is        IO_L22P_T3_12 bank  12 bus_bmb7_J103[15]       AE23
// pin HB05_N is        IO_L24N_T3_12 bank  12 bus_bmb7_J103[135]       AF22
// pin HB05_P is        IO_L24P_T3_12 bank  12 bus_bmb7_J103[112]       AE22
// pin HB06_N_CC is   IO_L14N_T2_SRCC_12 bank  12 bus_bmb7_J103[150]       AC24
// pin HB06_P_CC is   IO_L14P_T2_SRCC_12 bank  12 bus_bmb7_J103[54]       AC23
// pin HB07_N is        IO_L17N_T2_12 bank  12 bus_bmb7_J103[123]       AC22
// pin HB07_P is        IO_L17P_T2_12 bank  12 bus_bmb7_J103[59]       AB22
// pin HB08_N is        IO_L18N_T2_12 bank  12 bus_bmb7_J103[103]       AC21
// pin HB08_P is        IO_L18P_T2_12 bank  12 bus_bmb7_J103[141]       AB21
// pin HB09_N is        IO_L16N_T2_12 bank  12 bus_bmb7_J103[48]       AD24
// pin HB09_P is        IO_L16P_T2_12 bank  12 bus_bmb7_J103[33]       AD23
// pin HB10_N is        IO_L20N_T3_12 bank  12 bus_bmb7_J103[6]       AF25
// pin HB10_P is        IO_L20P_T3_12 bank  12 bus_bmb7_J103[77]       AF24
// pin HB11_N is         IO_L8N_T1_12 bank  12 bus_bmb7_J103[49]        W24
// pin HB11_P is         IO_L8P_T1_12 bank  12 bus_bmb7_J103[37]        W23
// pin HB12_N is         IO_L2N_T0_12 bank  12 bus_bmb7_J103[116]        U25
// pin HB12_P is         IO_L2P_T0_12 bank  12 bus_bmb7_J103[2]        U24
// pin HB13_N is        IO_L10N_T1_12 bank  12 bus_bmb7_J103[127]        Y26
// pin HB13_P is        IO_L10P_T1_12 bank  12 bus_bmb7_J103[61]        Y25
// pin HB14_N is    IO_L21N_T3_DQS_12 bank  12 bus_bmb7_J103[38]       AE26
// pin HB14_P is    IO_L21P_T3_DQS_12 bank  12 bus_bmb7_J103[151]       AD26
// pin HB15_N is        IO_L23N_T3_12 bank  12 bus_bmb7_J103[62]       AE25
// pin HB15_P is        IO_L23P_T3_12 bank  12 bus_bmb7_J103[107]       AD25
// pin HB16_N is     IO_L9N_T1_DQS_12 bank  12 bus_bmb7_J103[104]       AC26
// pin HB16_P is     IO_L9P_T1_DQS_12 bank  12 bus_bmb7_J103[10]       AB26
// pin HB17_N_CC is   IO_L12N_T1_MRCC_12 bank  12 bus_bmb7_J103[72]       AA24
// pin HB17_P_CC is   IO_L12P_T1_MRCC_12 bank  12 bus_bmb7_J103[129]        Y23
// pin HB18_N is         IO_L4N_T0_12 bank  12 bus_bmb7_J103[115]        V26
// pin HB18_P is         IO_L4P_T0_12 bank  12 bus_bmb7_J103[86]        U26
// pin HB19_N is         IO_L7N_T1_12 bank  12 bus_bmb7_J103[99]       AB25
// pin HB19_P is         IO_L7P_T1_12 bank  12 bus_bmb7_J103[147]       AA25
// pin HB20_N is         IO_L5N_T0_12 bank  12 bus_bmb7_J103[47]        W26
// pin HB20_P is         IO_L5P_T0_12 bank  12 bus_bmb7_J103[22]        W25
// pin HB21_N is     IO_L3N_T0_DQS_12 bank  12 bus_bmb7_J103[75]        V24
// pin HB21_P is     IO_L3P_T0_DQS_12 bank  12 bus_bmb7_J103[157]        V23
// pin LA00_N_CC is   IO_L12N_T1_MRCC_34 bank  34 bus_bmb7_J103[52]        AA2
// pin LA00_P_CC is   IO_L12P_T1_MRCC_34 bank  34 bus_bmb7_J103[39]        AA3
// pin LA01_N_CC is   IO_L13N_T2_MRCC_34 bank  34 bus_bmb7_J103[102]        AB4
// pin LA01_P_CC is   IO_L13P_T2_MRCC_34 bank  34 bus_bmb7_J103[28]        AA4
// pin LA02_N is        IO_L20N_T3_34 bank  34 bus_bmb7_J103[153]        AE1
// pin LA02_P is        IO_L20P_T3_34 bank  34 bus_bmb7_J103[16]        AD1
// pin LA03_N is    IO_L21N_T3_DQS_34 bank  34 bus_bmb7_J103[109]        AF4
// pin LA03_P is    IO_L21P_T3_DQS_34 bank  34 bus_bmb7_J103[132]        AF5
// pin LA04_N is         IO_L8N_T1_34 bank  34 bus_bmb7_J103[121]         V1
// pin LA04_P is         IO_L8P_T1_34 bank  34 bus_bmb7_J103[8]         V2
// pin LA05_N is     IO_L9N_T1_DQS_34 bank  34 bus_bmb7_J103[97]        AC1
// pin LA05_P is     IO_L9P_T1_DQS_34 bank  34 bus_bmb7_J103[144]        AB1
// pin LA06_N is        IO_L16N_T2_34 bank  34 bus_bmb7_J103[83]        AC6
// pin LA06_P is        IO_L16P_T2_34 bank  34 bus_bmb7_J103[76]        AB6
// pin LA07_N is        IO_L10N_T1_34 bank  34 bus_bmb7_J103[154]         Y1
// pin LA07_P is        IO_L10P_T1_34 bank  34 bus_bmb7_J103[130]         W1
// pin LA08_N is         IO_L7N_T1_34 bank  34 bus_bmb7_J103[45]         Y2
// pin LA08_P is         IO_L7P_T1_34 bank  34 bus_bmb7_J103[137]         Y3
// pin LA09_N is        IO_L23N_T3_34 bank  34 bus_bmb7_J103[93]        AE5
// pin LA09_P is        IO_L23P_T3_34 bank  34 bus_bmb7_J103[12]        AE6
// pin LA10_N is   IO_L14N_T2_SRCC_34 bank  34 bus_bmb7_J103[145]        AC3
// pin LA10_P is   IO_L14P_T2_SRCC_34 bank  34 bus_bmb7_J103[120]        AC4
// pin LA11_N is    IO_L6N_T0_VREF_34 bank  34 bus_bmb7_J103[58]         W4
// pin LA11_P is         IO_L6P_T0_34 bank  34 bus_bmb7_J103[81]         V4
// pin LA12_N is        IO_L24N_T3_34 bank  34 bus_bmb7_J103[95]        AF2
// pin LA12_P is        IO_L24P_T3_34 bank  34 bus_bmb7_J103[119]        AF3
// pin LA13_N is     IO_L3N_T0_DQS_34 bank  34 bus_bmb7_J103[158]         W5
// pin LA13_P is     IO_L3P_T0_DQS_34 bank  34 bus_bmb7_J103[56]         W6
// pin LA14_N is         IO_L2N_T0_34 bank  34 bus_bmb7_J103[71]         U1
// pin LA14_P is         IO_L2P_T0_34 bank  34 bus_bmb7_J103[117]         U2
// pin LA15_N is   IO_L11N_T1_SRCC_34 bank  34 bus_bmb7_J103[18]        AC2
// pin LA15_P is   IO_L11P_T1_SRCC_34 bank  34 bus_bmb7_J103[41]        AB2
// pin LA16_N is        IO_L17N_T2_34 bank  34 bus_bmb7_J103[42]         Y5
// pin LA16_P is        IO_L17P_T2_34 bank  34 bus_bmb7_J103[156]         Y6
// pin LA17_N_CC is   IO_L12N_T1_MRCC_32 bank  32 bus_bmb7_J103[108]       AC16
// pin LA17_P_CC is   IO_L12P_T1_MRCC_32 bank  32 bus_bmb7_J103[9]       AB16
// pin LA18_N_CC is   IO_L13N_T2_MRCC_32 bank  32 bus_bmb7_J103[50]       AD18
// pin LA18_P_CC is   IO_L13P_T2_MRCC_32 bank  32 bus_bmb7_J103[74]       AC18
// pin LA19_N is         IO_L2N_T0_32 bank  32 bus_bmb7_J103[155]       AF15
// pin LA19_P is         IO_L2P_T0_32 bank  32 bus_bmb7_J103[23]       AF14
// pin LA20_N is   IO_L19N_T3_VREF_32 bank  32 bus_bmb7_J103[111]        Y18
// pin LA20_P is        IO_L19P_T3_32 bank  32 bus_bmb7_J103[134]        Y17
// pin LA21_N is         IO_L8N_T1_32 bank  32 bus_bmb7_J103[5]       AD14
// pin LA21_P is         IO_L8P_T1_32 bank  32 bus_bmb7_J103[87]       AC14
// pin LA22_N is         IO_L5N_T0_32 bank  32 bus_bmb7_J103[29]       AF20
// pin LA22_P is         IO_L5P_T0_32 bank  32 bus_bmb7_J103[142]       AF19
// pin LA23_N is         IO_L4N_T0_32 bank  32 bus_bmb7_J103[146]       AE15
// pin LA23_P is         IO_L4P_T0_32 bank  32 bus_bmb7_J103[7]       AD15
// pin LA24_N is        IO_L18N_T2_32 bank  32 bus_bmb7_J103[80]       AB20
// pin LA24_P is        IO_L18P_T2_32 bank  32 bus_bmb7_J103[21]       AB19
// pin LA25_N is    IO_L15N_T2_DQS_32 bank  32 bus_bmb7_J103[34]       AE20
// pin LA25_P is    IO_L15P_T2_DQS_32 bank  32 bus_bmb7_J103[57]       AD20
// pin LA26_N is         IO_L1N_T0_32 bank  32 bus_bmb7_J103[79]       AF17
// pin LA26_P is         IO_L1P_T0_32 bank  32 bus_bmb7_J103[89]       AE17
// pin LA27_N is         IO_L7N_T1_32 bank  32 bus_bmb7_J103[84]       AA15
// pin LA27_P is         IO_L7P_T1_32 bank  32 bus_bmb7_J103[4]       AA14
// pin LA28_N is     IO_L9N_T1_DQS_32 bank  32 bus_bmb7_J103[136]        Y16
// pin LA28_P is     IO_L9P_T1_DQS_32 bank  32 bus_bmb7_J103[101]        Y15
// pin LA29_N is        IO_L16N_T2_32 bank  32 bus_bmb7_J103[24]       AA20
// pin LA29_P is        IO_L16P_T2_32 bank  32 bus_bmb7_J103[0]       AA19
// pin LA30_N is        IO_L22N_T3_32 bank  32 bus_bmb7_J103[118]        W16
// pin LA30_P is        IO_L22P_T3_32 bank  32 bus_bmb7_J103[67]        W15
// pin LA31_N is        IO_L24N_T3_32 bank  32 bus_bmb7_J103[85]        W14
// pin LA31_P is        IO_L24P_T3_32 bank  32 bus_bmb7_J103[94]        V14
// pin LA32_N is        IO_L20N_T3_32 bank  32 bus_bmb7_J103[63]        V17
// pin LA32_P is        IO_L20P_T3_32 bank  32 bus_bmb7_J103[73]        V16
// pin LA33_N is        IO_L23N_T3_32 bank  32 bus_bmb7_J103[40]        V19
// pin LA33_P is        IO_L23P_T3_32 bank  32 bus_bmb7_J103[51]        V18
assign HA00_N_CC=0;
assign HA00_P_CC=0;
assign HA01_N_CC=0;
assign HA01_P_CC=0;
assign HA02_N=0;
assign HA02_P=0;
assign HA03_N=0;
assign HA03_P=0;
assign HA04_N=0;
assign HA04_P=0;
assign HA05_N=0;
assign HA05_P=0;
assign HA06_N=0;
assign HA06_P=0;
assign HA07_N=0;
assign HA07_P=0;
assign HA08_N=0;
assign HA08_P=0;
assign HA09_N=0;
assign HA09_P=0;
assign HA10_N=0;
assign HA10_P=0;
assign HA11_N=0;
assign HA11_P=0;
assign HA12_N=0;
assign HA12_P=0;
assign HA13_N=0;
assign HA13_P=0;
assign HA14_N=0;
assign HA14_P=0;
assign HA15_N=0;
assign HA15_P=0;
assign HA16_N=0;
assign HA16_P=0;
assign HA17_N_CC=0;
assign HA17_P_CC=0;
assign HA18_N=0;
assign HA18_P=0;
assign HA19_N=0;
assign HA19_P=0;
assign HA20_N=0;
assign HA20_P=0;
assign HA21_N=0;
assign HA21_P=0;
assign HA22_N=0;
assign HA22_P=0;
assign HA23_N=0;
assign HA23_P=0;
assign HB00_N_CC=0;
assign HB00_P_CC=0;
assign HB01_N=0;
assign HB01_P=0;
assign HB02_N=0;
assign HB02_P=0;
assign HB03_N=0;
assign HB03_P=0;
assign HB04_N=0;
assign HB04_P=0;
assign HB05_N=0;
assign HB05_P=0;
assign HB06_N_CC=0;
assign HB06_P_CC=0;
assign HB07_N=0;
assign HB07_P=0;
assign HB08_N=0;
assign HB08_P=0;
assign HB09_N=0;
assign HB09_P=0;
assign HB10_N=0;
assign HB10_P=0;
assign HB11_N=0;
assign HB11_P=0;
assign HB12_N=0;
assign HB12_P=0;
assign HB13_N=0;
assign HB13_P=0;
assign HB14_N=0;
assign HB14_P=0;
assign HB15_N=0;
assign HB15_P=0;
assign HB16_N=0;
assign HB16_P=0;
assign HB17_N_CC=0;
assign HB17_P_CC=0;
assign HB18_N=0;
assign HB18_P=0;
assign HB19_N=0;
assign HB19_P=0;
assign HB20_N=0;
assign HB20_P=0;
assign HB21_N=0;
assign HB21_P=0;
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
