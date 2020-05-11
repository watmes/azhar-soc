`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Modelling Team
// Create Date:    MARCH 2020
// Design Name: 
// Module Name:    transmitter
// Project Name:   UART TX design
// Target Devices: ALTERA FPGA
// Tool Versions: 
// Description:    the transmitter converts (parallel data --> serial) and 
//                 send the serial data to the receiver
// Revision: Version 1.00
//////////////////////////////////////////////////////////////////////////////////
module transmitter(
    input [8:0] data_in,           
    input [1:0] num_stop_bit,
    input reset,
    input [3:0] data_length,            
    input MCR1,                   
    input baud_clock,           
    input data_valid ,           //from process : data valid to transmit
    input n_CTS ,
    /////////////////////////////outputs ////////////////
    output reg  serial_data_out,
    output reg  n_RTS,                       
    output reg  tx_done,         //transmission done
    output tx_ready             //to process : ready to get data from process
    );
    
  reg  [9:0] data;
  reg [13:0] clk_counter;
  reg [3:0] length;
  reg [3:0] bit_counter;  
  reg start_transmit;
  reg tx;
  assign tx_ready = !tx_done;

always @(posedge baud_clock or negedge reset) 
 begin
   
   if (!reset) begin

        data <= 0;
        length <= 0;
        clk_counter <=0;
        bit_counter <= 0;
        n_RTS <= 1;
        tx_done <=0;
        serial_data_out <= 1;
        tx <=1;
       end

   else if (data_valid && MCR1 && tx && !n_CTS) begin

      case(data_length)
         4'd6: data <= {data_in[8],data_in[4:0],1'b0};
         4'd7: data <= {data_in[8],data_in[5:0],1'b0};
         4'd8: data <= {data_in[8],data_in[6:0],1'b0};
         4'd9: data <= {data_in[8],data_in[7:0],1'b0};
         default  data <= {data_in[8],data_in[7:0],1'b0};
         endcase

         length <= data_length;
         bit_counter <= 0;
         tx_done <= 0;
         n_RTS <= 1;   //ready to send
         tx <=0;
   end 
      
  else if ( MCR1 && !tx)begin
    n_RTS <= 0;   
    if (bit_counter <= length) begin
       if (clk_counter == 15) begin             //Start bit and data  
          clk_counter <=  0;                    //1 bit --> 16 cycle
          bit_counter <= bit_counter + 1;
          serial_data_out <= data[0];
          data <= {1'b0,data[9:1]};
          end
       else  begin
          serial_data_out <= data[0];
          clk_counter <= clk_counter +1;
        end      
     end
    else begin
     n_RTS <= 0;
        case (num_stop_bit)
      2'b01: begin
           if (clk_counter == 15)begin            //1 stop bit (16 cycle)
             clk_counter <=  0;
             tx_done <= 1;
             tx<=1;       
             serial_data_out <= 0;
              end
           else  begin
             serial_data_out <=1;
             clk_counter <= clk_counter +1;            
           end
       end
      2'b10:begin                        //1.5 stop bit (24 cycle)
           if (clk_counter == 23)begin            
             clk_counter <=  0;
             tx_done <= 1;
             tx<=1;     
             serial_data_out <=0;
              end
           else  begin
             clk_counter <= clk_counter +1;
              serial_data_out <=1;              
              end         
       end
    2'b11:begin
           if (clk_counter == 31)begin            //2 stop bit (32 cycle)
             clk_counter <=  0;
             tx_done <= 1;
             tx<=1;      
             serial_data_out <=0;
              end
           else  begin
             clk_counter <= clk_counter +1;
             serial_data_out <=1;             
              end         
      end
    default begin
           if (clk_counter == 15)begin            //1 stop bit
             clk_counter <=  0;
             tx_done <= 1;
             tx<=1;         
             serial_data_out <=0;
              end
           else  begin
             clk_counter <= clk_counter +1; 
             serial_data_out <=1;            
              end       
   
     end
     endcase


    end    
 end
 else begin
       data <= 0;
       length <= 0;
       clk_counter <=0;
       bit_counter <= 0;
       n_RTS <= 1;
       tx_done <=0;
       tx <= 1;    
 end 
end
endmodule
