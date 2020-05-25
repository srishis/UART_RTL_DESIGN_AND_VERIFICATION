//////////////////////////////////////////////////////////////
// baud_gen.sv - baud rate generator for UART
//
// 
////////////////////////////////////////////////////////////////
module baud_gen (
    input  logic clk, reset,		// system clock and reset
    input  logic [10:0] dvsr,		// divisor for the clock divider
    output logic tick				// one cycle sampling clock signal
);

// internal variables
logic [10:0] r_reg;
logic [10:0] r_next;

// Baud rate counter
always_ff @(posedge clk, posedge reset) begin: counter
	// sequential logic
		if (reset)
			r_reg <= 0;
		else
			r_reg <= r_next;
end: counter

// note: The Sampling rate is set to 16 times the baud rate, which means that each
// serial bit is sampled 16 times.
// dvsr = clk/(16*baudrate).

// next-state logic - clear counter when counter == devisor
// otherwise increment the counter
assign r_next = (r_reg == dvsr-1) ? 0 : r_reg + 1;

// output logic - one cycle "tick" when counter has counted down to 1 (verify this?)
assign tick = (r_reg == dvsr-1) ? 1 : 0; //generate 'tick' on each maximum count
													  // dvsr = 2, then dvsr-1 = 1
endmodule: baud_gen