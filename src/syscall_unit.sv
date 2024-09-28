`include "mips_defines.svh"


module syscall_unit(/*AUTOARG*/
   // Outputs
   syscall_halt,
   // Inputs
   pc, r_v0, Sys, rst_b, clk
   );
	output wire        syscall_halt;
	input       [31:0] pc, r_v0;
	input 	           Sys, rst_b, clk;
	
	assign 	syscall_halt = rst_b && Sys && (r_v0 == `SYS_EXIT);

	// synthesis translate_off
	always @(posedge clk)
		if (rst_b && Sys)
			case(r_v0)
			`SYS_EXIT: begin
				$display(`MSG_EOP_S, pc);
			end
			endcase
	// synthesis translate_on
endmodule
