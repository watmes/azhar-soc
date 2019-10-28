`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26/10/2019 
// Version : V1.00 - b
// Design Name: 
// Module Name: Ethernet_MAC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Ethernet module contains two main blocks :
//              physical layer block and media access control (MAC) 
//
//             (MAC) has interfaces with => 1- PHY module by (MII interface)
//                                            2- Soc AXI BUS  by (AXI4-Lite)
//                                            3- direct memory address (DMA) by (AXI4-Stream) 
// Dependencies: 
// 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Ethernet_MAC  #(parameter data_width = 32)
(
 //interface with Ethernet PHY module with MII interface
 input [3:0] phy_rx_data,    //recieved nipple from PHY
 input phy_rx_DV,
 input phy_rx_en,
 input phy_rx_clk,
 
 output [3:0] phy_tx_data,   //transmitted nipple from PHY
 output phy_tx_DV,
 output phy_tx_en,
 input phy_tx_clk,
 
 output phy_MDC,         // MDIO interface
 output phy_MDIO,
 output phy_rst,         //reset
 
 ////////       AXI_lite interface /////////
 ////////       (Slave Block)      /////////
 //Write Address
 input AWvalid,
 input AWready,
 input [31:0] AWaddr,
 input  [2:0] AWprot,
 
 //Write Data Channel
 input Wvalid,
 input Wready,
 input [data_width-1 : 0] Wdata,
 input [data_width/8 -1 : 0] Wstrb,
 
 //Write response
 output Bvalid,
 output Bready,
 output [1:0] Bresp,
 
 //Read Address
 input ARvalid,
 input ARready,
 input [31:0] ARaddr,
 input [2:0] ARprot,
 
 //Read Data Channel
 output Rvalid,
 output Rready,
 output [data_width-1 : 0]Rdata,
 output [1:0] Rresp,
 
 //////////////      AXI_STREAM   /////////////////
//////////////       (MASTER)     ////////////////
  input  Aclk,
  input  Areset,
  output TVALID,
  
  inout [data_width -1 : 0]   Tdata,  
  inout [data_width/8 -1 : 0] Tstrb, /* TSTRB indicates whether the content of the associated byte of TDATA
                                        is processed as a data byte or a position byte*/
  
  inout [data_width/8 -1 : 0] Tkeep, /* TKEEP is the byte qualifier that indicates whether the content
                                        of the associated byte of TDATA is processed as part of the data stream.
                                      */
  inout Tlast                       // TLAST indicates the boundary of a packet.
  
    );
    
    
    
    
    
endmodule
