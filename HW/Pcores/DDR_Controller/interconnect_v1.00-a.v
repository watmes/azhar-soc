`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:Ahmed Abd elkader 
// Versions: 1.00-a
// Create Date: 10/27/2019 07:05:35 PM
// Design Name: 
// Module Name: interconnect
// Project Name: interconnect
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

module interconnect
#(parameter 
                ddr=3'b000,
                sd=3'b010,
                ether=3'b011,
                uart=3'b100,
                vga=3'b101,
   		     ps2=3'b110

)
(

input clk,
input [2:0]select,

//----VGA----
//Read Address Channel
output reg [31:0]ARADDR_v,
output reg ARVALID_v,
input ARREADY_v,

//Read Data Channel
output reg RREADY_v,
input [31:0]RDATA_v,
input RRESP_v,RVALID_v,

//Write Address Channel
output reg [31:0]AWADDR_v,
output reg AWVALID_v,
input AWREADY_v,

//Write Data Channel
output reg [31:0] WDATA_v,
output reg  [3:0] WSTRB_v,
output reg  WVALID_v,
input WREADY_v,

//Write Response Channel
output reg BREADY_v,
input  BRESP_v,BVALID_v,

//----ETHRT----
//Read Address Channel
output reg [31:0]ARADDR_e,
output reg ARVALID_e,
input ARREADY_e,

//Read Data Channel
output reg RREADY_e,
input [31:0]RDATA_e,
input RRESP_e,RVALID_e,

//Write Address Channel
output reg [31:0]AWADDR_e,
output reg AWVALID_e,
input AWREADY_e,

//Write Data Channel
output reg [31:0] WDATA_e,
output reg  [3:0] WSTRB_e,
output reg  WVALID_e,
input WREADY_e,

//Write Response Channel
output reg BREADY_e,
input  BRESP_e,BVALID_e,

//----PS2----
//Read Address Channel
output reg [31:0]ARADDR_p,
output reg ARVALID_p,
input ARREADY_p,

//Read Data Channel
output reg RREADY_p,
input [31:0]RDATA_p,
input RRESP_p,RVALID_p,

//Write Address Channel
output reg [31:0]AWADDR_p,
output reg AWVALID_p,
input AWREADY_p,

//Write Data Channel
output reg [31:0] WDATA_p,
output reg  [3:0] WSTRB_p,
output reg  WVALID_p,
input WREADY_p,

//Write Response Channel
output reg BREADY_p,
input  BRESP_p,BVALID_p,

//----UART----
//Read Address Channel
output reg [31:0]ARADDR_u,
output reg ARVALID_u,
input ARREADY_u,

//Read Data Channel
output reg RREADY_u,
input [31:0]RDATA_u,
input RRESP_u,RVALID_u,

//Write Address Channel
output reg [31:0]AWADDR_u,
output reg AWVALID_u,
input AWREADY_u,

//Write Data Channel
output reg [31:0] WDATA_u,
output reg  [3:0] WSTRB_u,
output reg  WVALID_u,
input WREADY_u,

//Write Response Channel
output reg BREADY_u,
input  BRESP_u,BVALID_u,

//---SD-CADR---
//Read Address Channel
output reg [31:0]ARADDR_s,
output reg ARVALID_s,
input ARREADY_s,

//Read Data Channel
output reg RREADY_s,
input [31:0]RDATA_s,
input RRESP_s,RVALID_s,

//Write Address Channel
output reg [31:0]AWADDR_s,
output reg AWVALID_s,
input AWREADY_s,

//Write Data Channel
output reg [31:0] WDATA_s,
output reg  [3:0] WSTRB_s,
output reg  WVALID_s,
input WREADY_s,

//Write Response Channel
output reg BREADY_s,
input  BRESP_s,BVALID_s,

//----DDR----
//Read Address Channel
output reg [31:0]ARADDR_d,
output reg ARVALID_d,
input ARREADY_d,

//Read Data Channel
output reg RREADY_d,
input [31:0]RDATA_d,
input RRESP_d,RVALID_d,

//Write Address Channel
output reg [31:0]AWADDR_d,
output reg AWVALID_d,
input AWREADY_d,

//Write Data Channel
output reg [31:0] WDATA_d,
output reg  [3:0] WSTRB_d,
output reg  WVALID_d,
input WREADY_d,

//Write Response Channel
output reg BREADY_d,
input  BRESP_d,BVALID_d,

//--------------------------------------------------------------------------------

//----Master----
//Read Address Channel
input [31:0]ARADDR_m,
input ARVALID_m,
output reg ARREADY_m,

//Read Data Channel
input RREADY_m,
output reg [31:0]RDATA_m,
output reg RRESP_m,RVALID_m,

//Write Address Channel
input [31:0]AWADDR_m,
input AWVALID_m,
output reg AWREADY_m,

//Write Data Channel
input [31:0] WDATA_m,
input  [3:0] WSTRB_m,
input  WVALID_m,
output reg WREADY_m,

//Write Response Channel
input BREADY_m,
output reg  BRESP_m,BVALID_m

);
always@(posedge clk)
begin
  case(select)
   ddr  : begin
           //Read Address Channel
			ARADDR_d<=ARADDR_m;
			ARVALID_d<=ARVALID_m;
			ARREADY_m<=ARREADY_d;

			//Read Data Channel
			 RREADY_d<=RREADY_m;
            		 RDATA_m<=RDATA_d;
             		 RRESP_m<=RRESP_d;
			 RVALID_m<=RVALID_d;

			//Write Address Channel
			 AWADDR_d<=AWADDR_m;
			 AWVALID_d<=AWVALID_m;
			 AWREADY_m<=AWREADY_d;

			//Write Data Channel
			 WDATA_d<=WDATA_m;
			 WSTRB_d<=WSTRB_m;
			 WVALID_d<=WVALID_m;
			 WREADY_m<=WREADY_d;

			//Write Response Channel
			 BREADY_d<=BREADY_m;
			 BRESP_m<=BRESP_d;
			 BVALID_m<=BVALID_d;
          end
   
   
   sd   : begin
           //Read Address Channel
			ARADDR_s<=ARADDR_m;
			ARVALID_s<=ARVALID_m;
			ARREADY_m<=ARREADY_s;

			//Read Data Channel
			 RREADY_s<=RREADY_m;
             		 RDATA_m<=RDATA_s;
             		 RRESP_m<=RRESP_s;
			 RVALID_m<=RVALID_s;

			//Write Address Channel
			 AWADDR_s<=AWADDR_m;
			 AWVALID_s<=AWVALID_m;
			 AWREADY_m<=AWREADY_s;

			//Write Data Channel
			 WDATA_s<=WDATA_m;
			 WSTRB_s<=WSTRB_m;
			 WVALID_s<=WVALID_m;
			 WREADY_m<=WREADY_s;

			//Write Response Channel
			 BREADY_s<=BREADY_m;
			 BRESP_m<=BRESP_s;
			 BVALID_m<=BVALID_s;
          end
		  
		  
   ether: begin
           //Read Address Channel
			ARADDR_e<=ARADDR_m;
			ARVALID_e<=ARVALID_m;
			ARREADY_m<=ARREADY_e;

			//Read Data Channel
			 RREADY_e<=RREADY_m;
            		 RDATA_m<=RDATA_e;
            		 RRESP_m<=RRESP_e;
			 RVALID_m<=RVALID_e;

			//Write Address Channel
			 AWADDR_e<=AWADDR_m;
			 AWVALID_e<=AWVALID_m;
			 AWREADY_m<=AWREADY_e;

			//Write Data Channel
			 WDATA_e<=WDATA_m;
			 WSTRB_e<=WSTRB_m;
			 WVALID_e<=WVALID_m;
			 WREADY_m<=WREADY_e;

			//Write Response Channel
			 BREADY_e<=BREADY_m;
			 BRESP_m<=BRESP_e;
			 BVALID_m<=BVALID_e;
          end
		  
		  
   uart : begin
           //Read Address Channel
			ARADDR_u<=ARADDR_m;
			ARVALID_u<=ARVALID_m;
			ARREADY_m<=ARREADY_u;

			//Read Data Channel
			 RREADY_u<=RREADY_m;
            		 RDATA_m<=RDATA_u;
             		 RRESP_m<=RRESP_u;
			 RVALID_m<=RVALID_u;

			//Write Address Channel
			 AWADDR_u<=AWADDR_m;
			 AWVALID_u<=AWVALID_m;
			 AWREADY_m<=AWREADY_u;

			//Write Data Channel
			 WDATA_u<=WDATA_m;
			 WSTRB_u<=WSTRB_m;
			 WVALID_u<=WVALID_m;
			 WREADY_m<=WREADY_u;

			//Write Response Channel
			 BREADY_u<=BREADY_m;
			 BRESP_m<=BRESP_u;
			 BVALID_m<=BVALID_u;
          end
		  
		  
   vga  : begin
           //Read Address Channel
			ARADDR_v<=ARADDR_m;
			ARVALID_v<=ARVALID_m;
			ARREADY_m<=ARREADY_v;

			//Read Data Channel
			 RREADY_v<=RREADY_m;
            		 RDATA_m<=RDATA_v;
            		 RRESP_m<=RRESP_v;
			 RVALID_m<=RVALID_v;

			//Write Address Channel
			 AWADDR_v<=AWADDR_m;
			 AWVALID_v<=AWVALID_m;
			 AWREADY_m<=AWREADY_v;

			//Write Data Channel
			 WDATA_v<=WDATA_m;
			 WSTRB_v<=WSTRB_m;
			 WVALID_v<=WVALID_m;
			 WREADY_m<=WREADY_v;

			//Write Response Channel
			 BREADY_v<=BREADY_m;
			 BRESP_m<=BRESP_v;
			 BVALID_m<=BVALID_v;
          end
		  
		  
   ps2  : begin
           //Read Address Channel
			ARADDR_p<=ARADDR_m;
			ARVALID_p<=ARVALID_m;
			ARREADY_m<=ARREADY_p;

			//Read Data Channel
			 RREADY_p<=RREADY_m;
            		 RDATA_m<=RDATA_p;
           	         RRESP_m<=RRESP_p;
			 RVALID_m<=RVALID_p;

			//Write Address Channel
			 AWADDR_p<=AWADDR_m;
			 AWVALID_p<=AWVALID_m;
			 AWREADY_m<=AWREADY_p;

			//Write Data Channel
			 WDATA_p<=WDATA_m;
			 WSTRB_p<=WSTRB_m;
			 WVALID_p<=WVALID_m;
			 WREADY_m<=WREADY_p;

			//Write Response Channel
			 BREADY_p<=BREADY_m;
			 BRESP_m<=BRESP_p;
			 BVALID_m<=BVALID_p;
          end
		  
		  
 
  endcase
 end
endmodule
  