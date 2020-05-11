`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Modelling Team
// Create Date:    MARCH 2020
// Design Name: 
// Module Name:    UART_User_interface
// Project Name:   UART TX design
// Target Devices: ALTERA FPGA
// Description:  User interface contain registers which control the
//               operation of UART and also show status of UART
//
//               (User interface is the link between software developer and 
//               UART hardware)
// Revision: Version 1.00
// 
//////////////////////////////////////////////////////////////////////////////////

module UART_User_interface(
input [7:0]data_in,
input [2:0]addr,
input wr_en,
input rd_en,
input rst,
input clk,
input fifo_full,

output reg [7:0]AXI_data_out,
output reg [7:0]data_fifo,
output reg fifo_wr_en,
output     [7:0]reg_array0,
output     [7:0]reg_array1,
output     [7:0]reg_array3,
output     [7:0]reg_array4
    );
 reg [7:0] mem [0:7];
 
assign reg_array0=mem[0];   //DLL or THR registers
assign reg_array1=mem[1];   //DLH or RBR registers
assign reg_array3=mem[3];   //LCR
assign reg_array4=mem[4];   //MCR

always @ (posedge clk) begin
 if (!rst) begin
   
   mem[0] <= 8'b0;
   mem[1] <= 8'b0;
   mem[2] <= 8'b0;
   mem[3] <= 8'b0;
   mem[4] <= 8'b0;
   mem[5] <= 8'b0;
   mem[6] <= 8'b0;
   mem[7] <= 8'b0;
    end
 else begin
   if (wr_en) 
      begin
       mem[addr] <= data_in;
       AXI_data_out <= 0;
         if (addr== 3'b000&& !fifo_full && reg_array3[7] == 0)
         begin                             //under these conditions  
            fifo_wr_en <= 1'b1;            //write the data in reg0 to FIFO
            data_fifo <= data_in;
            mem[5] <= 8'b11111101;
         end 
         else 
         begin
            mem[5]<= 8'b11111111;
            fifo_wr_en <= 1'b0;
            data_fifo <= 8'b0;
         end  
   end	  
   else if (rd_en) begin
	       AXI_data_out <= mem[addr];
   end
   else begin
	      AXI_data_out <= 0;
	      fifo_wr_en <= 1'b0;
	      mem[5]<= 8'b11111111;
   end	 
 end
end
endmodule
