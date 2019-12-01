
/*
  THIS TASK IS TO WRITE DATA WORD TO A SPASIFIC ADRESS
  YOU WILL USE IT IN YOUR GENERATED TB BY INSTANSIATE IT IN THIS FORM 
      AXI4_write('addr','data')
  */
  
task AXI4_write;
  input [AXI_ADDR_WIDTH - 1 : 0] addr;
  input [AXI_DATA_WIDTH - 1 : 0] data;
  begin
    AXI_Wdata = data;   //WRITE DATA 
    AXI_Waddr = addr;   //WRITE ADRESS
    AXI_adwvalid = 1;   //ADRESS AVALIBILTY 
    AXI_wvalid = 1;     //DATA AVALIBILTY 
    wait(AXI_adwready && AXI_wready);

    @(posedge AXI_aclk) 
	#1;
    AXI_adwvalid = 0;
    AXI_wvalid = 0;
	//ALL THE SIGNALS START WITH 'AXI_' SHOULD BE CONNECTED TO SIGNALS IN YOUR TB 
  end
endtask 

