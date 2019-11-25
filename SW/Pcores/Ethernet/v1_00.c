#include <stdio.h>
#include <string.h>
#include <stdlib.h>
struct TL0  //Transmit Length Register
{
	char FL_LSB ; 
	char FL_MSB ;
	short int reserved ;
}; 
struct GIE0 //Global Interrupt Enable Register
{
	int reserved:31 ;
	char gie:1 ;
};
struct PING_TX0 //Transmit Control Register
{
	char s:1; //Status
	char p:1; //Program
	char reserved0:1;
	char i:1; //Interrupt Enable
	char l:1; //Loopback
	int reserved:27;	
};
struct PONG_TX0 //Transmit Control Register
{
	char s:1 ; //status
	char p:1 ; //program
}
struct PONG_RX0 //Receive Control Register
{
	char s:1 ; //status
	int reserved:31 ;
};
struct PING_RX0 //Receive Control Register
{
	char s:1; //status
	char reserved:2; 
	char ie:1 ; //Interrupt Enable
	int reserved:26;
}
struct MDIOADDR0 //MDIO Address Register
{
	char REGADDR:5 ; //PHY register address
	char PHYADDR:5 ;//PHY device address
	char OP:1 ;//Operation Access Type
	int reserved:21;	
};
struct MDIOWR0 //MDIO Write Data Register
{
	short int Write_Data ; //MDIO Write Data
	short int reserved ;
};
struct MDIORD0 //MDIO Read Data Register 
{
	short int Read_Data ; //MDIO Read Data
	short int reserved ;
};
struct MDIOCTRL0 //MDIO Control Register
{
	char s:1 ; //status
	char reserved:2;
	char e:1 ; //MIDO Enable
	int reserved:28 ;
};
struct Erhernet 
 {
	
	struct MDIOADDR0    MDIOADDR ; 
	struct MDIOWR0 		MDIOWR;
	struct MDIORD0 		MDIORD;
	struct MDIOCTRL0 	MDIOCTRL;
	struct TL0			TX_Ping_Length;
	struct GIE0 		GIE;
	struct PING_TX0		TX_Ping_Control;
	struct TL0 			TX_Pong_Length ;
	struct PONG_TX0		TX_Pong_Control;
	struct PING_RX0		RX_Ping_Control;
	struct PONG_RX0		RX_Pong_Control;
};
struct Erhernet erhernet;
int Ping_Data_Lenght (struct Erhernet erhernet  ,char x) // x = 'L' Frame length LSB 
{											   		     // x = 'M' Frame length MSB	
	int lenght	;   		  // x = 'T' Total frame length 	  
	if ( x =='L')
		{
		lenght = erhernet.TX_Ping_Length.FL_LSB
		}
	 else if ( x =='M')
		{
		lenght = erhernet.TX_Ping_Length.FL_MSB ;
		}
	 else if( x =='T')
		{
		 lenght = erhernet.TX_Ping_Length.FL_LSB + erhernet.TX_Ping_Length.FL_MSB *1000000000
		}
	 else {
		lenght = 0;
		}
		return lenght ; 
}
int Pong_Data_Lenght (struct Erhernet erhernet ,char x) // x = 'L' Frame length LSB 
{							  							// x = 'M' Frame length MSB	
	int lenght	;   		  // x = 'T' Total frame length 	  
	if ( x =='L')
		{
		lenght = erhernet.TX_Pong_Length.FL_LSB
		}
	 else if ( x =='M')
		{
		lenght = erhernet.TX_Pong_Length.FL_MSB ;
		}
	 else if( x =='T')
		{
		 lenght = erhernet.TX_Pong_Length.FL_LSB + erhernet.TX_Pong_Length.FL_MSB *1000000000
		}
	 else {
		lenght = 0;
		}
		return lenght ; 
}
void set_Global_Interrupt_Enable(struct Erhernet erhernet,char x) //
{ 	if ( x==0){
		erhernet.GIE.gie = 0;
	}
	else if ( x==1){
		erhernet.GIE.gie = 1;
	}
}
void Set_Internal_Loopback(struct Erhernet erhernet, char x )
{
	if (x==1 || x==0){
		erhernet.TX_Ping_Control.l = x;
	}
}
 void set_TX_Interrupt_Enable (struct Erhernet erhernet , char x )
	{
		if (x==0){
		erhernet.TX_Ping_Control.i=0;
		}
		else if (x==1)
		{erhernet.TX_Ping_Control.i=1;}
	}
void Set_new_MAC_TX_Ping(struct Erhernet erhernet,char x )
	{												
		if (x==1){
		erhernet.TX_Ping_Control.p=1;
		erhernet.TX_Ping_Control.s=1;
		}
		else if (x==0){
		erhernet.TX_Ping_Control.p=0;
		}
	}
	/*
	The software sequence for programming a new Ethernet MAC address is:
	• The software loads the new Ethernet MAC address in the transmit dual port memory,
	starting at address 0x0. The most significant four bytes are stored at address 0x0 and
	the least significant two bytes are stored at address 0x4. The Ethernet MAC address
	can also be programmed from the pong buffer starting at 0x0800.
	• The software writes a 1 to both the program bit (Bit[1] on the data bus) and the status
	bit (Bit[0] on the data bus) at address 0x07FC. The pong buffer address is 0x0FFC.
	• The software monitors the status and program bits and waits until they are set to 0
	before performing any additional Ethernet operations.
	A transmit complete interrupt, if enabled, occurs when the status and program bits are
	cleared
	*/
void set_RX_Interrupt_Enable (struct Erhernet erhernet , char x )
	{
  	 if ( x==0){
		erhernet.RX_Ping_Control.i=0;
		}
	 else if (x==1){erhernet.RX_Ping_Control.i=1;}	
	}		
void set_Ping_buffer (struct Erhernet erhernet,char x)//Transmit ping buffer is ready to accept new frame
	{if ( x==0){
		erhernet.RX_Ping_Control.s=0;
		}
	 else if (x==1){erhernet.RX_Ping_Control.s=1;}
	 }
	
void set_new_MAC_adrees_TX_Pong	 ( struct Erhernet erhernet,char x )//Program :AXI Ethernet Lite MAC address program bit.
	{														//..Setting this bit and status bit configures the new Ethernet MAC..													
		if (x==1){											//..address for the core
		erhernet.TX_Pong_Control.p=1;							
		erhernet.TX_Pong_Control.s=1;
		}
		else if (x==0){
			erhernet.TX_Pong_Control.p=0;
		}
	}	
int set_Pong_buffer (struct Erhernet erhernet , char x ) // Transmit Pong buffer Receive status indicator
	{													//0 – Receive pong buffer is empty.
		if (x==0){erhernet.RX_Pong_Control.s=0;}		//AXI Ethernet Lite MAC can accept new available valid packet.
		else if (x==1){erhernet.RX_Pong_Control.s=1;}  //1 – Indicates presence of receive packet ready for software processing.
		else {return erhernet.RX_Pong_Control.s;}		//When the software reads the packet from the receive pong
	}													//buffer, the software must clear this bit
	
void set_Operation_Access(struct Erhernet erhernet, char x ){//Operation Access Type
	if (x ==0){erhernet.MDIOADDR.OP=0;}						//0 – Write Access
	else if (x==1){erhernet.MDIOADDR.OP=1;}					//1 – Read Access
	}
int Set_PHY_Device_Address(struct Erhernet erhernet, char x )//PHY device address
	{
		if (erhernet.MDIOADDR.OP==0)
			{
				int y:5 = x ; 
			erhernet.MDIOADDR.PHYADDR=y ;
			return erhernet.MDIOADDR.PHYADDR; 
		}
		else {
			return erhernet.MDIOADDR.PHYADDR;
		}
	}
int Set_PHY_Device_Address(struct Erhernet erhernet, char x )//PHY register address
	{
		if (erhernet.MDIOADDR.OP==0)
			{
				int y:5 = x ; 
			erhernet.MDIOADDR.REGADDR=y ;
			return erhernet.MDIOADDR.REGADDR; 
		}
		else {
			return erhernet.MDIOADDR.REGADDR;
		}
	}
int Set_MIDO_Write_Date(struct Erhernet erhernet, short int  x )//MDIO write data to be written to PHY register
	{
		if (erhernet.MDIOADDR.OP==0)
			{
			erhernet.MDIOWR.Write_Data=x ;
			return erhernet.MDIOWR.Write_Data; 
		}
		else {
			return erhernet.MDIOWR.Write_Data;
		}
	}
int MDIO_Read_Data	(struct Erhernet erhernet)
	{
	return	erhernet.MDIORD.Read_Data;
	}
void Set_MIDO_Enable(struct Erhernet erhernet,char x)//	MDIO enable bit
	{		if (x==0){erhernet.MDIOCTRL.e=0;}		 //0 – Disable MDIO interface
            else if(x==1){erhernet.MDIOCTRL.e=1;}	 //1 – Enable MDIO interface
	}														
void Set_MIDO_Status(struct Erhernet erhernet,char x)//MDIO status bit
	{		if (x==0){erhernet.MDIOCTRL.s=0;} 		 //0 – MDIO transfer is complete and core is ready to accept a new
            else if(x==1){erhernet.MDIOCTRL.=1;}     //MDIO request
													 //1 – MDIO transfer is in progress. Setting this bit initiates an
													 //MDIO transaction. When the MDIO transaction is complete, the
													 //AXI Ethernet Lite MAC core clears this bit.
	}