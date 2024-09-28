`include "mips_defines.svh"

module exception_unit(/*AUTOARG*/
   // Outputs
   exception_halt, load_ex_regs, load_bva, cause, load_bva_sel,
   // Inputs
   pc, IBE, DBE, RI, Ov, BP, AdEL_inst, AdEL_data, AdES, CpU, clk,
   rst_b
   );

   	input            clk;
   	input            rst_b;
   		
   	input  [31:0]    pc;
	input            IBE;
	input            DBE;
	input            RI;
	input            Ov; 
	input            BP; 
	input            AdEL_inst;
	input            AdEL_data;
	input            AdES;
	input            CpU;

	output wire      exception_halt;
	output wire      load_ex_regs;
	output wire      load_bva;
	output reg [4:0] cause;
	output wire      load_bva_sel;

	assign exception_halt   = rst_b && (AdEL_inst || IBE);
	assign load_ex_regs     = rst_b && (IBE || DBE || RI || Ov || BP || AdEL_inst || AdEL_data || AdES || CpU);	
	assign load_bva         = rst_b && (AdEL_inst || AdEL_data || AdES || IBE || DBE);
	assign load_bva_sel     = AdEL_data || AdES || DBE;

	always @(*) begin
		cause = 0;
		
		case (1'b1)
		AdEL_inst: cause = `EX_ADEL;
		AdEL_data: cause = `EX_ADEL;
		AdES:      cause = `EX_ADES;
		IBE:       cause = `EX_IBE;
		DBE:       cause = `EX_DBE;
		CpU:       cause = `EX_CPU;
		RI:        cause = `EX_RI;
		Ov:        cause = `EX_OV;
		BP:        cause = `EX_BP;
		endcase
	end

	// synthesis translate_off
	always @(posedge clk or negedge rst_b) begin
		if (rst_b) begin
			// Address errors take priority over bus errors.
			// Coprocessor exceptions take priority over reserved instruction
			//   exceptions.
			// Instruction bus/address errors are fatal.
			if(AdEL_inst == 1'b1)
				$display(`MSG_ADEL_S, pc);
			else if(AdEL_data == 1'b1)
				$display(`MSG_ADEL_S, pc);
			else if(AdES == 1'b1)
				$display(`MSG_ADES_S, pc);
			else if(IBE == 1'b1)
				$display(`MSG_IBE_S, pc);
			else if(DBE == 1'b1)
				$display(`MSG_DBE_S, pc);
			else if(CpU == 1'b1)
				$display(`MSG_CPU_S, pc);
			else if(RI == 1'b1)
				$display(`MSG_RI_S, pc);
			else if(Ov == 1'b1)
				$display(`MSG_OV_S, pc);
			else if(BP == 1'b1)
				$display(`MSG_BP_S, pc);
		end
	end
	// synthesis translate_on

endmodule
