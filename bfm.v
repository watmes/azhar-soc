//----------------------------------------------------------------------------
// bfm_block_tb.v - module

// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

`timescale 1 ns / 100 fs

//testbench defines
`define RESET_PERIOD 200
`define CLOCK_PERIOD 10
`define INIT_DELAY   400

//user slave defines
`define BASE_ADDR  64'h000000030000000
`define REG_OFFSET 64'h000000000000000
`define RESET_ADDR 64'h000000000000100


//Response type defines
`define RESPONSE_OKAY   2'b00
//AMBA 4 defines
`define ADDR_BUS_WIDTH   64
`define RESP_BUS_WIDTH   2

module bfm_block_tb
(
); // bfm_block_tb

// -- ADD USER PARAMETERS BELOW THIS LINE ------------
// --USER parameters added here 
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_NUM_REG                      = 64;
parameter C_SLV_DWIDTH                   = 64;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------

  // -- Testbench nets declartions added here, as needed for testbench logic

  reg                                       rst_n;
  reg                                       sys_clk;
  integer                                   number_of_bytes;
  integer                                   i;
  integer                                   j;
  reg        [C_SLV_DWIDTH-1 : 0]           Data;
  reg        [`ADDR_BUS_WIDTH-1 : 0]        Addr;
  reg        [`RESP_BUS_WIDTH-1 : 0]        response; //AFTER FINSHING THE WRITE ACTION IN THE ADDR IT WILL BACK YOU THIS SIGNAL 
  //----------------------------------------------------------------------------
  // INSTANTIAT BLOCK
  //----------------------------------------------------------------------------

  bfm_block
    dut(.sys_reset(rst_n),.sys_clk(sys_clk));

  //----------------------------------------------------------------------------
  // RESET BLOCK 
  //----------------------------------------------------------------------------

  initial begin
         rst_n = 1'b0;
    #`RESET_PERIOD rst_n = 1'b1;
  end

  //----------------------------------------------------------------------------
  //  CLOCK GENERATOR 
  //----------------------------------------------------------------------------

  initial sys_clk = 1'b0;
  always #`CLOCK_PERIOD sys_clk = !sys_clk;

  //----------------------------------------------------------------------------
  // Simple testbench logic
  //----------------------------------------------------------------------------

  initial
  begin
    //WAITE FOR RESET 
    wait(rst_n == 0) @(posedge sys_clk);
    wait(rst_n == 1) @(posedge sys_clk);
   
    $display("----------------------------------------------------");
    $display("Full Registers write");
    $display("----------------------------------------------------");
    number_of_bytes = (C_SLV_DWIDTH/8);
    for( i = 0 ; i <64; i = i+1) 
	begin
      for(j = 0 ; j < number_of_bytes ; j = j+1)
        Data[j*8 +: 8] = j+(i*number_of_bytes);
      Addr = `BASE_ADDR + `REG_OFFSET + i*number_of_bytes;
      $display("Writing to Register addr=0x%h",Addr, " data=0x%h",Data);
      AXI_WRITE(Addr,Data , response);
    end
    for( i = 0 ; i <64; i = i+1)
	begin
      for(j=0 ; j < number_of_bytes ; j = j+1)
        Data[j*8 +: 8] = j+(i*number_of_bytes);
      Addr = `BASE_ADDR + `REG_OFFSET + i*number_of_bytes;
      
    end
end

  //----------------------------------------------------------------------------
  // AXI_WRITE : AXI_WRITE(ADRESS , DATA ,RESPONCE )
  //----------------------------------------------------------------------------

  task automatic AXI_WRITE;
     input [`ADDR_BUS_WIDTH-1 : 0] address;
     input [C_SLV_DWIDTH-1 : 0]    data;
     output[`RESP_BUS_WIDTH-1 : 0] response;
     begin
       fork
          dut.bfm_processor.bfm_processor.cdn_axi4_lite_master_bfm_inst.SEND_WRITE_ADDRESS(address,data);
          dut.bfm_processor.bfm_processor.cdn_axi4_lite_master_bfm_inst.RECEIVE_WRITE_RESPONSE(response);
       join
       CHECK_RESPONSE_OKAY(response);
     end
  endtask

  

  //----------------------------------------------------------------------------
  //   TEST LEVEL: CHECK_RESPONSE_OKAY(response)!!
  //----------------------------------------------------------------------------

  //Description: CHECING IF THE RESPONSE IS OKAY OR NOT , IT WILL RELATE TO READ FUNCTION IN THE WHOLE TB 
  //----------------------------------------------------------------------
  task automatic CHECK_RESPONSE_OKAY;
    input [`RESP_BUS_WIDTH-1:0] response;
     begin
      if (response !== `RESPONSE_OKAY)
	  begin
        $display("TESTBENCH FAILED! Response is not OKAY", response);
        $stop;
      end
    end
  endtask
 
endmodule 