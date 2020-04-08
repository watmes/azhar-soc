//#include <stdio.h>
//#include <stdint.h>
//#include <string.h>
#define UART_base 0x10000000
#define SAMPLING_RATE 16




#include <sbi/riscv_io.h>
#include <sbi_utils/serial/uart8250.h>


struct IER {                          //interrupt enable register.
	uint8_t  EN_RX_D_V:1;                    //bit(0)=>enable received data available interrupt.
	uint8_t  EN_TX_H:1;                      //bit(1)=>enable transmitter holding register empty interrupt.
	uint8_t EN_RX_L:1;                      //bit(2)=>enable receiver line status interrupt.
	uint8_t  EN_M:1;                         //bit(3)=>enable modem status interrupt.
	uint8_t  unused:4;
};
struct IIR{                           //interrupt identification register.
	uint8_t IN_P:1;                          //bit(0)=>interrupt pending.
	uint8_t MIX_1:1;                           ///(011)=>receiver line status interrupt parity ,data overrun,or framing error ,or break interrupt
    uint8_t MIX_2:1;              ///         (010)=>receiver data avilable receiver FIFO trigger level reached
    uint8_t MIX_3:1;                          ///(110)=>timeout indication   (001)=>transmit hold register empty   (000)=>modem status interrupt
                                           /// (4,5,7)=>unused.*/
    uint8_t RESERVED_4:1;
    uint8_t RESERVED_5:1;                                     	//ALWAYS =00.
    uint8_t FIFO_EN_6:1;               //These two bits are set when FCR0=1.
	uint8_t FIFO_EN_7:1;
};
struct FCR{                          //FIFO control register
	uint8_t EN_FIFO:1;
    uint8_t RX_FIFO_RESET:1;
    uint8_t TX_FIFO_RESET:1;
    uint8_t DMA_MODE:1;
    uint8_t RESER_IGNORED_4:1;
	uint8_t RESER_IGNORED_5:1;
    uint8_t RX_FIFO_TRIGGER_6:1;
	uint8_t RX_FIFO_TRIGGER_7:1;
};
struct LCR{                        //line control register.
    uint8_t W_L_0:1;                        //word lenth select.
	uint8_t W_L_1:1;                        //word lenth select.
	uint8_t NUMBER_STOP:1;                //number of stop bits.
	uint8_t P_EN:1;                       //parity enable.
	uint8_t EVEN_P:1;                     //even parity.
	uint8_t STICK_P:1;                    //stick parity ignored.
	uint8_t S_BRAKE:1;
	uint8_t D_LATCH:1;                    //divisor latch.
};
struct MCR{                        //modem control register.
    uint8_t DTRN:1;                       // This bit controls the Data Terminal Ready (DTR) output     "bit is inverted to drive pin."
	uint8_t RTSN:1;                       //This bit controls the Request to Send (RTS) output.          "bit is inverted to drive pin."
	uint8_t OUT1N:1;                      //This bit controls the Output 1 (OUT 1) signal.
	uint8_t OUT2N:1;                      //This bit controls the Output 2 (OUT 2) signal.
	uint8_t L_B_M:1;                     // This bit provides a local loopback feature for diagnostic testing of the UART.  "loop back mode."
	uint8_t IGNO_5:1;                      //These bits are permanently set to logic 0.
	uint8_t IGNO_6:1;                      //These bits are permanently set to logic 0.
	uint8_t IGNO_7:1;                      //These bits are permanently set to logic 0.
};
struct LSR{                       //line status register.
    uint8_t DATA_READY:1;
	uint8_t ERROR:1;                     //overrun error.
	uint8_t P_ERROE:1;
	uint8_t F_ERROE:1;                   //framing error.
	uint8_t B_IN:1;                      //break interrupt.
	uint8_t TX_H:1;                      //transmitter holding register.
	uint8_t TX_EMPTY:1;
	uint8_t ERROR_RECEIVE_FIFO:1;
};
struct MSR{                       //modem status register.
    uint8_t D_CLEAR:1;                   //delta clear to send.
	uint8_t D_SET:1;                     //delta data set ready.
	uint8_t T_EDGE:1;                    //trailing edge ring indicator.
	uint8_t D_CARRIER:1;                 //delta data carrier detect.
	uint8_t CLEAR:1;                     //clear to send.
	uint8_t DATA_SET:1;                  //data set ready.
	uint8_t RING:1;                      //ring indicator.
	uint8_t DATA_DETECT:1;               //data carrier detect.
};
union U1{
	struct IIR    IIR_;
	struct FCR    FCR_;
	uint8_t WR_FCR;
};
union u2{
	struct IER    IER_;
	uint8_t DLM;
	uint8_t write_value;
};
union u3{
	uint8_t RBR;
	uint8_t THR;
	uint8_t DLL;
};
union U4{
	struct LCR   LCR_;
	uint8_t WR_LCR;
};
union U5{
	struct MCR  MCR_;
	uint8_t  WR_MCR;
};
union U6{
	struct LSR  LSR_;
	uint8_t WR_LSR;
};
union U7{
	struct MSR  MCR_;
	uint8_t WR_MCR;
};

struct UART{
	union u3       ADDRESS0_RBR;
	union u2       ADDRESS1_DLM;
	union U1       ADDRESS2_IIR;
	union U4    ADDRESS3_LCR;
	union U5     ADDRESS4_MCR;
	union U6     ADDRESS5_LSR;
	union U7     ADDRESS6_MSR;
	uint8_t      WR_SCR;
	uint8_t      MDR1;
};

struct UART_HW {
	volatile struct UART * hw;
} uart_instance;

void uart8250_putc(char ch){
while( (uart_instance.hw->ADDRESS5_LSR.LSR_.TX_H ) == 0)
		;
	uart_instance.hw->ADDRESS0_RBR.RBR=ch;
		
	}
	


int uart8250_getc(void){
	if( uart_instance.hw->ADDRESS5_LSR.LSR_.DATA_READY == 1)
		return uart_instance.hw->ADDRESS0_RBR.RBR;
	return -1;
}
uint8_t uart8250_init(unsigned long base, uint32_t in_freq,
		  uint32_t baudrate, uint32_t reg_shift,
		  uint32_t reg_width) {
			  
			  uart_instance.hw = (struct UART *) base;
	uint16_t bdiv;
	bdiv = in_freq / (16 *baudrate);
	///disable enable enterrupt
	uart_instance.hw->ADDRESS1_DLM.write_value = 0;
	uart_instance.hw->ADDRESS3_LCR.WR_LCR = 0x80;
	uart_instance.hw->ADDRESS0_RBR.DLL = bdiv & 0xff;
	uart_instance.hw->ADDRESS1_DLM.DLM = (bdiv >> 8) & 0xff;
	uart_instance.hw->ADDRESS3_LCR.WR_LCR = 0x3;
	uart_instance.hw->ADDRESS2_IIR.WR_FCR = 1;
	uart_instance.hw->ADDRESS4_MCR.WR_MCR = 0;
	uint8_t temp_read;
	temp_read = uart_instance.hw->ADDRESS5_LSR.WR_LSR;
	temp_read = uart_instance.hw->ADDRESS0_RBR.RBR;
	uart_instance.hw->WR_SCR = 0;
	
	
   return (uint8_t) temp_read;
}

