// Include the MIPS constants
`include "mips_defines.svh"
`include "internal_defines.svh"

module mips_branch_prediction(/*AUTOARG*/
   // Outputs
   br_pred_taken,br_pred_not_taken, branch_prediction_addr, 
   // Inputs
   clk, rst_b,inst_addr_PC, inst, branch_taken 
   );

      // Core Interface
    input            clk;
    input            rst_b;

    // Instruction Fetch Interface
    input  [29:0]    inst_addr_PC;
    input  [31:0]    inst;
    input            branch_taken;


    output           br_pred_taken;
    output           br_pred_not_taken;
    output [29:0]    branch_prediction_addr;

    parameter       GHR_W=2;



    logic [5:0]      dcd_op;
    logic [4:0]      dcd_rt;
    logic [4:0]      dcd_funct1;
    logic [5:0]      dcd_funct2;

    logic            uncond_jump;
    logic            cond_branch;
    logic [1:0]      branch_prediction;
    logic [GHR_W-1:0] global_history_register;
    logic [1:0]      pattern_history_table[4096];
    logic            jump_branch_ID,jump_branch_EX;
    logic            cache_hit,cache_hit_ID, cache_hit_EX;
    logic            cache_miss,cache_miss_ID, cache_miss_EX;
    logic [29:0]     inst_addr_PC_ID,inst_addr_PC_EX;


   assign        dcd_op             = inst[31:26];  // Opcode
   assign        dcd_funct1         = inst[4:0];    // Coprocessor 0 function field
   assign        dcd_funct2         = inst[5:0];    // funct field; secondary opcode
   assign        dcd_rt             = inst[20:16];  // rt field

   assign        uncond_jump        = ((dcd_op == `OP_OTHER0) && ((dcd_funct2==`OP0_JALR) || (dcd_funct2==`OP0_JR)) || (dcd_op == `OP_J) || (dcd_op == `OP_JAL));
   assign        cond_branch        = ((dcd_op == `OP_BEQ) || (dcd_op == `OP_BNE) || (dcd_op == `OP_BLEZ) || (dcd_op == `OP_BGTZ) || 
                                      ((dcd_op==`OP_OTHER1) && ((dcd_rt==`OP1_BLTZ) || (dcd_rt==`OP1_BLTZAL) || (dcd_rt==`OP1_BGEZ) || (dcd_rt==`OP1_BGEZAL))));

   assign        branch_prediction  = pattern_history_table[global_history_register][1:0];
   assign        br_pred_taken      = (branch_prediction>=2) && cache_hit;
   assign        br_pred_not_taken  = ((branch_prediction<2) || cache_miss) && (uncond_jump || cond_branch);


   always @(posedge clk, negedge rst_b) begin
       if(!rst_b) begin
            global_history_register  <= 'b0;
              for (int i=0;i<4096;i=i+1)begin
                pattern_history_table[i] <= 'b0;
            end

           
            jump_branch_ID           <= 'b0;
            jump_branch_EX           <= 'b0;
            cache_hit_ID             <= 'b0;
            cache_hit_EX             <= 'b0;
            inst_addr_PC_ID          <= 'b0;
            inst_addr_PC_EX          <= 'b0;
       end
       else begin
            if(jump_branch_EX) begin
                global_history_register  <= {global_history_register[GHR_W-2:0],branch_taken};
                if(((branch_prediction != 2'b11) && branch_taken) || ((branch_prediction != 2'b00) && !branch_taken))
                    pattern_history_table[global_history_register] <= (branch_taken? 
                                                                        (pattern_history_table[global_history_register] + 1): 
                                                                        (pattern_history_table[global_history_register] - 1));
            end
            jump_branch_ID           <= (uncond_jump || cond_branch);
            jump_branch_EX           <= jump_branch_ID;
            inst_addr_PC_ID          <= inst_addr_PC;
            inst_addr_PC_EX          <= inst_addr_PC_ID;
            cache_hit_ID             <= cache_hit;
            cache_hit_EX             <= cache_hit_ID;

        end
   end


  mips_cache branch_target_buffer ( 
         .clk               ( clk                               ),              
         .rst_b             ( rst_b                             ),
                  
         .cache_input_valid ( (uncond_jump || cond_branch)      ), 
         .Addr_in           ( inst_addr_PC                      ),
         .cache_hit         ( cache_hit                         ),
         .cache_miss        ( cache_miss                        ),
         .Data_out          ( branch_prediction_addr            ),

        
         .write_en          ((jump_branch_EX && !cache_hit_EX && branch_taken)  ),
         .Addr_in_write     ( inst_addr_PC_EX                   ),
         .Data_in           ( inst_addr_PC                      )

  
     );



endmodule
