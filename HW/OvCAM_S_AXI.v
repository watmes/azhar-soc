`timescale 1 ns / 1 ps

	module OvCAM_S_AXI #
	(
		
		parameter integer S_AXI_DATA_WIDTH	= 32,     // AXI DATA bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 4  //  AXI ADDRESS bus
		
	)
	(
        output reg [9:0] xLoc, //HORIZONTAL FRAME BUFFER conter  
        output reg [9:0] yLoc,//VERTICAL FRAME BUFFER 
        output reg [1:0]output_sel,        
		input wire  active_pixel,
        input wire i2c_ready, //ACTIVE FRAME IN THE CAM WILL BE VSYNC
        input wire [7:0] pixel_out,
        //**************************************//
		
	//GLOBAL SIGNALS STARTS WITH 'A' REFERINNG TO AXI 

		
		input wire ACLK,
		
		input wire  ARESETN,//  RESET Signal is Active LOW
		
		     // Write ADDRESS FROM MASTER TO SLAVE 
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		 
    	     //  Write channel TO SHOW the transaction is a DATA access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		
    		 // valid write ADDRESS and control information.
		input wire  S_AXI_AWVALID, // Write ADDRESS valid.
		
    	     //slave is ready to accept an ADDRESS and associated control signals.	
		output wire  S_AXI_AWREADY, // Write ADDRESS ready. 
		
		     // Write DATA FROM MASTER TO SLAVE 
		input wire [S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		 
		     // Write strobes. This signal indicates which byte lanes hold	
		input wire [(S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB, // valid DATA. 1write_strobe_bit for each BYTE  
		
		     // Write valid. 
		input wire  S_AXI_WVALID,// valid write DATA and strobes are available.
		
		     // Write ready.  
		output wire  S_AXI_WREADY, // slave can accept the write DATA.
		
		     // Write response.  	
		output wire [1 : 0] S_AXI_BRESP, // status of the write transaction   //2
		
		     // Write response valid.  
		output wire  S_AXI_BVALID, // the channel is signaling a valid write response.
		
		     // Response ready.
		input wire  S_AXI_BREADY, // the master can accept a write response.
		
		     // Read ADDRESS FROM MASTER TO SLAVE 
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,                     //4
		 
		     // Protection type. 
		input wire [2 : 0] S_AXI_ARPROT, // transaction is a DATA access or an instruction access.
		
		     // Read ADDRESS valid.  
		input wire  S_AXI_ARVALID, //channel is signaling valid read ADDRESS and control information.
		
		     // Read ADDRESS ready.  
   		output wire  S_AXI_ARREADY,// slave is ready to accept an ADDRESS and associated control signals.
		
		     // Read DATA ( slave)
		output wire [S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,                        //32
		
		      // Read response. 
		output wire [1 : 0] S_AXI_RRESP, //status of the read transfer.          //2
		
		     // Read valid.
		output wire  S_AXI_RVALID, // the channel is signaling the required read DATA.
		
		     // Read ready
		input wire  S_AXI_RREADY //Master can accept the read DATA and response information.
	);

	//*****************//
	
	
	
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr; //4 Write
	reg  	axi_awready; 
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;                  //2 
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;  //4 Read
	reg  	axi_arready;
	reg [S_AXI_DATA_WIDTH-1 : 0] 	axi_rDATA;  //32
	reg [1 : 0] 	axi_rresp;                  //2  
	reg  	axi_rvalid;

	
	// local parameter for ADDRESSing 32 bit / 64 bit S_AXI_DATA_WIDTH
	// ADDR_LSB is used for ADDRESSing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (S_AXI_DATA_WIDTH/32) + 1;   //32/32+1>>2
	localparam integer OPT_MEM_ADDR_BITS = 1; 
	//----------------------------------------------
	//-- Signals for user logic register 
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [S_AXI_DATA_WIDTH-1:0]	slv_reg0;  //32
	reg [S_AXI_DATA_WIDTH-1:0]	slv_reg1;  
	reg [S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [S_AXI_DATA_WIDTH-1:0]	 reg_DATA_out; //32
	integer	 byte_index;

  // I/O Connections 

	assign S_AXI_AWREADY	= axi_awready; 
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rDATA;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	
	
	
    //*************//

	// Implement axi_awready generation
	

	always @( posedge ACLK )
	begin
	  if ( ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0; 
	    end 
	  else
	    begin    
		       // axi_awready is asserted for oneACLK clock cycle when both
	           // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is de-asserted when reset is low.
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) 
	        begin
	          // slave is ready to accept write ADDRESS 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	    // Implement axi_awaddr latching to latch the ADDRESS when both S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge ACLK )
	begin
	  if ( ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write ADDRESS latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       


	// WRITE READY 
	
	always @( posedge ACLK )
	begin
	  if ( ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write DATA 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	//  MEM MAPPED register select and WRITE CHANNEL 
	// The write DATA is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid ADDRESS and DATA are available
	// and the slave is ready to accept the write ADDRESS and write DATA.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge ACLK )
	begin
	  if ( ARESETN == 1'b0 )
	    begin
		    //IDEAL STATE 
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	      slv_reg3 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren) // 
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] ) // 3:2
	          2'h0:
	            for ( byte_index = 0; byte_index <= (S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) 
				  begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h1:
	            for ( byte_index = 0; byte_index <= (S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h2:
	            for ( byte_index = 0; byte_index <= (S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h3:
	            for ( byte_index = 0; byte_index <= (S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end   //4REG OF THE SLAVE 
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
	                    end
	        endcase
	      end
	  end
	end    

	// WRITE RESPONSE 
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of ADDRESS and indicates the status of 
	// write transaction.

	always @( posedge ACLK )
	begin
	  if ( ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	           
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// ADDRESS READY 
	// axi_arready is asserted for oneACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read ADDRESS is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge ACLK )
	begin
	  if ( ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read ADDRESS
	          axi_arready <= 1'b1;
	          // Read ADDRESS latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// ADDRESS READ VALID
	// axi_rvalid is asserted for oneACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// DATA are available on the axi_rDATA bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read DATA on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rDATA are 
	// cleared to zero on reset (active low).  
	always @( posedge ACLK )
	begin
	  if ( ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read DATA is available at the read DATA bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read DATA is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	//  MEM MAPPED register select and READ CHANNEL 
	// Slave register read enable is asserted when valid ADDRESS is available
	// and the slave is ready to accept the read ADDRESS.
	
	
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // ADDRESS decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] ) 
	        2'h0   : reg_DATA_out <= slv_reg0; //{pixel_out[7:0],yLoc[9:0],xLoc[9:0],i2c_ready,active_pixel,[1:0]output_sel};
	        2'h1   : reg_DATA_out <= {23'b0,pixel_out[7:0],i2c_ready};
	        2'h2   : reg_DATA_out <= slv_reg2;
	        2'h3   : reg_DATA_out <= slv_reg3;
	        default : reg_DATA_out <= 0;
	      endcase
	end

	// Output register or memory read DATA
	always @( posedge ACLK )
	begin
	  if ( ARESETN == 1'b0 )
	    begin
	      axi_rDATA  <= 0;
	    end 
	  else
	    begin    
	      //  valid read ADDRESS (S_AXI_ARVALID) with 
	      // acceptance of read ADDRESS by the slave (axi_arready), 
	     
	      if (slv_reg_rden)
	        begin
	          axi_rDATA <= reg_DATA_out;     // register read DATA
	        end   
	    end
	end    

	
    // slv_reg0 = {pixel_out[7:0], [9:0],xLoc[9:0],i2c_ready,active_pixel,[1:0]output_sel} //8+22+2
    always @(slv_reg0, pixel_out, i2c_ready)
    begin
        yLoc = slv_reg0[23:14]; 
        xLoc = slv_reg0[13:4]; 
        output_sel = slv_reg0[1:0];
    end
	// User logic ends

	endmodule
