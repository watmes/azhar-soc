module sd_card  #(parameter data_width = 32)( cs ,sclk ,mosi ,miso,ARVALID, ARREADY,BREADY,BRESP,ARADDER,ARPROT,RVALID,RREADY,RDATA,RRESP,AWVALID,AWREADY,AWADDER,AWPROT,WVALID,BVALID,WREADY,WDATA,WSTRB);
input miso;
output cs ,sclk ,mosi;


//Read Address channel
input ARVALID;
input ARREADY;
input [31:0] ARADDER;
input [2:0] ARPROT;

//read data channel
output RVALID;
output RREADY;
output [data_width-1:0] RDATA;
output  RRESP;

//write address channel
input AWVALID;
input AWREADY;
input [31:0] AWADDER;
input [2:0] AWPROT;

////write data channel
input WVALID;
input WREADY;
input [data_width-1:0] WDATA;
input [data_width/8 -1 : 0] WSTRB;

//write responce channel
output BVALID;
input BREADY;
output [1:0] BRESP;
endmodule
