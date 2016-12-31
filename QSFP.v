module QSFP (input IntL
,output LPMode
,input ModPrsL
,output ModSelL
,output ResetL
,input Rx1n
,input Rx1p
,input Rx2n
,input Rx2p
,input Rx3n
,input Rx3p
,input Rx4n
,input Rx4p
,output Tx1n
,output Tx1p
,output Tx2n
,output Tx2p
,output Tx3n
,output Tx3p
,output Tx4n
,output Tx4p

,input [3:0] gtrefclk
,input [3:0] gtrefclkbuf
,input sysclk
,input soft_reset
,input [3:0]  gt_txusrrdy,gt_rxusrrdy
,input [3:0] txusrclk,rxusrclk
,output [3:0] txoutclk,rxoutclk
,input [4*20-1:0] gt_txdata
,output[4*20-1:0] gt_rxdata
,output[3:0] rxbyteisaligned
,input qsfp_resetl
,output qsfp_modprsl
,input qsfp_lpmode
,input qsfp_modsel
);
// pin   SCL is    IO_L21P_T3_DQS_16 bank  16 bus_bmb7_U50[4]        B14
// pin   SDA is        IO_L20P_T3_16 bank  16 bus_bmb7_U50[20]        B12
// pin  IntL is        IO_L20N_T3_16 bank  16 bus_bmb7_U32[13]        B11
// pin  Rx1n is         MGTXRXN2_116 bank 116 bus_bmb7_U32[6]         C3
// pin  Rx1p is         MGTXRXP2_116 bank 116 bus_bmb7_U32[16]         C4
// pin  Rx2n is         MGTXRXN3_116 bank 116 bus_bmb7_U32[2]         B5
// pin  Rx2p is         MGTXRXP3_116 bank 116 bus_bmb7_U32[12]         B6
// pin  Rx3n is         MGTXRXN1_116 bank 116 bus_bmb7_U32[18]         E3
// pin  Rx3p is         MGTXRXP1_116 bank 116 bus_bmb7_U32[1]         E4
// pin  Rx4n is         MGTXRXN0_116 bank 116 bus_bmb7_U32[4]         G3
// pin  Rx4p is         MGTXRXP0_116 bank 116 bus_bmb7_U32[11]         G4
// pin  Tx1n is         MGTXTXN2_116 bank 116 bus_bmb7_U32[15]         B1
// pin  Tx1p is         MGTXTXP2_116 bank 116 bus_bmb7_U32[20]         B2
// pin  Tx2n is         MGTXTXN3_116 bank 116 bus_bmb7_U32[9]         A3
// pin  Tx2p is         MGTXTXP3_116 bank 116 bus_bmb7_U32[8]         A4
// pin  Tx3n is         MGTXTXN1_116 bank 116 bus_bmb7_U32[21]         D1
// pin  Tx3p is         MGTXTXP1_116 bank 116 bus_bmb7_U32[7]         D2
// pin  Tx4n is         MGTXTXN0_116 bank 116 bus_bmb7_U32[14]         F1
// pin  Tx4p is         MGTXTXP0_116 bank 116 bus_bmb7_U32[19]         F2
// pin LPMode is        IO_L23N_T3_16 bank  16 bus_bmb7_U32[10]        A15
// pin ModPrsL is        IO_L23P_T3_16 bank  16 bus_bmb7_U32[3]        B15
// pin ModSelL is    IO_L21N_T3_DQS_16 bank  16 bus_bmb7_U32[17]        A14
// pin ResetL is        IO_L24N_T3_16 bank  16 bus_bmb7_U32[0]        A12
/*assign IntL=0;
assign LPMode=0;
assign ModPrsL=0;
assign ModSelL=0;
assign ResetL=0;
assign SCL=0;
assign SDA=0;
*/

OBUF lpmode_obuf(.I(qsfp_lpmode),.O(LPMode));
OBUF resetl_obuf(.I(qsfp_resetl),.O(ResetL));
OBUF modsel_obuf(.I(qsfp_modsel),.O(ModSelL));
//assign ResetL = qsfp_resetl;//1'b1;
//assign ModPrsL = qsfp_modprsl;//1'b1;
//assign LPMode = qsfp_lpmode;//1'b0;
assign qsfp_modprsl = ModPrsL;  // Module Present bit sent to application

wire [3:0] RXN;
assign RXN={Rx4n,Rx3n,Rx2n,Rx1n};
wire [3:0] RXP;
assign RXP={Rx4p,Rx3p,Rx2p,Rx1p};
wire [3:0] TXN;
assign {Tx4n,Tx3n,Tx2n,Tx1n}=TXN;
wire [3:0] TXP;
assign {Tx4p,Tx3p,Tx2p,Tx1p}=TXP;

gtx #(.CHAN(4))
gtx(.gtrefclk(gtrefclk)
,.gtrefclkbuf(gtrefclkbuf),.RXN(RXN),.RXP(RXP),.TXN(TXN),.TXP(TXP)
,.sysclk(sysclk)
,.soft_reset(soft_reset)
,.txusrclk({txusrclk[3:0]})//,txusrclk[0]})
,.rxusrclk({rxusrclk[3:0]})//,rxusrclk[0]})
,.txoutclk({txoutclk[3:0]})//,txoutclk[0]})
,.rxoutclk({rxoutclk[3:0]})//,rxoutclk[0]})
,.rxbyteisaligned(rxbyteisaligned)
,.gt_txdata(gt_txdata)
,.gt_rxdata(gt_rxdata)
,.gt_txusrrdy_in(gt_txusrrdy)
,.gt_rxusrrdy_in(gt_rxusrrdy)
);

endmodule
