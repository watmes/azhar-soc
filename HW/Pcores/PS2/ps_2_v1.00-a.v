`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Versions: 1.00-a
// Create Date: 10/27/2019 07:05:35 PM
// Design Name: 
// Module Name: ps/2
// Project Name: ps/2
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
module ps_2(

////////////////////////// PS/2  SIGNALS

input data,clk,
output [7:0] da_t_cpu,
output clk_slave,


//////////////////////////AXI4 LITE DIFINE PORTS by refrance(https://www.realdigital.org/doc/a9fee931f7a172423e1ba73f66ca4081)

// Global Signals
input ACLK,ARESETN,

//Read Address Channel
input [31:0]ARADDR,
input ARVALID,
output ARREADY,

//Read Data Channel
input RREADY,
output [31:0]RDATA,
output RRESP,RVALID,

//Write Address Channel
input [31:0]AWADDR,
input AWVALID,
output AWREADY,

//Write Data Channel
input [31:0] WDATA,
input [3:0] WSTRB,

//Write Response Channel
input BREADY,
output BRESP,BVALID
);


endmodule
