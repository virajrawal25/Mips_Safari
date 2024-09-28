// Include the MIPS constants
`include "mips_defines.svh"
`include "internal_defines.svh"

module mips_decode(/*AUTOARG*/
   // Outputs
   dcd_imm_ID,dcd_e_imm_ID,dcd_se_imm_ID,dcd_shamt_ID,dcd_se_offset_ID,ctrl_we_ID, ctrl_Sys_ID, ctrl_RI_ID,ctrl_unsigned_ID,ctrl_shift_ID,ctrl_jump_and_link_ID,ctrl_reg_imm_data_ID,ctrl_operation_type_ID, alu__sel_ID,
   // Inputs
   inst_out_ID,  clk, rst_b 
   );

    input               clk;
    input               rst_b;

    // IF/ID
    input   [31:0]      inst_out_ID;

    // ID/EX
    output  [15:0]      dcd_imm_ID;
    output  [31:0]      dcd_e_imm_ID;  
    output  [31:0]      dcd_se_imm_ID;         // Sign Extended Immediate Data
    output  [4:0]       dcd_shamt_ID;          // Shift Amount
    output  [31:0]      dcd_se_offset_ID;      // Sign Extended Offset

    output reg          ctrl_we_ID;
    output reg          ctrl_Sys_ID;
    output reg          ctrl_RI_ID;
    output reg          ctrl_unsigned_ID;
    output reg          ctrl_shift_ID;
    output reg          ctrl_jump_and_link_ID;
    output reg          ctrl_reg_imm_data_ID;
    output reg  [4:0]   ctrl_operation_type_ID;
    output reg  [3:0]   alu__sel_ID;




    // Decode signals
    logic [31:0]     dcd_se_mem_offset;  // Sign Extended Memory Offset

    logic [5:0]      dcd_op;
    logic [4:0]      dcd_rt;
    logic [5:0]      dcd_funct2;

    logic [15:0]     dcd_offset;         // Offset value

    logic [25:0]     dcd_target;
    logic [19:0]     dcd_IDode;

// inst_outruction decoding



   assign        dcd_op             = inst_out_ID[31:26];  // Opcode
   assign        dcd_rt             = inst_out_ID[20:16];  // rt field
   assign        dcd_shamt_ID       = inst_out_ID[10:6];   // Shift amount
   assign        dcd_funct2         = inst_out_ID[5:0];    // funct field; secondary opcode
   assign        dcd_offset         = inst_out_ID[15:0];   // offset field

// Sign-extended offset for branches
   assign        dcd_se_offset_ID   = { {14{dcd_offset[15]}}, dcd_offset, 2'b00 };

// Sign-extended offset for load/store
   assign        dcd_se_mem_offset  = { {16{dcd_offset[15]}}, dcd_offset };
   assign        dcd_imm_ID         = inst_out_ID[15:0];           // immediate field
   assign        dcd_e_imm_ID       = { 16'h0, dcd_imm_ID };   // zero-extended immediate

// Sign-extended immediate
   assign        dcd_se_imm_ID      = { {16{dcd_imm_ID[15]}}, dcd_imm_ID };
   assign        dcd_target         = inst_out_ID[25:0];           // target field
   assign        dcd_code           = inst_out_ID[25:6];           // Breakpoint code




   always @(*) begin
     alu__sel_ID       		= 4'hF;
     ctrl_we_ID        		= 1'b0;
     ctrl_Sys_ID       		= 1'b0;
     ctrl_RI_ID        		= 1'b0;
     ctrl_unsigned_ID  		= 1'b0;
     ctrl_reg_imm_data_ID  	= 1'b0;
     ctrl_operation_type_ID = 5'b0;
     ctrl_jump_and_link_ID  = 1'b0;
     ctrl_shift_ID          = 1'b0;
     case(dcd_op)
       `OP_OTHER0: begin
         ctrl_reg_imm_data_ID = 1'b0;
         case(dcd_funct2)
           `OP0_SYSCALL:
                ctrl_Sys_ID = 1'b1;
           `OP0_ADD, `OP0_ADDU:
                begin
                    alu__sel_ID = `ALU_ADD;
                    ctrl_we_ID 	= 1'b1;
                end

           `OP0_SUB, `OP0_SUBU:
                begin
                    alu__sel_ID = `ALU_SUB;
                    ctrl_we_ID 	= 1'b1;
                end
                
           `OP0_SLT:
                begin
                    alu__sel_ID = `ALU_LESS_THAN;
                    ctrl_we_ID 	= 1'b1;
                end

           `OP0_AND:
                begin
                    alu__sel_ID = `ALU_AND;
                    ctrl_we_ID 	= 1'b1;
                end
           `OP0_XOR:
                begin
                    alu__sel_ID = `ALU_XOR;
                    ctrl_we_ID 	= 1'b1;

                end
           `OP0_NOR:
                begin
                    alu__sel_ID = `ALU_NOR;
                    ctrl_we_ID 	= 1'b1;

                end
           `OP0_OR:
                begin
                    alu__sel_ID = `ALU_OR;
                    ctrl_we_ID 	= 1'b1;

                end

           `OP0_SLL, `OP0_SLLV:
                begin
                    alu__sel_ID 	= `ALU_SHIFT_LEFT;
                    ctrl_shift_ID 	= 1'b1;
                    ctrl_we_ID 		= 1'b1;

                end

           `OP0_SRA:
                begin
                    alu__sel_ID 	= `ALU_SHIFT_RIGHT;
                    ctrl_shift_ID 	= 1'b1;
                    ctrl_we_ID 		= 1'b1;

                end
           `OP0_SRAV:
                begin
                    alu__sel_ID 	= `ALU_SHIFT_RIGHT;
                    ctrl_shift_ID 	= 1'b1;
                    ctrl_we_ID 		= 1'b1;

                end
           `OP0_SRL:
                begin
                    alu__sel_ID 	= `ALU_SHIFT_RIGHT;
                    ctrl_shift_ID 	= 1'b1;
                    ctrl_we_ID 		= 1'b1;

                end
           `OP0_SRLV:
                begin
                    alu__sel_ID 	= `ALU_SHIFT_RIGHT;
                    ctrl_shift_ID 	= 1'b1;
                    ctrl_we_ID 		= 1'b1;

                end
           `OP0_JALR, `OP0_JR:
                begin
                    ctrl_operation_type_ID 	= 5'h12;
                    ctrl_we_ID 				= (dcd_funct2==`OP0_JALR);
                end

           default:
                ctrl_RI_ID = 1'b1;
         endcase
        end

        `OP_ADDIU, `OP_ADDI:
                begin
                    alu__sel_ID 			= `ALU_ADD;
                    ctrl_we_ID				= 1'b1;
                    ctrl_reg_imm_data_ID 	= 1'b1;
                    ctrl_unsigned_ID 		= 1'b0;//(dcd_op==`OP_ADDIU);
                end

        `OP_SLTI, `OP_SLTIU:
                begin
                    alu__sel_ID 			= `ALU_LESS_THAN;
                    ctrl_we_ID 				= 1'b1;
                    ctrl_reg_imm_data_ID 	= 1'b1;
                end

        `OP_SB ,`OP_SH, `OP_SW, `OP_LB,`OP_LBU, `OP_LH, `OP_LHU, `OP_LW:
                 begin
                    alu__sel_ID = `ALU_LOAD_STORE;
                    ctrl_operation_type_ID  = ((dcd_op==`OP_SB )?5'h1:
                                               (dcd_op==`OP_SH )?5'h2:
                                               (dcd_op==`OP_SW )?5'h3:
                                               (dcd_op==`OP_LB )?5'h4:
                                               (dcd_op==`OP_LBU)?5'h5:
                                               (dcd_op==`OP_LH )?5'h6:
                                               (dcd_op==`OP_LHU)?5'h7:
                                               (dcd_op==`OP_LW )?5'h8:0); 
                    ctrl_we_ID 				= ((dcd_op==`OP_LB) || 
											   (dcd_op==`OP_LBU) || 
											   (dcd_op==`OP_LH) || 
											   (dcd_op== `OP_LHU) || 
											   (dcd_op== `OP_LW));
                    ctrl_reg_imm_data_ID 	= 1'b1;
                end
   
        `OP_LUI:
                 begin
                    ctrl_we_ID = 1'b1;
                    ctrl_operation_type_ID 	= (dcd_op==`OP_LUI)?5'h9:0;
                    ctrl_reg_imm_data_ID 	= 1'b1;
                end


        `OP_ANDI:
                begin
                    alu__sel_ID 			= `ALU_AND;
                    ctrl_we_ID 				= 1'b1;
                    ctrl_unsigned_ID 		= 1'b1;
                    ctrl_reg_imm_data_ID 	= 1'b1;
                end

        `OP_ORI:
                begin
                    alu__sel_ID 			= `ALU_OR;
                    ctrl_we_ID 				= 1'b1;
                    ctrl_unsigned_ID 		= 1'b1;
                    ctrl_reg_imm_data_ID 	= 1'b1;
                end

        `OP_XORI:
                begin
                    alu__sel_ID 			= `ALU_XOR;
                    ctrl_we_ID 				= 1'b1;
                    ctrl_unsigned_ID 		= 1'b1;
                    ctrl_reg_imm_data_ID 	= 1'b1;
                end


        `OP_J, `OP_JAL:
                begin
                    ctrl_operation_type_ID 	= 5'h11;
                    ctrl_jump_and_link_ID 	= 1'b1;
                    ctrl_we_ID 				= (dcd_op==`OP_JAL);
                end

        `OP_BEQ, `OP_BNE:
                begin
                    alu__sel_ID 			= `ALU_XOR;
                    ctrl_operation_type_ID 	= (dcd_op==`OP_BEQ)?5'h13:(dcd_op==`OP_BNE)?5'h14:0;
                end


        `OP_BLEZ, `OP_BGTZ:
                begin
                    ctrl_operation_type_ID 	= {1'b1,dcd_op[3:0]};
                end

        `OP_OTHER1: 
                begin
                case(dcd_rt)
                `OP1_BLTZ, `OP1_BLTZAL:
                    begin
                        ctrl_operation_type_ID 	= 5'h15;
                        ctrl_jump_and_link_ID 	= (dcd_rt==`OP1_BLTZAL);
                    end

                `OP1_BGEZ, `OP1_BGEZAL: 
                    begin
                        ctrl_operation_type_ID 	= 5'h18;
                        ctrl_jump_and_link_ID 	= (dcd_rt==`OP1_BGEZAL);
                    end
             


                default:
                    ctrl_RI_ID = 1'b1;
                endcase
                end



       default:
         begin
            ctrl_RI_ID = 1'b1;
         end
     endcase // case(op)
   end


  



endmodule
