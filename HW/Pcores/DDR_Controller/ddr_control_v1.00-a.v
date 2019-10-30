`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Versions: 1.00-a
// Create Date: 10/27/2019 07:05:35 PM
// Design Name: 
// Module Name: ddr_control
// Project Name: ddr_controller
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// added ck_s
module ddr_control(ck_s ODT ,CK ,CK_ ,CKE ,CS_ ,RAS_ ,CAS_ ,WE_ ,A ,AB_s,AB,DQ ,DQS_DQS_m ,RDQS_ ,RDQS ,DM ,com ,data ,add,ACLK,ARESETN,ARADDR,ARVA_ID,ARREADY,RDATA,RRESP,RVALID,RREADY,AWADDR,AWVALID,AWREADY,WDATA,WSTRB,BRESP,BVALID,BREADY);

//////////////////////////DDR2 CONTROLLER SIGNALS

input com[3:0],add[13:0],DM,AB_s[2:0],ck_s; //com,data,add is the suorce input.
//AB_s the bank signal from cpu.

inout  DQ[7:0],data[7:0],DQS_DQS_m,DQS_DQS_s;
output reg ODT,CK,CK_,CKE,CS_,RAS_,CAS_,WE_,A,AB,RDQS_,RDQS;

//////////////////////////AXI4 LITE DIFINE PORTS by refrance(https://www.realdigital.org/doc/a9fee931f7a172423e1ba73f66ca4081)

// Global Signals
input ACLK,ARESETN;

//Read Address Channel
input ARADDR[31:0],ARVALID;
output ARREADY;

//Read Data Channel
input RREADY;
output RDATA[31:0],RRESP,RVALID;

//Write Address Channel
input AWADDR[31:0],AWVALID;
output AWREADY;

//Write Data Channel
input WDATA[31:0],WSTRB[3:0];

//Write Response Channel
input BREADY;
output BRESP,BVALID;



endmodule
