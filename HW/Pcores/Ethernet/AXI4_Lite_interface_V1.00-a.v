`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Author: Ashraf Ahmed Abdallah 
// Create Date: 28/11/2019
// Design Name: 
// Module Name: AXI4_Lite_interface 
// Description:   Design AXI4_LITE interface MASTER block to connect between AXI4
//                bus and IP core
// Revision:
// Revision 1.01 - File Created
// Additional Comments: 
//////////////////////////////////////////////////////////////////////////////////
module AXI4_Lite_interface 
#(parameter data_width = 32,
  parameter IDLE = 3'b000,                  //States of Read 
  parameter Rd_Addr_channel = 3'b001,
  parameter RD_Data_channel = 3'b010,
  
  parameter Wr_Addr_channel = 3'b011,       //States of Write
  parameter Wr_Data_channel = 3'b100,
  parameter Wr_response_channel = 3'b101)
(
input clk,
input reset,

input Read_Request,             //Read request from IP 
input Write_Request,           // Write request from IP
input [31:0] Addr,             //input address from IP

output reg [data_width-1 : 0] Read_Data ,    //Read Data from AXI to IP
input  [data_width-1 : 0] Write_Data,        //Write Data from IP to AXI
//////////////////////////     AXI_lite interface ////////////////////////
/////////////////////////       (Master Block)    ////////////////////////
//Write Address
input AWready,                           //Slave is ready to receive address
output reg AWvalid,                      //Valid address (HandShake)
output reg [31:0] AWaddr,
//output  [2:0] AWprot,
 
//Write Data Channel
input Wready,                            //Slave is ready to receive Data 
output reg Wvalid,                       //Valid Data to Write (HandShake)
output reg [data_width-1 : 0] Wdata,     //Data  
output reg [data_width/8 -1 : 0] Wstrb,  //Data strobe (Default = 1)
 
//Write response
input Bvalid,                           //Response Valid (HandShake)
input [1:0] Bresp,                      //Response
output reg Bready,                      //Ready to receive Response
 
 
//Read Address
input ARready,                          //Slave is ready to receive address
output reg ARvalid,                     //Valid Address (Handshake)
output reg [31:0] ARaddr,
//output reg [2:0] ARprot ,
 
 //Read Data Channel
input Rvalid,                          //Data is valid to read (Handshake)
input [data_width-1 : 0]Rdata,         
input  [1:0] Rresp,                    //response 
output reg Rready                      //Ready to receive Data 
    );
    
reg [2:0] state,nextstate; 
 //FSM  
always@ (posedge clk)
     begin 
      if (~reset)   begin state <= IDLE;    Wstrb <= 4'hf; end   
      else state <= nextstate;    
     end
 //NOTE: Repeating signals in every State to avoid inferring latches    
always@ (*) 
    begin
     case (state)
     IDLE: begin               ///// IDLE State //////
       ARaddr = 0;
       ARvalid = 0;
       Rready = 0;
       Read_Data = 0;        
       /////////////////
       Wvalid = 0;
       AWaddr = 0;             
       Wdata = 0;
       AWvalid = 0;
       Bready = 0;
       /////////////////
       if (Read_Request ^ Write_Request)    //works only if both signals are different  
          begin
            if (Read_Request) nextstate = Rd_Addr_channel;   //Read 
            else              nextstate = Wr_Addr_channel;   //Write
          end     
       else      nextstate = IDLE;                    
          end
 //////////////////////////////////////////////////////////////////////////////
      Rd_Addr_channel: begin        ////// Read Address Channel ///////
        Wvalid = 0;
        AWvalid = 0;               //In Read states all write signals are zeroes
        AWaddr = 0;             
        Wdata = 0;
        Bready = 0;
        ///////////////
        ARaddr = Addr;
        ARvalid = 1'b1;
        Rready = 1'b1; 
        Read_Data = 0;                         
        if (ARready)  nextstate =  RD_Data_channel;   //(Address HandShake)
        else   nextstate  = Rd_Addr_channel;       
                       end 
 /////////////////////////////////////////////////////////////////////////////////                         
     RD_Data_channel : begin    ///Read Data Channel ///  
        Wvalid = 0;
        AWvalid = 0;
        AWaddr = 0;             
        Wdata = 0;
        Bready = 0;
        //////////////
        ARaddr = Addr;
        ARvalid = 1'b0;
        Rready = 1'b1;
                       
        if (Rvalid  && (Rresp == 2'b00)) begin     ///(Data HandShake)
           Read_Data = Rdata;
           nextstate =  IDLE;
             end
         else   
           begin                         
           Read_Data = 0; 
           nextstate  = Rd_Addr_channel;   
           end        
                       end 
/////////////////////////////////////////////////////////////////////////////////                        
     Wr_Addr_channel : begin              ///Write Address Channel///
         ARaddr = 0;
         ARvalid = 0;
         Rready = 1'b0;              //In Write states all Read signals are zeroes
         Read_Data = 0; 
         //////////////// 
         Wvalid = 1;
         AWvalid = 1;
         AWaddr = Addr;
         Wdata = Write_Data;
         Bready = 1;                            
         if ( AWready) nextstate =  Wr_Data_channel;  //(Address Handshake)
         else   nextstate  = Wr_Addr_channel;                                         
                       end 
/////////////////////////////////////////////////////////////////////////////////                                  
     Wr_Data_channel : begin          ///Write Data Channel///
         ARaddr = 0;
         ARvalid = 0;
         Rready = 1'b0;
         Read_Data = 0; 
         //////////////
         AWaddr = Addr;
         AWvalid = 1'b0;
         Wvalid = 1'b1; 
         Bready = 1;
         if (Wready) begin              //(Data Handshake)
            Wdata = Write_Data;
            nextstate =  Wr_response_channel;
              end
         else   
            begin 
            Wdata = 0;
            nextstate  = Wr_Addr_channel;   
            end   
                       end
 /////////////////////////////////////////////////////////////////////////////////                       
     Wr_response_channel  : begin   ///Write Response Channel///
            AWaddr = Addr;
            AWvalid = 1'b0;
            Wvalid = 1'b0;            
            Wdata = 0;
            Bready = 1;
            ///////////////
            ARaddr = 0;
            ARvalid = 0;
            Rready = 1'b1;
            Read_Data = 0; 
            ///////////////
            if (Bvalid && (Bresp == 2'b00)) begin      //Response Handshake
                Rready = 1'b0;
                nextstate =  IDLE;
                end
            else     nextstate  = Wr_Addr_channel;
                                       
              end 
/////////////////////////////////////////////////////////////////////////////////                                                  
     default     begin   Rready = 0; 
                         ARaddr = 0;
                         ARvalid = 0;
                         Read_Data = 0; 
                         ////////////////
                         Wvalid = 0;
                         AWvalid = 0;
                         AWaddr = 0;
                         Wdata = 0;
                         Bready = 0;
                         ///////////////
                         nextstate =  IDLE;  end           
     endcase
     end
   
endmodule