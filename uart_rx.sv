//////////////////////////////////////////////////////////////
// uart_rx.sv - UART Receiver
//
// 
////////////////////////////////////////////////////////////////
module uart_rx
#(
    parameter DBIT = 8,     // # data bits
              SB_TICK = 16  // # ticks for stop bits
)
(
    input  logic clk, reset,	   // system clock and reset (reset is asserted high)
    input  logic rx, s_tick,	   // rx is serial data bit.  s_tick is the oversampling pulse
    output logic rx_done_tick,	// done signal. asserted high for a single cycle
								         // when an entire packet has been received.
    output logic [7:0] dout		// parallel data out. contains bits from packet
);

// fsm state type 
typedef enum logic [1:0] {idle, start, data, stop} state_type;

// signal declaration
state_type state_reg, state_next;
logic [3:0] s_reg, s_next;	// counts the number of s_ticks to sample
							      // in the middle of a serial bit
logic [2:0] n_reg, n_next;	// counts the number of data bits received
logic [7:0] b_reg, b_next;	// shift register to store the received data bits

// FSMD state & data registers
always_ff @(posedge clk, posedge reset) begin: seq_block
	if (reset) 
	 begin
		state_reg <= idle;
		    s_reg <= 0;		
		    n_reg <= 0;		
		    b_reg <= 0;
	 end
	else 
	 begin
		state_reg <= state_next;
		    s_reg <= s_next;
	       n_reg <= n_next;
			 b_reg <= b_next;
	 end
end: seq_block

// FSMD next-state logic
always_comb begin: next_state_logic
	// give initial values to all variables so you don't have to
	// include them in every case item
		state_next = state_reg;
		rx_done_tick = 1'b0;
		s_next = s_reg;
		n_next = n_reg;
		b_next = b_reg;	

	// process the serial data packet
	case (state_reg)
		
		idle:	// wait for the start bit
			if (~rx) 
				begin
					state_next <= start;
					s_next = 0;
            end
			
		start:	// get the start bit
			
			//s_tick is the oversampling pulse from the baud rate generator
			if (s_tick)
				// sample in the middle of the start pulse
				if (s_reg == 7) 
					begin
						state_next = data;
						s_next = 0;
						n_next = 0;
				   end
				else
					// we don't sample the start bit until the middle of the bit
					s_next = s_reg + 1;
					
		data:	// get the data bits one at a time
			if (s_tick)
				// sample in the middle of the serial data bit
				if (s_reg == 15) 
					begin
						// got the bit - shift it into a data register
						s_next = 0;
						b_next = {rx, b_reg[7:1]};
						if (n_reg == (DBIT-1))
							// received all of the data bits
							state_next = stop ;
						else
							n_next = n_reg + 1;
					end
				else
					// sample the data bit in the middle
					s_next = s_reg + 1;
					
		stop:	// process the stop bit
            if (s_tick)
					if (s_reg == (SB_TICK-1)) 
						begin
						// middle of stop bit
							state_next = idle;
							rx_done_tick =1'b1;
						end
				else
					s_next = s_reg + 1;
      endcase
   end: next_state_logic
   
// move the data bits to the output register
assign dout = b_reg;
   
endmodule: uart_rx