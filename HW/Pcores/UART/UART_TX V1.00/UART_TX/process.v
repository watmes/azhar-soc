`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Modelling Team
// Create Date:  MARCH 2020
// Design Name: 
// Module Name:     Process
// Project Name:    UART TX design
// Target Devices:  ALTERA FPGA
// Description:  process block responisble for 
//               (determining the data length and number of stop bits
//                and adding parity bits )
              
// Revision: Version 1.00
//////////////////////////////////////////////////////////////////////////////////


module Process(
    input LCR0,                           //LCR0 && LCR1  from:user interface  to: process  function: determine data_in length
    input LCR1,
    input LCR2,                           // from:user interface  to: process  function: determine number of stop bits
    input LCR3,                           // from:user interface  to: process  function: determine parity bit enabled or not
    input LCR4,                          //LCR4 && LCR5  from:user interface  to: process  function: determine parity bit value and even or odd 
    input LCR5,
    input [7:0] data_in,  
    input fifo_empty,                     //from:fifo   to:process  function:check fifo empty or not 
    input clk,
    input reset,
    input tx_ready,                      //from:tx    to: process     function: check serial data is transmit to rx or not
    output reg  fifo_read,               // from:process  to: fifo    function: want to read data from fifo
    output reg [8:0] data_out,  
    output reg  [3:0] data_length,
    output reg [1:0] num_stop_bit,    //from: process  to:tx     function:number of stop bits
    output reg data_out_active        //from: process  to:tx  function: tell tx data_out is ready 
    );
    
 
 reg  XOR_OUT_parity;
 wire XOR_OUT ;   
 reg  [3:0] data_in_length ;    
 reg [7:0] data;   
 reg [2:0] state;
 reg [2:0] next_state;  
 reg [8:0] data_parity;    
 reg  [3:0] data_parity_length ;
 
 assign XOR_OUT = ^data ; 
 
 parameter  IDLE = 1'b0;     
 parameter  data_processing = 1'b1; 

 
 
always @(posedge clk) 
begin
  if (reset==0)  state<= IDLE;
  else           state<= next_state;
          
end 
   
always @ ( state or data_parity or data_parity_length or fifo_empty or data_in or tx_ready or data_in_length or data or LCR0 or LCR1 or  LCR2 or  LCR3 or  LCR4 or  LCR5 or XOR_OUT)
 begin
   case (state)

   IDLE: 
     begin 
          data_out_active <=  0;
          data_out <=0;
          num_stop_bit <=0;
          data_length <=0;
          fifo_read <= 0;
          data_parity <= 0;
          data_parity_length <=0;
          data <= 0;
          data_in_length <= 0;
          
    if ( fifo_empty == 0 && tx_ready)  //if fifo has data and the tanmsitter is  
       begin                           //ready to get data from process go to  
      fifo_read <= 1;                    //processing data state
     next_state <= data_processing ;
       end    	
	else   begin 
	  fifo_read <= 0; 
	  next_state<= IDLE;
     end
 end       
//////////////////////////DATA PROCESSING STATE/////////////////////////    
data_processing: 
    begin
    data_length<= 0;
	fifo_read <= 0;
	data<= data_in;	
	data_out <= data_parity ;
	data_length <= data_parity_length; 
    data_out_active<=1;
 ///////////////////////////////////////////////
 case({LCR0,LCR1})              //combinational block to compute data length
      2'b00:
        begin
         data_in_length <=5;
        end
      2'b01:
       begin
        data_in_length<=6;
       end
       2'b10:
        begin
         data_in_length<=7;
        end
       
     default: 
     begin
            data_in_length<=8;
      end
 endcase
 ///////////////////////////////////////////////////////////
     if (LCR3==1)
 begin
     case({LCR4,LCR5, XOR_OUT})    // XOR_OUT=0 :mean even number of ones       // XOR_OUT=1 :mean odd number of ones
        3'b000:                   // LCR4 == 0 :mean odd parity  (one's odd )    // lCR4 ==1 :mean even parity 
         begin                    //odd number of one's (parity = 1) else (parity = 0)
          data_parity_length <= data_in_length+ 1 ; 
          data_parity<= {1'b0,data} ;                 
         end
        3'b001 :
         begin
          data_parity_length<=  data_in_length+ 1;
          data_parity<= {1'b1,data} ;            
         end       
        3'b010:   
         begin
          data_parity_length <= data_in_length+ 1 ; 
          data_parity<= {1'b1,data} ;             
         end
        3'b011: 
         begin
          data_parity_length<=  data_in_length+ 1;
          data_parity<= {1'b0,data} ;              
         end
        3'b100:  //stick parity
        begin
          data_parity_length <= data_in_length+ 1 ; 
          data_parity<= {1'b0,data} ;  
        end 
       3'b101: 
        begin
          data_parity_length <= data_in_length+ 1 ; 
          data_parity<= {1'b1,data} ;  
        end    
       3'b110: 
        begin
          data_parity_length <= data_in_length+ 1 ; 
          data_parity<= {1'b1,data} ;  
        end 
      default: 
       begin
         data_parity_length <= data_in_length+ 1 ; 
         data_parity<= {1'b0,data} ;  
         end            
      endcase
     end     
 else  
      begin
      data_parity_length<=  data_in_length;  
      data_parity<= data;
      end 
  
////////////////////////////////////////////////////////
 case (LCR2)                            //compute Stop bits
 1'b0: 
     begin
        num_stop_bit<=2'b01;   //1 stop bit
      end
  
 1'b1:
      begin
        case({LCR0,LCR1})
        2'b00:
          begin
           num_stop_bit<=2'b10 ;    //1.5 stop bit
          end
         default:
           begin
            num_stop_bit<= 2'b11 ;   //2 stop bit
          end
          
      endcase  
     end  
endcase
      
    if(!tx_ready)                     
       next_state<=  IDLE;  
    else
       next_state<=  data_processing ;   
    end


 default: begin
    data_out_active <=  0;
    data_out<=0;
    num_stop_bit<=0;
    data_length<=0;
    fifo_read<= 0;
    next_state <= IDLE;
    data_parity<= 0;
    data_parity_length <= 0;
    data <= 0;
    data_in_length <= 0;
 end
endcase 

 end 
 
endmodule