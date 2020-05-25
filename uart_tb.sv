//////////////////////////////////////////////////////////////////////////////
// uart_tb.sv - Test bench for UART Design from Pong Chu book  
//
// Date:	5/19/2020 
//
// Description:
// ------------
// Unit level Test bench for UART Design from Pong Chu book 
// which generates all characters from 0x00 to 0x7F in TX RX loopback test
////////////////////////////////////////////////////////////////////////////

module uart_tb;

	timeunit 1ns;
	timeprecision 1ps;
	parameter SYS_CLK_FREQ  = 50000000; 		    	// Assume 50 MHz system clk					 
	parameter BAUD_RATE	= 19200;
	localparam TICKS	= SYS_CLK_FREQ/BAUD_RATE;	// For baud rate of 19200Hz, TICKS = 2604
	localparam DVSR		= SYS_CLK_FREQ/BAUD_RATE/16;	// divisor for setting baud rate
			
	parameter CLK_PERIOD 	= 20;				// 50 MHz clock means 20ns clk period 
	parameter CYCLES        = 10;
	parameter LOOP          = 20;
	parameter DBIT 			= 8;       			//  data bits
	parameter SB_TICK 		= 16;   			//  ticks for 1 stop bit
    parameter FIFO_W 	= 2;     			//  addr bits of FIFO

	logic clk, reset;
	logic [10:0] dvsr; 
   	logic rd_uart, wr_uart;		
	logic tx_full, rx_empty;	
	logic [7:0] w_data;			
   	logic [7:0] r_data;			
	logic rx;						
	logic tx;	

	// test variables
	bit [7:0] exp_data;
	bit rx_fail = 0;
	int error_count = 0;
	int test_count  = 0;

	// UART Design instantiation
	uart #(.DBIT(DBIT) , .SB_TICK (SB_TICK), .FIFO_W(FIFO_W)) UART_DUT (.*);

	// Clock generation
	initial begin
		clk = 0;
		forever #(CLK_PERIOD/2) clk = ~clk;
	end

	// UART run test
	initial begin
		run_test();
	end

	// UART test methods used in the test bench
	// UART run task
	task run_test();
		apply_reset();
		set_baud_rate(DVSR);		
		// generate all characters from 0x00 to 0x7f
		for(int i = 0; i < 128; i++) begin
			uart_loopback_test(i);
			test_count++;
		end
		if(error_count == 0) 
			$display("TX RX Loopback %0d tests PASSED!!!", test_count);
		else
			$display("TX RX Loopback test FAILED with %0d errors!!!", error_count);
		$display("Time = %0t:\t END OF UART TEST!!!", $time);
		$stop;
	endtask : run_test

	// Apply and lift reset after some time so that signals get settled to known values
	task apply_reset();
		reset = 1;
		#(10*CYCLES) reset = 0;
	endtask : apply_reset

	// set baud rate using dvsr register
	// Assuming we want baud rate of 9600 Hz  or bps, we need to divide reference clock by 9600 and further we are dividing it
	// by 16 (which is 65) so that we get the ticks to have 16 times the frequency of the UART signal 
	task set_baud_rate(input int data);
		dvsr = data; 
	endtask : set_baud_rate
	
	//  uart rx tx loopback test
	task uart_loopback_test(input bit [7:0] data);
		  // RX test
		  // reverse data (using streaming operator) as it sent in little endian way d0-d7
		  exp_data = {<<{data}};
		  // make RX line idle
		  rx = 1'b1;
		  repeat(2*TICKS)@(posedge clk);
		  // set start bit by making RX line low to start Receiving data
		  rx = 1'b0;
		  repeat(TICKS)@(posedge clk);
		  foreach(exp_data[i]) begin
		  	rx = exp_data[i];
		  	repeat(TICKS)@(posedge clk);
		  end // end of foreach loop 
		  // set stop bit by making RX line high and keep it idle
		  rx = 1'b1;
		  // wait for data to reflect on r_data pin
		  repeat(TICKS)@(posedge clk);
		  // reverse exp_data so that it matches the r_data
		  exp_data = {<<{exp_data}};
		  // check if data received matches expected value
		  if(r_data !== exp_data) begin
		  	$display("***RX FAILED with Expected data = %0h \t Actual data = %0h!!!***", exp_data, r_data);
		  	rx_fail = 1;
		  	error_count++;
		  end

		 // TX test
		 if(rx_fail != 1) begin
			// copy r_data to w_data for TX
			w_data = r_data;
			// enable wr_uart to transmit data
			wr_uart = 1'b1;
			repeat(10)@(posedge clk);
			wr_uart = 1'b0;
			// wait for TX to complete
			repeat(10*TICKS)@(posedge clk);
	 	 end	// end of rx_fail if block

	endtask : uart_loopback_test


endmodule : uart_tb
