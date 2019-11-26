`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// Versions: 1.00-a
// Create Date: 10/27/2019 07:05:35 PM
// Design Name: 
// Module Name: AXI4 LITE
// Project Name: AXI4 LITE
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
module AXI4_LITE(
inout [31:0]data,   //data from rx to file register
output reg wr_en,rd_en,
output reg [31:0]add,

// Global Signals
input ACLK,ARESETN,

//Read Address Channel
input [31:0]ARADDR,
input ARVALID,
output reg ARREADY,

//Read Data Channel
input RREADY,
output reg [31:0]RDATA,
output reg RRESP,RVALID,

//Write Address Channel
input [31:0]AWADDR,
input AWVALID,
output reg AWREADY,

//Write Data Channel
input [31:0] WDATA,
input [3:0] WSTRB,
input WVALID,
output reg WREADY,

//Write Response Channel
input BREADY,
output reg BRESP,BVALID
);
reg [31:0]data1;
assign data=data1;
//--------------------------------------------------------------
always@(posedge ACLK)
begin
//---Rest
 if(ARESETN==0)
 begin
  wr_en<=0;
  rd_en<=0;
  add<=32'b0;
  ARREADY<=0;
  RDATA<=32'b0;
  RRESP<=0;
  RVALID<=0;
  AWREADY<=0;
  BRESP<=0;
  BVALID<=0;
  WREADY<=0;
  data1<=32'b0;
 end

//---READ Transaction
 else if(ARVALID)
 begin
  add<=ARADDR;
  ARREADY<=0;
  rd_en<=1;
  wr_en<=0;
  RDATA<=data;
  if(RDATA&&RREADY)
  begin
   RVALID<=1;
   ARREADY<=1;
  end
end

//---WRITE Transaction
else if(AWVALID&&BREADY&&WVALID)
begin
 add<=ARADDR;
 wr_en<=1;
 rd_en<=0;
 case(WSTRB)
  4'b0000: data1<=32'b0;
  4'b0001: data1<=WDATA[7:0];
  4'b0010: data1<=WDATA[15:8];
  4'b0011: data1<=WDATA[15:0];
  4'b0100: data1<=WDATA[23:16];
  4'b0101: data1<={8'b0,WDATA[23:16],8'b0,WDATA[7:0]};
  4'b0110: data1<={8'b0,WDATA[23:16],WDATA[15:8],8'b0};
  4'b0111: data1<={8'b0,WDATA[23:16],WDATA[15:8],WDATA[7:0]};
  4'b1000: data1<={WDATA[31:24],8'b0,8'b0,8'b0};
  4'b1001: data1<={WDATA[31:24],8'b0,8'b0,WDATA[7:0]};
  4'b1010: data1<={WDATA[31:24],8'b0,WDATA[15:8],8'b0};
  4'b1011: data1<={WDATA[31:24],8'b0,WDATA[15:8],WDATA[7:0]};
  4'b1111: data1<=WDATA;
 endcase 
 if((AWVALID||WVALID)&&BREADY==0)
 begin
  BVALID<=1;
 end
end
//--------------------------------
else 
begin
  wr_en<=wr_en;
  rd_en<=rd_en;
  add<=add;
  ARREADY<=ARREADY;
  RDATA<=RDATA;
  RRESP<=RRESP;
  RVALID<=RVALID;
  AWREADY<=AWREADY;
  BRESP<=BRESP;
  BVALID<=BVALID;
  WREADY<=WREADY;
end
end

endmodule


