/*
// AXI4LITE_MASTER PACKAGE 
// U CAN INSTANSIATE IT IN UR TB IN THIS FORM 
                                            "<import AXI4LITE_MASTER::*;>"


 // I PUT THE SIGNALS SIZE (WORD LENTH ) AS I FOUND IN A WRITTEN FILE SO YOU CAN CHANGE IT WHENEVER U NEED 
 // I SUGGEST U TO HAVE A GENRIC TYPES FILE IN VERILOG IT CAN BE .h FILE OR A PACKAGE LIKE THIS 



*/
package AXI4LITE_MASTER;

typedef bit [7:0]    bit8;
typedef bit [31:0]   bit32;
typedef bit [63:0]   bit64;
typedef bit [127:0]  bit128;
typedef bit8         bit8_16[16];
typedef class AXI4LITE_MASTER_busTrans;
typedef class AXI4LITE_MASTER_busBFM;
typedef mailbox #(AXI4LITE_MASTER_busTrans) TransMBox;

//----------- CLASS AXI4LITE_MASTER_BUS TRANSFERE :----------------

 class AXI4LITE_MASTER_busTrans;
  
  
    enum {WRITE_READ, IDLE, WAIT}       TrType;
       bit64                               address;
       bit8_16                             dataBlock;
       bit128                              dataWord;
       bit   [15:0]                        wrStrob;
       bit8                                resp;  
       int unsigned                        rdDataPtr;
       int unsigned                        wrRespPtr;
       int                                 lastTr;
       int                                 idleCycles;
       string                              failed_Trans;

    //-**** unpack2pack(): CONVERTS UNPACK ARRAY TO PACK ****
  
    function bit128 unpack2pack(bit8_16 dataBlock);
  
     for (int i = 0; i < 16; i++) unpack2pack[8*i+:8] = dataBlock[i];
	
    endfunction

    //- **** pack2unpack(): CONVERTS PACK ARRAY TO UNPACK ****

    function bit8_16 pack2unpack(bit128 dataBlock);
  
     for (int i = 0; i < 16; i++) pack2unpack[i] = dataBlock[8*i+:8];
	
    endfunction
  
    //-**** genErrorMsg(): GENRATES ERROR MESSAGE **** 
  
    function void genErrorMsg(string ErrStr);
     string tempStr;
       ErrStr = {ErrStr, " at sim time "};
      $write(ErrStr,"%0d\n", $time() );
      tempStr.itoa($time);
      this.failed_Trans = ErrStr;
      this.failed_Trans = {this.failed_Trans, " ", tempStr, "ns"};
    endfunction
  
  endclass // AXI4LITE_MASTER_busTrans

//------ Class AXI4LITE_MASTER_busBFM:------------

class AXI4LITE_MASTER_busBFM;
  
  string id_name;
  int blockSize;  
  virtual AXI4LITE_MASTER_if ifc; //VIRTULE INTERFACE & CALL BACK 
  // MAIL BOX  
  TransMBox trWrAddrBox, trWrDataBox, trRdAddrBox, trRdDataBox,
            trWrRespBox, trRReadyBox, trWrAddrQueueBox, statusBox;
  semaphore wrAddrSem, wrDataSem, wrRespSem, rdAddrSem, rdDataSem;
  local AXI4LITE_MASTER_busTrans trWrAddr, trWrData, trRdAddr, trRdData, trWrResp;
  // Read data and write response buffers
  TransMBox RdDataArrayBox[*];
  TransMBox WrRespArrayBox[*];
  int readyTimeOut;
  int respReportEn;
 //CONTROL DELAYS 
  int       max_Burst_Len_WrAddr    = 0;
  int       burst_Cnt_WrAddr        = 0;
  int       max_Burst_Len_WrData    = 0;
  int       burst_Cnt_WrData        = 0;
  int       max_Burst_Len_RdAddr    = 0;
  int       burst_Cnt_RdAddr        = 0;
  int       max_Burst_Len_RdData    = 0;
  int       burst_Cnt_RdData        = 0;
  int       max_Burst_Len_WrResp    = 0;
  int       burst_Cnt_WrResp        = 0;
  int       maxBurst                = 0;
  int       minBurst                = 0;
  int       maxWait                 = 0;
  int       minWait                 = 0;

    //- ******************START TASK ********************
	
  task startBFM  ();
  //LOOP 4 EACH BUS 
     /* FUNCTION OF EACH_loop():
                   1- Get mailbox data. 
				   2-Check transaction type and call
    */
      fork
        this.write_addr_loop();
        this.write_data_loop();
        this.read_addr_loop();
        this.read_data_loop();
        this.write_resp_loop();
      join_none
  endtask
  
   //- ******************WRITE ADDRES TASK ********************
   
   
  task write_addr_loop();
    
     this.ifc.cb.awaddr         <= 'd0;
     this.ifc.cb.awvalid        <= 1'b0;
   
      forever
       begin
            this.trWrAddrBox.get(this.trWrAddr);
                if(this.trWrAddr.TrType == AXI4LITE_MASTER_busTrans::IDLE) 
	             begin
                  repeat (this.trWrAddr.idleCycles) @this.ifc.cb;
                end 
	           if(this.trWrAddr.TrType == AXI4LITE_MASTER_busTrans::WAIT)
			     begin
                   this.wrAddrSem.put(1);
                end 
				else 
				    begin
                      this.writeAddr();
                end
       end
	   
  endtask
  
  //- ******************WRITE DATA TASK ********************
  

  task write_data_loop();

      this.ifc.cb.wdata         <= 'd0;
      this.ifc.cb.wstrb         <= 'd0;
      this.ifc.cb.wvalid        <= 1'b0;

      forever
	  begin
            this.trWrDataBox.get(this.trWrData);
            if(this.trWrData.TrType == AXI4LITE_MASTER_busTrans::IDLE)
			  begin
               repeat (this.trWrData.idleCycles) @this.ifc.cb;
              end
			if (this.trWrData.TrType == AXI4LITE_MASTER_busTrans::WAIT)
			 begin
              this.wrDataSem.put(1);
             end
			else begin
               this.writeData();
               this.trWrRespBox.put(this.trWrData);//GENRATES TRANSECTION 
               end
       end
  endtask
  
    //- ******************WRITE RESPONSE  TASK ********************

  task write_resp_loop();
   
    this.ifc.cb.bready         <= 1'b0;
	
   
    forever
	begin
       this.trWrRespBox.get(this.trWrResp);
       if (this.trWrResp.TrType == AXI4LITE_MASTER_busTrans::WAIT)
	    begin
        this.rdDataSem.put(1);
        end 
	   else begin
        this.writeResp();
       end
    end
  endtask
  
    //- ******************READ ADDRS TASK ********************


  task read_addr_loop();
    
      this.ifc.cb.araddr         <= 'd0;
       this.ifc.cb.arvalid        <= 1'b0;
   
     forever 
	  begin
               this.trRdAddrBox.get(this.trRdAddr);
         if(this.trRdAddr.TrType == AXI4LITE_MASTER_busTrans::IDLE)
		   begin
            repeat (this.trRdAddr.idleCycles) @this.ifc.cb;
           end
	     else if (this.trRdAddr.TrType == AXI4LITE_MASTER_busTrans::WAIT)
    	  begin
            this.rdAddrSem.put(1);
          end
	     else begin
          this.readAddr();
          this.trRdDataBox.put(this.trRdAddr);
          end
       end
   endtask
  
    //- ******************READ DATA TASK ********************

  task read_data_loop();
   
      this.ifc.cb.rready  <= 1'b0;
      forever
	  begin
         this.trRdDataBox.get(this.trRdData);
         if (this.trRdData.TrType == AXI4LITE_MASTER_busTrans::WAIT)
		   begin
            this.rdDataSem.put(1);
           end 
		 else begin
           this.readData();
           end
       end
  endtask
  
    //- ******************GENRATES ADDRES BUS TIMING TASK ********************
  
  local task writeAddr();
               AXI4LITE_MASTER_busTrans trErr;
               string tempStr;
          
              this.ifc.clockAlign();
          // GENRATE TIMING
              this.ifc.cb.awaddr         <= this.trWrAddr.address;
              this.ifc.cb.awvalid        <= 1'b1;
              @this.ifc.cb;
    
     fork: aw_ready_poll
         while(this.ifc.cb.awready !== 1'b1) @this.ifc.cb;
          begin
               repeat(this.readyTimeOut) @this.ifc.cb;
               trErr = new();
               trErr.genErrorMsg("ERROR: Write address channel TimeOut");
               this.statusBox.put(trErr);
                trErr = null;
           end
      join_any
      disable aw_ready_poll;
              this.ifc.cb.awvalid        <= 1'b0;
           // RANDOM TIME 
              if(this.max_Burst_Len_WrAddr != 0)
			   begin
                    this.burst_Cnt_WrAddr++;
               end
             if(this.burst_Cnt_WrAddr == this.max_Burst_Len_WrAddr)
	         begin
                   if(this.max_Burst_Len_WrAddr != 0)
			        repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
                   this.burst_Cnt_WrAddr = 0;
                   this.max_Burst_Len_WrAddr = $urandom_range(this.maxBurst, this.minBurst);
                end
  endtask
  
 
   //- ******************GENRATES DATA BUS TIMING TASK ********************
   
   local task writeData();
            AXI4LITE_MASTER_busTrans trErr;
            string tempStr;
            this.ifc.clockAlign();
            this.ifc.cb.wvalid         <= 1'b1;
            this.ifc.cb.wdata          <= this.trWrData.dataWord;
            this.ifc.cb.wstrb          <= this.trWrData.wrStrob;
            @this.ifc.cb;
    
        fork: w_ready_poll
              while(this.ifc.cb.wready !== 1'b1) @this.ifc.cb;
                 begin
                        repeat(this.readyTimeOut) @this.ifc.cb;
                        trErr = new();
                        trErr.genErrorMsg("ERROR: Write data channel TimeOut Detected");
                        this.statusBox.put(trErr);
                        trErr = null;
                   end
        join_any
        disable w_ready_poll;
             this.ifc.cb.wvalid          <= 1'b0;
              if(this.max_Burst_Len_WrData != 0)
			  begin
                 this.burst_Cnt_WrData++;
                end
             if(this.burst_Cnt_WrData == this.max_Burst_Len_WrData)
			 begin
                if(this.max_Burst_Len_WrData != 0) 
				   repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
              this.burst_Cnt_WrData = 0;
              this.max_Burst_Len_WrData = $urandom_range(this.maxBurst, this.minBurst);
              end
  endtask
      //- ******************GENRATES ADDRES BUS TIMING TASK ********************

  
  local task readAddr();
           AXI4LITE_MASTER_busTrans trErr;
           string tempStr;
           this.ifc.clockAlign();
           this.ifc.cb.araddr         <= this.trRdAddr.address;
           this.ifc.cb.arvalid        <= 1'b1;
           @this.ifc.cb;
   
           fork: ar_ready_poll
             while(this.ifc.cb.arready !== 1'b1) @this.ifc.cb;
              begin
                      repeat(this.readyTimeOut) @this.ifc.cb;
                      trErr = new();
                      trErr.genErrorMsg("ERROR: Read address channel TimeOut Detected");
                      this.statusBox.put(trErr);
                      trErr = null;
                end
           join_any
           disable ar_ready_poll;
                  this.ifc.cb.arvalid        <= 1'b0;
    
                  if(this.max_Burst_Len_RdAddr != 0)
				  begin
                    this.burst_Cnt_RdAddr++;
                  end
                  if(this.burst_Cnt_RdAddr == this.max_Burst_Len_RdAddr)
				  begin
                    if(this.max_Burst_Len_RdAddr != 0) repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
                    this.burst_Cnt_RdAddr = 0;
                    this.max_Burst_Len_RdAddr = $urandom_range(this.maxBurst, this.minBurst);
                 end
  endtask
  
  //- ******************GENRATES DATA BUS TIMING TASK ********************
  
  local task readData();
            AXI4LITE_MASTER_busTrans trErr;
            string tempStr;
            this.ifc.cb.rready        <= 1'b1;
            @this.ifc.cb;
            this.trRdData.resp = 8'd0;
    
            fork: r_valid_poll
                      while(this.ifc.cb.rvalid !== 1'b1) @this.ifc.cb;
                           begin
                                repeat(this.readyTimeOut) @this.ifc.cb;
                                trErr = new();
                                trErr.genErrorMsg("ERROR: Read Data channel TimeOut Detected");
                                this.statusBox.put(trErr);
                                trErr = null;
                                this.trRdData.resp = 8'hff;
                            end
            join_any
            disable r_valid_poll;
   
                    this.ifc.cb.rready        <= 1'b0;
                    this.trRdData.resp[1:0]   = this.ifc.cb.rresp;
                    this.trRdData.dataBlock   = this.trRdData.pack2unpack(this.ifc.cb.rdata);
                    if((this.respReportEn == 1) && (this.trRdData.resp != 'd0))
					begin
                              trErr = new();
                              trErr.genErrorMsg("ERROR: Not OK read response Detected");
                              this.statusBox.put(trErr);
                              trErr = null;
                    end
                            this.RdDataArrayBox[this.trRdData.rdDataPtr].put(this.trRdData);
    
                    if(this.max_Burst_Len_RdData != 0)
					begin
                      this.burst_Cnt_RdData++;
                    end
                    if(this.burst_Cnt_RdData == this.max_Burst_Len_RdData)
					begin
                      if(this.max_Burst_Len_RdData != 0) repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
                      this.burst_Cnt_RdData = 0;
                      this.max_Burst_Len_RdData = $urandom_range(this.maxBurst, this.minBurst);
                    end
  endtask
  
       //- ******************GENRATES RESPONSE TIMING TASK ********************

  
  local task writeResp();
                    AXI4LITE_MASTER_busTrans trErr;
                    string tempStr;
					this.ifc.cb.bready         <= 1'b1;
                    @this.ifc.cb;
                    this.trWrResp.resp = 8'd0;
    
            fork: w_resp_valid_poll
                      while(this.ifc.cb.bvalid !== 1'b1) @this.ifc.cb;
                      begin
                        repeat(this.readyTimeOut) @this.ifc.cb;
                        trErr = new();
                        trErr.genErrorMsg("ERROR: Write response channel TimeOut Detected");
                        this.statusBox.put(trErr);
                        trErr = null;
                        this.trWrResp.resp = 8'hff;
                      end
            join_any
            disable w_resp_valid_poll;
                    this.ifc.cb.bready         <= 1'b0;
                    this.trWrResp.resp[1:0]     = this.ifc.cb.bresp;
                    if((this.respReportEn == 1) && (this.trWrResp.resp != 'd0))
					begin
                      trErr = new();
                      trErr.genErrorMsg("ERROR: Not OK write response Detected");
                      this.statusBox.put(trErr);
                      trErr = null;
                    end
                    this.WrRespArrayBox[this.trWrResp.wrRespPtr].put(this.trWrResp);
                   if(this.max_Burst_Len_WrResp != 0)
				   begin
                      this.burst_Cnt_WrResp++;
                    end
                    if(this.burst_Cnt_WrResp == this.max_Burst_Len_WrResp)
					begin
                          if(this.max_Burst_Len_WrResp != 0)
						    repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
                         this.burst_Cnt_WrResp = 0;
                         this.max_Burst_Len_WrResp = $urandom_range(this.maxBurst, this.minBurst);
                    end
  endtask
 endclass
endpackage:AXI4LITE_MASTER