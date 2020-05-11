`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Modelling Team
// Create Date: 
// Design Name: 
// Module Name:    fifo
// Project Name:   UART TX design
// Target Devices: ALTERA FPGA
// Description:  First input first output memory 
//               (the data we want to transmit are stored in FIFO) 
// Revision: Version 1.00
// 
//////////////////////////////////////////////////////////////////////////////////

module fifo
(
 input we, //control if reg dealing with fifo
 input re,
 input clk,
 input rst,
 input [7:0] data_in,
 output full,
 output reg [7:0] data_o,
 output  empty
 /////////////depug//////////////////
 
 /*
 output [4:0] write_pointer,
 output [4:0] read_pointer*/
);
integer i;
reg [4:0] pr,pw;
reg [7:0] mem [31:0];
assign empty = ((pw-pr)==0)? 1'b1:1'b0;
assign full  = (pr>pw)? (((pr-pw)==1)? 1'b1:1'b0):1'b0;

//////////depug///////////////
/*assign write_pointer = pw;
assign read_pointer = pr;*/

 always@(posedge clk )
begin

 if(!rst)
  begin
   pr<=5'd1;
   pw<=5'd1; 
   for(i=0;i<=31;i=i+1)
    begin
      mem[i]<=8'b0;
	end
  end
else
begin
  if(re&&!empty)
   begin
     data_o=mem[pr]; 
     pr=pr+5'd1;
   end
  else begin data_o<=data_o; end
  if(we&&!full )
   begin
     mem[pw]=data_in;
     pw=pw+5'd1;
   end
     
end
end
 
endmodule