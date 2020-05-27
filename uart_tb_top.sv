/////////////////////////////////////////////////////////////////////////////
// uart_tb_top.sv - Top level Test bench for UART Design  
//
// Date:	5/19/2020 
//
// Description:
// ------------
// Top level Test bench for UART Design 
// which generates all characters from 0x00 to 0x7F in TX RX loopback test  
//////////////////////////////////////////////////////////////////////////////

module uart_tb_top;

	timeunit 1ns;
	timeprecision 1ns;
	
	parameter SYS_CLK_FREQ  = 50000000; 		    	// Assume 50 MHz system clk					 
	parameter BAUD_RATE		= 19200;
	localparam TICKS		= SYS_CLK_FREQ/BAUD_RATE;	    // For baud rate of 19200Hz, TICKS = 2604
	localparam DVSR			= SYS_CLK_FREQ/BAUD_RATE/16;	// divisor for setting baud rate
			
	parameter CLK_PERIOD 	= 20;				        // 50 MHz clock implies 20ns clk period 
	parameter CYCLES        = 10;
	parameter LOOP          = 20;

	logic clk, reset;
    	// UART Design signals
    	logic cs;
    	logic read;
    	logic write;
    	logic [4:0] addr;
    	logic [31:0] wr_data;
    	logic [31:0] rd_data;
    	logic tx;
    	logic rx;
	
	// test variables
	bit [31:0] data;
	bit [7:0] exp_data;
	bit [7:0] tx_data;
	bit [7:0] rx_data;
	int error_count = 0;
	int test_count  = 0;
	bit rx_fail = 0;
	
	// UART Top level Design instantiation
	uart_top #(8) UART_DUT (.*);

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
		repeat(TICKS)@(posedge clk);
		set_baud_rate(DVSR);		
		repeat(TICKS)@(posedge clk);
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
	
	// Apply and lift reset after some time CYCLES so that signals get settled to known values.
	task apply_reset();
		reset = 1;
		#(10*CYCLES) reset = 0;
	endtask : apply_reset
	
	// set baud rate using dvsr register
	task set_baud_rate(input int dvsr);
		cs 	      = 1'b1;
		addr[1:0] = 2'b01;
		addr[4:2] = $urandom;
		write     = 1'b1;
		wr_data   = dvsr;
	endtask : set_baud_rate
	
	// read data and status
	task read_data_uart();
		cs 	  = 1'b1;
		addr[1:0] = 2'b11;
		addr[4:2] = $urandom;
		write     = 1'b1;  	
 		repeat(CYCLES)@(posedge clk);
		write     = 1'b0;  	
	endtask : read_data_uart
	
	// write data
	task write_data_uart(input bit [7:0] data);
		cs 	  = 1'b1;
		addr[1:0] = 2'b10;
		addr[4:2] = $urandom;
		write     = 1'b1;	
		wr_data   = {$urandom, data};
 		repeat(CYCLES)@(posedge clk);
		write     = 1'b0;  	
	endtask : write_data_uart	
	
	//  uart rx tx loopback test
	task uart_loopback_test(input bit [31:0] data);
		 // RX test
		 // configure UART for RX
		 read_data_uart();
		 // reverse data (using streaming operator) as it sent in little endian way d0-d7
		 exp_data = {<<{data[7:0]}};
		 // make RX line idle
		 rx = 1'b1;
		 repeat(2*TICKS)@(posedge clk);
		 // set start bit by making RX line low to start receiving data
		 rx = 1'b0;
		 repeat(TICKS)@(posedge clk);
		 foreach(exp_data[i]) begin
		 	rx = exp_data[i];
		 	repeat(TICKS)@(posedge clk);
		 end // end of foreach loop 
		 // set stop bit by making RX line high and keep it idle
		 rx = 1'b1;
		 // wait for data to reflect on rd_data pin after RX FIFO de-asserts empty flag
		 wait(rd_data[8] == 0);
		 // copy r_data to w_data for TX
		 tx_data = rd_data[7:0];
		 // reverse exp_data so that it matches the r_data
		 exp_data = {<<{exp_data}};
		 // check if data received matches expected value
		 if(rd_data[7:0] !== exp_data) begin
		 	$display("***RX FAILED with Expected data = %0h \t Actual data = %0h!!!***", exp_data, rd_data[7:0]);
		 	rx_fail = 1;
		 	error_count++;
		 end

		 // TX test
		 if(rx_fail != 1) begin
			// enable wr_uart to transmit data
			write_data_uart(tx_data);
			// wait for TX to complete
			repeat(10*TICKS)@(posedge clk);
	 	 end	// end of rx_fail if block

	endtask : uart_loopback_test

endmodule : uart_tb_top
