`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Modelling Team
// Create Date:    MARCH 2020
// Design Name: 
// Module Name:    UART_TEST
// Project Name:   UART TX design
// Description:    Test bench for top module   
//
// Revision: Version 1.00
 
//////////////////////////////////////////////////////////////////////////////////
module UART_TEST ();
reg clk;
reg rst;  
reg [7:0]data_in;   //data from rx to file register
reg  wr_en,rd_en;
reg  [2:0]address;
reg  n_CTS;

wire   serial_data_out;
wire  n_RTS;  
wire  [7:0]data_o;           //from:tx  to:rx  function:ready to send
wire  tx_done;

////////////depug////////////////
/*
wire [4:0] write_pointer;    //remove the comment if you want to use depug ports
wire [7:0]reg0;
wire [7:0]reg1;
wire [7:0]reg3;
wire [7:0]reg4;
wire [7:0] fifo_data; 
wire baud;
//wire [15:0] value_rate_depug;
wire fifo_en ;
wire [7:0] data_in_process; 
wire data_valid_process;
wire [8:0]data_tx;
wire [3:0] length;
wire [1:0] stop_bit;
wire fifo_full;
wire [4:0] read_pointer;
wire fifo_empty;
wire tx_ready;
*/


 always #10 clk = ~clk;            //generate clock
 
 initial 
  begin
  clk = 0;
  rst = 1; wr_en = 0; rd_en=0; data_in = 8'h00; address = 3'b000;
  n_CTS = 0;           //CTS = 0 ==> allowed to send data
  
  #20 rst=0;
  #20 rst=1;
  #20  wr_en=1; data_in=8'h80; address=3'b011; //LCR[7] == 1 activate clock generator
  #20  data_in=8'h46; address=3'b000;          //DLL = 46 H
  #20  data_in=8'h01; address=3'b001;          //DLH = 01 H
  
  #20  data_in=8'h0f; address=3'b011;         //LCR[7] == 0 activate data registers and LCR[4:0] = 0
  #20  data_in=8'h02; address=3'b100;         // MCR[1] == 1
  #20  data_in=8'b01010101; address=3'b000;   //data to send  first(55h)
  #20  data_in=8'b01010111; address=3'b000;   // data to send secong (57H)
  #20  data_in=8'hab; address=3'b001;         
  #20 wr_en=0;                            //disable writing inside UI
 
 end
 UART_Top_Module  uart1(
 .clk(clk),
 .rst(rst),  
 .data_in(data_in),   
 .data_o(data_o),
 .wr_en(wr_en),
 .rd_en(rd_en),
 .address(address),
 .serial_data_out(serial_data_out),
 .n_RTS(n_RTS),            
 .tx_done(tx_done),
 .n_CTS(n_CTS)
////////////depug/////////////////// 
   /*                               
.write_pointer(write_pointer),
.reg0(reg0),
.reg1(reg1),
.reg3(reg3),
.reg4(reg4),
.fifo_data(fifo_data),
.baud(baud),
//.value_rate_depug(value_rate_depug),
.fifo_en(fifo_en),
.data_in_process(data_in_process),
.data_valid_process(data_valid_process),
.data_tx(data_tx),
.length(length),
.stop_bit(stop_bit),
.fifo_full(fifo_full),
.read_pointer(read_pointer),
.fifo_empty(fifo_empty),
.tx_ready(tx_ready),*/
  );
endmodule
