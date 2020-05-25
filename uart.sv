//////////////////////////////////////////////////////////////
// uart.sv - top level module for UART
//
//
// Description:
// ------------
// Instantiates and connects the uart transmitter, uart receiver, baud rate
// generator and the the transmit and receive FIFOs.
//
// 
////////////////////////////////////////////////////////////////
module uart
#(
	parameter DBIT = 8,      // # data bits
	parameter SB_TICK = 16,  // # ticks for 1 stop bit
	parameter FIFO_W = 2     // # addr bits of FIFO
)
(
   input logic 		   clk, reset,	// system clock and reset
	input logic [10:0]	dvsr,			// clock divisor for baud_gen
	
	// FIFO
   input  logic rd_uart, wr_uart,		// read a byte from and/or write to the FIFO
	output logic tx_full, rx_empty,		// FIFO full and empty flags for handshaking
	input  logic [7:0] w_data,			// data byte to transmit
   output logic [7:0] r_data,			// data byte received from top of the FIFO
	
	// serial port signals
	input  logic rx,						// Rx bit (next data bit to receive)
	output logic tx						// Tx bit (next data bit to send)	
);

// internal variables
logic tick, rx_done_tick, tx_done_tick;	// internal timing and counting
logic tx_empty, tx_fifo_not_empty;			// FIFO status
logic [7:0] tx_fifo_out, rx_data_out;		// FIFO data

//instantiate the modules in the block diagram
// ADD YOUR CODE HERE

//baud_generator
	baud_gen  
		baud_gen_unit (.clk(clk) , .reset(reset), .dvsr(dvsr), .tick(tick));

//uart_receiver
	uart_rx #(.DBIT(DBIT) , .SB_TICK (SB_TICK)) 
		uart_rx_unit(.clk(clk), .reset (reset), .rx(rx), .s_tick(tick), .rx_done_tick(rx_done_tick), 
						 .dout(rx_data_out));
 //fifo for receiver
	fifo #(.DATA_WIDTH(DBIT), .ADDR_WIDTH(FIFO_W)) 
			fifo_rx (.clk(clk), .reset(reset), .rd(rd_uart), .wr(rx_done_tick), 
							 .w_data(rx_data_out), .empty(rx_empty), .full(), .r_data(r_data));

//uart transmitter
	uart_tx #(.DBIT(DBIT) , .SB_TICK (SB_TICK)) 
		uart_tx_unit(.clk(clk), .reset (reset), .tx_start(tx_fifo_not_empty), .s_tick(tick), .din(tx_fifo_out),
						 .tx_done_tick(tx_done_tick), .tx(tx));
//fifo for transmitter
	fifo #(.DATA_WIDTH(DBIT), .ADDR_WIDTH(FIFO_W)) 
			fifo_tx (.clk(clk), .reset(reset), .rd(tx_done_tick), .wr(wr_uart), 
							 .w_data(w_data), .empty(tx_empty), .full(tx_full), .r_data(tx_fifo_out));

assign tx_fifo_not_empty = ~tx_empty;
endmodule: uart

