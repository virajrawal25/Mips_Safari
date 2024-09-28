// Include the MIPS constants
`include "mips_defines.svh"
`include "internal_defines.svh"



module mips_fetch(/*AUTOARG*/
   // Outputs
   inst_addr_PC, inst_out_IF,  nextpc_IF, flush, 
   // Inputs
   clk, rst_b, inst_excpt, inst, stall,ctrl_operation_type_EX,inst_addr_jump_branch_EX 
   );
  
    parameter text_start  = 32'h00400000; /* Initial value of $pc */

    // Core Interface
    input            clk;
    input            rst_b;

    // Instruction Fetch Interface
    input  [31:0]    inst;
    input            inst_excpt;
    input            stall;
    input  [4:0]     ctrl_operation_type_EX;
    input  [31:0]    inst_addr_jump_branch_EX;


    output [29:0]    inst_addr_PC;
    output [31:0]    inst_out_IF;
    output [31:0]    nextpc_IF;             // Next Program Counter
    output           flush;
    

    logic [31:0]     nextnextpc;         // Next Next Program Counter
    logic [31:0]     pc_int;
    logic [31:0]     nextpc_int;
    logic [31:0]     pc_int_saved;
    logic            branch_taken;
    logic            branch_not_taken;

    logic            br_pred_taken;
    logic            br_pred_not_taken;
    logic            br_pred_taken_ID;
    logic            br_pred_not_taken_ID;
    logic            br_pred_taken_EX;
    logic            br_pred_not_taken_EX;
    logic [29:0]     branch_prediction_addr;
    logic [29:0]     branch_prediction_addr_ID;
   // PC Management
  // register #(32, text_start)   PCReg       (clk, rst_b, ~internal_halt, nextpc, pc);
   
 //  register #(32, text_start+4) PCReg2      (clk, rst_b, ~internal_halt, nextnextpc, nextpc);

 //  add_const #(4)               NextPCAdder (nextnextpc, nextpc_int);


//   
        assign          branch_taken    = ctrl_operation_type_EX[4] && (inst_addr_jump_branch_EX>0);
        assign          branch_not_taken= ctrl_operation_type_EX[4] && (inst_addr_jump_branch_EX==0);

        assign          flush           = ((br_pred_taken_EX && branch_not_taken) || (br_pred_not_taken_EX && branch_taken));

        assign          inst_addr_PC    =  (br_pred_taken_ID ? branch_prediction_addr_ID     :((br_pred_taken_EX && branch_not_taken) ? pc_int_saved[31:2]    :((br_pred_not_taken_EX && branch_taken) ? inst_addr_jump_branch_EX[31:2]   :pc_int[31:2]    )));
        assign          nextpc_IF       = {(br_pred_taken_ID ? branch_prediction_addr_ID + 1 :((br_pred_taken_EX && branch_not_taken) ? pc_int_saved[31:2] + 1:((br_pred_not_taken_EX && branch_taken) ? inst_addr_jump_branch_EX[31:2]+1 :nextpc_int[31:2]))),2'b00};
       
     //   assign          inst_addr_PC    =   branch_taken ? inst_addr_jump_branch_EX[31:2]   : pc_int[31:2]    ;
     //   assign          nextpc_IF       = {(branch_taken ? inst_addr_jump_branch_EX[31:2]+1 : nextpc_int[31:2]),2'b00};
        assign          inst_out_IF     = inst;
        assign          nextnextpc      = nextpc_IF + 4;


   always @(posedge clk, negedge rst_b) begin
       if(!rst_b) begin
            pc_int           			<= text_start;
            nextpc_int       			<= text_start + 4;
            br_pred_taken_ID 			<= 'b0; 
            br_pred_taken_EX 			<= 'b0;
            br_pred_not_taken_ID 		<= 'b0;
            br_pred_not_taken_EX 		<= 'b0;
            branch_prediction_addr_ID 	<= branch_prediction_addr;;;
            pc_int_saved     			<= text_start;

       end
       else if(!stall) begin
            pc_int           			<= {(br_pred_taken_ID ? branch_prediction_addr_ID + 1 :((br_pred_taken_EX && branch_not_taken) ? pc_int_saved[31:2] + 1:((br_pred_not_taken_EX && branch_taken) ? inst_addr_jump_branch_EX[31:2]+1 :nextpc_int[31:2]))),2'b00};
            nextpc_int       			<= {(br_pred_taken_ID ? branch_prediction_addr_ID + 2 :((br_pred_taken_EX && branch_not_taken) ? pc_int_saved[31:2] + 2:((br_pred_not_taken_EX && branch_taken) ? inst_addr_jump_branch_EX[31:2]+2 :nextnextpc[31:2]))),2'b00};
            
            //pc_int           <=  branch_taken ? inst_addr_jump_branch_EX+4:nextpc_int;
            //nextpc_int       <=  branch_taken ? inst_addr_jump_branch_EX+8:nextnextpc;
            br_pred_taken_ID 			<= br_pred_taken;
            br_pred_taken_EX 			<= br_pred_taken_ID;
            br_pred_not_taken_ID 		<= br_pred_not_taken;
            br_pred_not_taken_EX 		<= br_pred_not_taken_ID;
            branch_prediction_addr_ID 	<= branch_prediction_addr;
            if(br_pred_taken)
                pc_int_saved    		<= nextpc_int;
        end
   end


 mips_branch_prediction U_branch_prediction( .* );

  
endmodule


