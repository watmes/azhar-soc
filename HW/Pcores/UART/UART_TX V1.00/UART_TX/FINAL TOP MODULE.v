`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Modelling Team
// Create Date:  MARCH 2020
// Design Name: 
// Module Name:    UART_Top_Module
// Project Name:   UART TX design
// Target Devices: ALTERA FPGA
// Tool Versions: 
// Description:  The top module of UART which containing these blocks  
//               (User Interface, FIFO, Process, Transmitter, Clock Divider)
//
// Revision: Version 1.00
// 
//////////////////////////////////////////////////////////////////////////////////

module UART_Top_Module(
////////////inputs/////////////
input clk,                     //system clock
input rst,                     //global reset
input [7:0] data_in,           //data input from AXI side
input wr_en,rd_en,             //write enable and read enable  
input [2:0] address,           //address input to access user interface registers    
///////////outputs////////////
output  [7:0]data_o,           //data out to read data from interface register
output  serial_data_out,       //serial data out to UART receiever 
output  n_RTS,                 //request to send
output  tx_done,               //data transmission done
input   n_CTS                //clear to send

///////////////////////////////// depug pins  //////////////////////////////
/*
 output [4:0] write_pointer,  //remove the comment if you want to use depug ports
 output [7:0]reg0,
 output [7:0]reg1,
 output [7:0]reg3,
 output [7:0]reg4,
 output [7:0] fifo_data,
 output baud,
 //output [15:0] value_rate_depug,
 output fifo_en,
 output [7:0] data_in_process,
 output data_valid_process,
 output [8:0]data_tx,
 output [3:0] length,
 output [1:0] stop_bit,
 output fifo_full,
 output [4:0] read_pointer,
 output fifo_empty,
 output tx_ready*/
);

//UI
wire b1;
wire [7:0]b2;
wire b3;
wire [7:0]ar0;
wire [7:0]ar1;
wire [7:0]ar3;
wire [7:0]ar4;
//process
wire e1, e2;
wire [8:0]e3;
wire [1:0]e4;
wire [3:0]e5;
wire e6;
//fifo
wire c1, c3;
wire [7:0]c2;
//clk_div
wire  d1;
  /*
assign tx_ready = e1;
assign reg0 = ar0;
assign reg1 = ar1;
assign reg3 = ar3;
assign reg4 = ar4;
assign fifo_data = b2;
assign baud = d1;
assign fifo_en = b3;
assign data_in_process   =c2;
assign data_valid_process  =e2;
assign data_tx = e3;
assign length = e5;
assign stop_bit = e4;
assign fifo_full = b1;
assign fifo_empty = c3;*/
assign tx_done = e6;

 UART_User_interface UI1 ( .clk(clk), .rst(rst),
  .wr_en(wr_en), .rd_en(rd_en), .data_in(data_in)
  , .addr(address), .fifo_full(b1),
  .data_fifo(b2), .fifo_wr_en(b3), .AXI_data_out(data_o),
  .reg_array0(ar0), .reg_array1(ar1), .reg_array3(ar3)
  , .reg_array4(ar4)
  );
  
  fifo F1( .clk(clk), .rst(rst),
  .we(b3), .data_in(b2), .re(c1),
  .full(b1), .data_o(c2), .empty(c3));
  //,.write_pointer(write_pointer),
 // .read_pointer(read_pointer));
  
  c_div CD1( .rst(rst),
  .clk_cpu(clk), .tx(ar0), .rate(ar1), .control(ar3[7]),
  .baud_clock(d1));
//  .value_rate_depug(value_rate_depug));
  
  
  Process pr(
  .clk(clk), 
  .reset(rst),
  .data_in(c2), 
  .fifo_empty(c3), 
  .tx_ready(e1),
  .LCR0(ar3[0]), 
  .LCR1(ar3[1]),
  .LCR2(ar3[2]),
  .LCR3(ar3[3]),
  .LCR4(ar3[4]),
  .LCR5(ar3[5]),
  .fifo_read(c1), 
  .data_out_active(e2),
  .data_out(e3), 
  .num_stop_bit(e4),
  .data_length(e5));
  
  //tx 
  transmitter TX(  .reset(rst),
  .data_valid(e2), .data_in(e3), .num_stop_bit(e4), .data_length(e5), .MCR1(ar4[1]), .baud_clock(d1),
  .serial_data_out(serial_data_out), .n_RTS(n_RTS), .tx_done(e6),.tx_ready(e1),.n_CTS(n_CTS));
 endmodule