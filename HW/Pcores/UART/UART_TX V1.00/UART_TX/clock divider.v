`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Modelling Team
// Create Date:    MARCH 2020
// Design Name: 
// Module Name:    c_div
// Project Name:   UART TX design
// Target Devices: ALTERA FPGA
// Description:    this block uses the system clock to generate the baud 
//                 clock by divide system clk on the divisor   
//
//                 (the developer choose appropriate divisor 
//                  to generate the required baud clock according to
//                  the system clock)
// Revision: Version 1.00
// 
//////////////////////////////////////////////////////////////////////////////////
module c_div
(
input control,              //bit number 7 LCR register 
input clk_cpu,              //system clock
input rst,
input [7:0] tx,             //from DLL register (UI)
input [7:0] rate,           //from DLH register  (UI)
output reg baud_clock       //output clock
);
reg [15:0] value_rate;
reg  [22:0] int_counter;
reg generate_clk = 0;

always @( posedge clk_cpu)
begin
	if (!rst)
		begin
         value_rate <=16'b0;
		 int_counter <= 0;
	     baud_clock <=1;
		end
    else if (control) begin
         value_rate <= {rate,tx};
         generate_clk <= 1;
    end
    else if (generate_clk) begin
	      if (int_counter == ((value_rate/2)))  //baud clock = sys clock / divisor
		     begin
		      int_counter <= 0;
		      baud_clock <= ~baud_clock;
		      end
	      else
		      int_counter <= int_counter + 1;
          end
    else begin 
             value_rate <= 16'b0;
		     int_counter <= 0;
	         baud_clock <=1;
         end 
end
endmodule