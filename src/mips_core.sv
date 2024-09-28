// Include the MIPS constants
`include "mips_defines.svh"
`include "internal_defines.svh"

module mips_core(/*AUTOARG*/
   // Outputs
   inst_addr_PC, mem_addr, mem_data_in, mem_write_en, halted,
   // Inputs
   clk, inst_excpt, mem_excpt, inst, mem_data_out, rst_b
   );
   
    parameter text_start  = 32'h00400000; /* Initial value of $pc */

    // Core Interface
    input            clk;
    input            rst_b;

    input  [31:0]    inst;
    output [29:0]    inst_addr_PC;

    input            inst_excpt;

    input  [31:0]    mem_data_out;
    output [29:0]    mem_addr;
    output [31:0]    mem_data_in;
    output [3:0]     mem_write_en;

    input            mem_excpt;
    output           halted;


    // Internal signals
    
    
    wire [31:0]     pc_IF;              // Program Counter
    wire [31:0]     pc_ID;              // Program Counter
    wire [31:0]     pc_EX;              // Program Counter
    wire [31:0]     pc_MEM;             // Program Counter
    wire [31:0]     pc_WB;              // Program Counter

    wire [31:0]     nextpc_IF;          // Next Program Counter
    wire [31:0]     nextpc_ID;          // Next Program Counter
    wire [31:0]     nextpc_EX;          // Next Program Counter
    wire [31:0]     nextpc_MEM;         // Next Program Counter
    wire [31:0]     nextpc_WB;          // Next Program Counter

    wire [31:0]     nextnextpc;         // Next Next Program Counter

    wire [31:0]     inst_addr_jump_branch_EX;
    wire [31:0]     inst_addr_jump_branch_MEM;



    wire [31:0]     inst_out_IF;
    wire [31:0]     inst_out_ID;
    wire [5:0]      dcd_op_IF;
    wire [5:0]      dcd_op_ID;
    wire [5:0]      dcd_funct2_IF;
    wire [5:0]      dcd_funct2_ID;
    wire [5:0]      dcd_funct2_EX;


    wire            exception_halt;     // Exception case
    wire            syscall_halt;       // External Halt
    wire            internal_halt;      // Internal Halt

    wire            load_epc;           
    wire            load_bva;
    wire            load_bva_sel;

    wire [4:0]      dcd_rt_IF;
    wire [4:0]      dcd_rt_ID;
    wire [4:0]      dcd_rt_EX;
    wire [4:0]      dcd_rt_MEM;
    wire [4:0]      dcd_rt_WB;

    wire [4:0]      dcd_rs_IF;
    wire [4:0]      dcd_rs_ID;
    wire [4:0]      dcd_rs_EX;
    wire [4:0]      dcd_rs_MEM;
    wire [4:0]      dcd_rs_WB;

    wire [4:0]      dcd_rd_IF;
    wire [4:0]      dcd_rd_ID;
    wire [4:0]      dcd_rd_EX;
    wire [4:0]      dcd_rd_MEM;
    wire [4:0]      dcd_rd_WB;
    
    wire [31:0]     rs_data_EX_f;            // rt - Register Target Data
    wire [31:0]     rt_data_EX_f;            // rt - Register Target Data

    wire [31:0]     rt_data_ID;            // rt - Register Target Data
    wire [31:0]     rt_data_EX;            // rt - Register Target Data
    wire [31:0]     rt_data_MEM;            // rt - Register Target Data
    wire [31:0]     rs_data_ID;            // rt - Register Target Data
    wire [31:0]     rs_data_EX;            // rs - Register Store Data
    wire [31:0]     rd_data_WB;            // rd - Register Destination Data

    wire [31:0]     alu__out_EX;           // ALU Output
    wire [31:0]     alu__out_MEM;           // ALU Output
    wire [31:0]     alu__out_WB;           // ALU Output

    wire [31:0]     r_v0;               
    wire [31:0]     epc;
    wire [31:0]     cause;
    wire [31:0]     bad_v_addr;
    wire [4:0]      cause_code;

    wire [15:0]     dcd_imm_ID;
    wire [15:0]     dcd_imm_EX;
    wire [15:0]     dcd_imm_MEM;

    wire [31:0]     dcd_e_imm_ID;  
    wire [31:0]     dcd_e_imm_EX;  
    wire [31:0]     dcd_se_imm_ID;  
    wire [31:0]     dcd_se_imm_EX; 

    wire [31:0]     dcd_se_offset_ID;
    wire [31:0]     dcd_se_offset_EX;

    wire [3:0]	    alu__sel_ID;		// From Decoder of mips_decode.v
    wire [3:0]	    alu__sel_EX;		// From Decoder of mips_decode.v
    wire		    ctrl_RI_ID;			// From Decoder of mips_decode.v
    wire		    ctrl_Sys_ID;		// From Decoder of mips_decode.v
    wire		    ctrl_RI_EX;			// From Decoder of mips_decode.v
    wire		    ctrl_Sys_EX;		// From Decoder of mips_decode.v

    wire [25:0]     dcd_target_ID;
    wire [25:0]     dcd_target_EX;
    wire		    ctrl_we_ID;			// From Decoder of mips_decode.v
    wire		    ctrl_we_EX;			// From Decoder of mips_decode.v
    wire		    ctrl_we_MEM;		// From Decoder of mips_decode.v
    wire		    ctrl_we_WB;			// From Decoder of mips_decode.v

    wire            ctrl_unsigned_ID;
    wire            ctrl_shift_ID;
    wire            ctrl_shift_EX;
    wire            ctrl_shift_MEM;
    wire            ctrl_shift_WB;
    
    wire            ctrl_store_reg_ID;
    wire            ctrl_store_reg_EX;
    
    wire            ctrl_load_reg_ID;
    wire            ctrl_load_reg_EX;
    wire            ctrl_load_reg_MEM;
    wire            ctrl_load_reg_WB;
    
    wire            ctrl_jump_and_link_ID;
    wire            ctrl_jump_and_link_EX;
    wire            ctrl_jump_and_link_MEM;
    wire            ctrl_jump_and_link_WB;

    wire            ctrl_reg_imm_data_ID;
    wire            ctrl_reg_imm_data_EX;
    wire            ctrl_reg_imm_data_MEM;
    wire            ctrl_reg_imm_data_WB;
    wire [4:0]      dcd_shamt_ID;          // Shift Amount
    wire [4:0]      dcd_shamt_EX;          // Shift Amount

    wire [4:0]      ctrl_operation_type_ID;
    wire [4:0]      ctrl_operation_type_EX;
    wire [4:0]      ctrl_operation_type_MEM;
    wire [4:0]      ctrl_operation_type_WB;

    wire [31:0]     load_reg_data_EX; 
    wire [31:0]     load_reg_data_MEM; 
    wire [31:0]     load_reg_data_WB;

    wire [32+32+32-1:0]  												IF_out,	ID_in;
    wire [4+16+32+32+32+5+32+32+1+1+1+1+1+1+1+5+5+5+5+6+32+32+26-1:0]  	ID_out,	EX_in;
    wire [32+1+1+1+5+1+16+32+5+5+5+32+32-1:0]      						EX_out,	MEM_in;
    wire [32+1+1+1+5+1+32+5+5+5+32-1:0]      							MEM_out,WB_in;

    wire            stall;
    wire            stall_EX;
    wire            flush;
   
    wire [1:0]      forward_rs,forward_rt;



   register #(1, 0)             Halt        (clk, rst_b, 1'b1, internal_halt, halted);
   
   register #(32, 0)            EPCReg      (clk, rst_b, load_ex_regs, pc_IF, epc);
   
   register #(32, 0)            CauseReg    (clk, rst_b, load_ex_regs, {25'b0, cause_code, 2'b0}, cause);

   register #(32, 0)            BadVAddrReg (clk, rst_b, load_bva, pc_IF, bad_v_addr);

   assign        internal_halt = exception_halt | syscall_halt;

    mips_fetch Inst_Fetch (.*);
   assign        pc_IF              = {inst_addr_PC,2'b00};
   assign        dcd_rs_IF          = inst_out_IF[25:21];  // rs field
   assign        dcd_rt_IF          = inst_out_IF[20:16];  // rt field
   assign        dcd_rd_IF          = inst_out_IF[15:11];  // rd field
   assign        dcd_op_IF          = inst_out_IF[31:26];  // Opcode
   assign        dcd_funct2_IF      = inst_out_IF[5:0];    // funct field; secondary opcode

   assign IF_out    = {inst_out_IF,pc_IF,nextpc_IF};

      register #(32+32+32, 0)          IF_ID_PIPELINE (clk, rst_b, !stall, IF_out , ID_in); 
//////////////////////////////////////////////////////////////////////////
//
   assign {inst_out_ID,pc_ID,nextpc_ID} = {flush? 32'b0:ID_in[64+:32],ID_in[63:0]}; 
   assign        dcd_rs_ID          = inst_out_ID[25:21];  // rs field
   assign        dcd_rt_ID          = inst_out_ID[20:16];  // rt field
   assign        dcd_rd_ID          = inst_out_ID[15:11];  // rd field
   assign        dcd_op_ID          = inst_out_ID[31:26];  // Opcode
   assign        dcd_funct2_ID      = inst_out_ID[5:0];    // funct field; secondary opcode
   assign        dcd_target_ID      = inst_out_ID[25:0];
   // Generate control signals
   mips_decode Inst_Decod( .* );

 
   // Register File
    regfile
    Register_file (
                .clk            (  clk         ),    
                .rst_b          (  rst_b       ),  
                // ID to Regfile
                .rs_num         (  dcd_rs_ID   ),
                .rt_num         (  dcd_rt_ID   ),
                // Regfile to EX
                .rs_data        ( rs_data_ID   ),
                .rt_data        ( rt_data_ID   ),
                // WB to Regfile
                .rd_we          (  ctrl_we_WB  ),
                .rd_num         (((!ctrl_shift_WB || (!ctrl_operation_type_WB[4] && ctrl_operation_type_WB==5'h9)) && ctrl_reg_imm_data_WB) ? dcd_rt_WB: ctrl_jump_and_link_WB?5'h1F:dcd_rd_WB ),
                .rd_data        ((ctrl_operation_type_WB[4])?nextpc_WB:((!ctrl_operation_type_WB[4] && |ctrl_operation_type_WB[3:2])?load_reg_data_WB:alu__out_WB)),
                .halted         (  halted   ));


    assign ID_out       =   {   alu__sel_ID,
                                dcd_imm_ID,
                                dcd_e_imm_ID,  
                                dcd_se_imm_ID,
                                dcd_se_offset_ID,
                                dcd_shamt_ID,
                                rs_data_ID,
                                rt_data_ID,
                                ctrl_we_ID,
                                ctrl_Sys_ID,
                                ctrl_RI_ID,
                                ctrl_unsigned_ID,
                                ctrl_shift_ID,
                                ctrl_jump_and_link_ID,
                                ctrl_reg_imm_data_ID,
                                ctrl_operation_type_ID,
                                dcd_rs_ID,              
                                dcd_rt_ID,              
                                dcd_rd_ID,
                                dcd_funct2_ID,
                                pc_ID,
                                nextpc_ID,
                                dcd_target_ID
                                };

      register #(4+16+32+32+32+5+32+32+1+1+1+1+1+1+1+5+5+5+5+6+32+32+26, 0)          ID_EX_PIPELINE (clk, rst_b, !stall, ID_out, EX_in);
      register #(1, 0) ID_EX_Stall     (clk, rst_b, 1'b1, stall, stall_EX);

      //assign EX_in = ID_out;

//////////////////////////////////////////////////////////////////////////
  
   // Execute
       assign {   alu__sel_EX,
                  dcd_imm_EX,
                  dcd_e_imm_EX,  
                  dcd_se_imm_EX, 
                  dcd_se_offset_EX,
                  dcd_shamt_EX, 
                  rs_data_EX,
                  rt_data_EX,
                  ctrl_we_EX,
                  ctrl_Sys_EX,
                  ctrl_RI_EX,
                  ctrl_unsigned_EX,
                  ctrl_shift_EX,
                  ctrl_jump_and_link_EX,
                  ctrl_reg_imm_data_EX,
                  ctrl_operation_type_EX,
                  dcd_rs_EX,              
                  dcd_rt_EX,              
                  dcd_rd_EX,
                  dcd_funct2_EX,
                  pc_EX,
                  nextpc_EX,
                  dcd_target_EX
                } =      stall_EX ?'b0:EX_in;

   // Data Forwarding   
   assign rs_data_EX_f = forward_rs[0]?alu__out_MEM:(forward_rs[1]?alu__out_WB:rs_data_EX); 
   assign rt_data_EX_f = forward_rt[0]?alu__out_MEM:(forward_rt[1]?alu__out_WB:rt_data_EX); 

   mips_ALU 
   Execute_ALU(
                // ID to EX
                .alu__sel       (alu__sel_EX),
                .alu__op1       (ctrl_shift_EX? rt_data_EX_f:rs_data_EX_f),
                .alu__op2       ((ctrl_reg_imm_data_EX)? (ctrl_unsigned_EX ? dcd_e_imm_EX: dcd_se_imm_EX):(ctrl_shift_EX)?{25'b0,dcd_funct2_EX[1:0],(dcd_funct2_EX>=4)?rs_data_EX_f[4:0]:dcd_shamt_EX}:rt_data_EX_f),
                .alu__out       (alu__out_EX)
      );


   assign inst_addr_jump_branch_EX = ((ctrl_operation_type_EX==5'h13 && (alu__out_EX == 0)) || 
                                      (ctrl_operation_type_EX==5'h14 && (alu__out_EX != 0)) ||
                                      (ctrl_operation_type_EX==5'h15 && (rs_data_EX[31])) ||
                                      (ctrl_operation_type_EX==5'h16 && (rs_data_EX[31] || (rs_data_EX == 0))) || 
                                      (ctrl_operation_type_EX==5'h17 && (!rs_data_EX[31] && (rs_data_EX != 0))) || 
                                      (ctrl_operation_type_EX==5'h18 && !rs_data_EX[31]) 
                                                                                            )?(pc_EX + dcd_se_offset_EX): 
                                     ((ctrl_operation_type_EX==5'h12) ?rs_data_EX:
                                     ((ctrl_operation_type_EX==5'h11) ?{pc_EX[31:28],dcd_target_EX,2'b00}:0));
                                        


    assign EX_out       =   {   alu__out_EX,
                                ctrl_we_EX,              
                                ctrl_shift_EX,          
                                ctrl_reg_imm_data_EX,   
                                ctrl_operation_type_EX,
                                ctrl_jump_and_link_EX,  
                                dcd_imm_EX,  
                                rt_data_EX_f,
                                dcd_rs_EX,              
                                dcd_rt_EX,              
                                dcd_rd_EX,
                                nextpc_EX,
                                inst_addr_jump_branch_EX
                            };

      register #(32+1+1+1+5+1+16+32+5+5+5+32+32, 0)         EX_MEM_PIPELINE              (clk, rst_b, 1'b1, EX_out,MEM_in);

      //assign MEM_in =  EX_out;
/////////////////////////////////////////////////////////////////////////
// Memory Access
    assign {alu__out_MEM,
            ctrl_we_MEM,
            ctrl_shift_MEM,
            ctrl_reg_imm_data_MEM,
            ctrl_operation_type_MEM,
            ctrl_jump_and_link_MEM,
            dcd_imm_MEM,
            rt_data_MEM,
            dcd_rs_MEM,
            dcd_rt_MEM,
            dcd_rd_MEM,
            nextpc_MEM,
            inst_addr_jump_branch_MEM
            }           = MEM_in;

    assign        mem_data_in       =   (!ctrl_operation_type_MEM[4] && |ctrl_operation_type_MEM[1:0]) ? rt_data_MEM:0;
    assign        mem_write_en      =   (ctrl_operation_type_MEM==1)    ? 4'b1 :
                                        (ctrl_operation_type_MEM==2)    ? 4'b11: 
                                        (ctrl_operation_type_MEM==3)    ? 4'hF :4'b0;

    assign        mem_addr          =   (!ctrl_operation_type_MEM[4] && |ctrl_operation_type_MEM)      ? alu__out_MEM[29:0]: 0;


    assign        load_reg_data_MEM  =  (ctrl_operation_type_MEM==5'h4) ? {{24{mem_data_out[7]}},mem_data_out[7:0]}:
                                        (ctrl_operation_type_MEM==5'h5) ? {24'b0,mem_data_out[7:0]}:
                                        (ctrl_operation_type_MEM==5'h6) ? {{16{mem_data_out[15]}},mem_data_out[15:0]}:
                                        (ctrl_operation_type_MEM==5'h7) ? {16'b0,mem_data_out[15:0]}:
                                        (ctrl_operation_type_MEM==5'h8) ? mem_data_out:
                                        (ctrl_operation_type_MEM==5'h9) ? {dcd_imm_MEM,16'b0}:0;




    assign      MEM_out             = { alu__out_MEM,
                                        ctrl_we_MEM,             
                                        ctrl_shift_MEM,          
                                        ctrl_reg_imm_data_MEM,   
                                        ctrl_operation_type_MEM,
                                        ctrl_jump_and_link_MEM,  
                                        load_reg_data_MEM,       
                                        dcd_rs_MEM,              
                                        dcd_rt_MEM,              
                                        dcd_rd_MEM,
                                        nextpc_MEM
                                      };

      register #(32+1+1+1+5+1+32+5+5+5+32, 0)         MEM_WB_PIPELINE     (clk, rst_b, 1'b1, MEM_out, WB_in);
      //assign WB_in = MEM_out;
/////////////////////////////////////////////////////////////////////////
// Write Back Stage

    assign      {alu__out_WB,
                 ctrl_we_WB,
                 ctrl_shift_WB,
                 ctrl_reg_imm_data_WB,
                 ctrl_operation_type_WB,
                 ctrl_jump_and_link_WB, 
                 load_reg_data_WB,
                 dcd_rs_WB,
                 dcd_rt_WB,
                 dcd_rd_WB,
                 nextpc_WB
                 }              = WB_in;

/////////////////////////////////////////////////////////////////////////


// Stall Logic
assign stall =0;

// Data Forwarding

    assign forward_rs =  {((dcd_rs_EX!=0) && ctrl_we_WB && (dcd_rs_EX==(ctrl_reg_imm_data_WB?dcd_rt_WB:dcd_rd_WB))),((dcd_rs_EX!=0) && ctrl_we_MEM && (dcd_rs_EX==(ctrl_reg_imm_data_MEM?dcd_rt_MEM:dcd_rd_MEM)))};
    assign forward_rt =  {((dcd_rt_EX!=0) && ctrl_we_WB && (dcd_rt_EX==(ctrl_reg_imm_data_WB?dcd_rt_WB:dcd_rd_WB))),((dcd_rt_EX!=0) && ctrl_we_MEM && (dcd_rt_EX==(ctrl_reg_imm_data_MEM?dcd_rt_MEM:dcd_rd_MEM)))};

    /*

    assign stall =  (((!ctrl_reg_imm_data_EX  && ctrl_we_EX  && (dcd_rs_ID>0) && (dcd_rs_ID == dcd_rd_EX )) || 
                     (!ctrl_reg_imm_data_MEM && ctrl_we_MEM && (dcd_rs_ID>0) && (dcd_rs_ID == dcd_rd_MEM)) || 
                     (!ctrl_reg_imm_data_WB  && ctrl_we_WB  && (dcd_rs_ID>0) && (dcd_rs_ID == dcd_rd_WB )) || 
                     (!ctrl_reg_imm_data_EX  && ctrl_we_EX  && (dcd_rt_ID>0) && (dcd_rt_ID == dcd_rd_EX )) || 
                     (!ctrl_reg_imm_data_MEM && ctrl_we_MEM && (dcd_rt_ID>0) && (dcd_rt_ID == dcd_rd_MEM)) || 
                     (!ctrl_reg_imm_data_WB  && ctrl_we_WB  && (dcd_rt_ID>0) && (dcd_rt_ID == dcd_rd_WB )) || 
                     ( ctrl_reg_imm_data_EX  && ctrl_we_EX  && (dcd_rs_ID>0) && (dcd_rs_ID == dcd_rt_EX )) ||  
                     ( ctrl_reg_imm_data_MEM && ctrl_we_MEM && (dcd_rs_ID>0) && (dcd_rs_ID == dcd_rt_MEM)) ||  
                     ( ctrl_reg_imm_data_WB  && ctrl_we_WB  && (dcd_rs_ID>0) && (dcd_rs_ID == dcd_rt_WB )) ||
                     ( ctrl_reg_imm_data_EX  && ctrl_we_EX  && (dcd_rt_ID>0) && (dcd_rt_ID == dcd_rt_EX )) ||  
                     ( ctrl_reg_imm_data_MEM && ctrl_we_MEM && (dcd_rt_ID>0) && (dcd_rt_ID == dcd_rt_MEM)) ||  
                     ( ctrl_reg_imm_data_WB  && ctrl_we_WB  && (dcd_rt_ID>0) && (dcd_rt_ID == dcd_rt_WB )))
                     //&& (forward_rs==0) && (forward_rt==0)
                    );


// Data Forwarding

    assign forward_rs = 0; // {((dcd_rs_EX!=0) && (dcd_rs_EX==dcd_rd_WB) && ctrl_we_WB),((dcd_rs_EX!=0) && (dcd_rs_EX==dcd_rd_MEM) && ctrl_we_MEM)};
    assign forward_rt = 0; // {((dcd_rt_EX!=0) && (dcd_rt_EX==dcd_rd_WB) && ctrl_we_WB),((dcd_rt_EX!=0) && (dcd_rt_EX==dcd_rd_MEM) && ctrl_we_MEM)};
*/


   // Miscellaneous stuff (Exceptions, syscalls, and halt)
   exception_unit 
   EU(
                .clk            (clk), 
                .rst_b          (rst_b),
                .exception_halt (exception_halt), 
                .pc             (pc_ID), 
                .load_ex_regs   (load_ex_regs),
                .load_bva       (load_bva), 
                .load_bva_sel   (load_bva_sel),
                .cause          (cause_code),
                .IBE            (inst_excpt),
                .DBE            (1'b0),
                .RI             (ctrl_RI_ID),
                .Ov             (1'b0),
                .BP             (1'b0),
                .AdEL_inst      (pc_ID[1:0]?1'b1:1'b0),
                .AdEL_data      (1'b0),
                .AdES           (1'b0),
                .CpU            (1'b0));

   assign r_v0 = 32'h0a; // Good enough for now. To support syscall for real,
                         // you should read the syscall
                         // argument from $v0 of the register file 

   syscall_unit 
   SU(
                .clk            (clk), 
                .rst_b          (rst_b),
                .syscall_halt   (syscall_halt), 
                .pc             (pc_ID), 
                .Sys            (ctrl_Sys_ID),
                .r_v0           (r_v0));
  

   // synthesis translate_off
   always @(posedge clk) begin
     // useful for debugging, you will want to comment this out for long programs
     if (rst_b) begin
       $display ( "=== Simulation Cycle %d ===", $time );
       $display ( "[pc=%x, inst=%x] [op=%x, rs=%d, rt=%d, rd=%d, imm=%x, f2=%x] [reset=%d, halted=%d]",
                   pc_ID, inst_out_ID, dcd_op_ID, dcd_rs_ID, dcd_rt_ID, dcd_rd_ID, dcd_imm_ID, dcd_funct2_ID, ~rst_b, halted);
     end
   end
   // synthesis translate_on


/*
 prop_check_ADD:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_ADD)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == rt_data_ID + rs_data_ID) && ctrl_we 
   );
   
 prop_check_ADDU:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_ADDU)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == rt_data_ID + rs_data_ID) && ctrl_we 
   );


 prop_check_SUB:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_SUB)) && !halted && (rt_data_ID>0) && (rs_data_ID>0) && (rs_data_ID>rt_data_ID)|-> (alu__out == rs_data_ID - rt_data_ID) && ctrl_we 
   );

 prop_check_SUBU:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_SUBU)) && !halted && (rt_data_ID>0) && (rs_data_ID>0) && (rs_data_ID>rt_data_ID)|-> (alu__out == rs_data_ID - rt_data_ID) && ctrl_we 
   );

 prop_check_AND:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_AND)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == (rt_data_ID & rs_data_ID)) && ctrl_we 
   );


 prop_check_XOR:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_XOR)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == (rt_data_ID ^ rs_data_ID)) && ctrl_we 
   );

  prop_check_NOR:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_NOR)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == !(rt_data_ID ^ rs_data_ID)) && ctrl_we 
   );

 prop_check_OR:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_OR)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == (rt_data_ID | rs_data_ID)) && ctrl_we 
   );

 prop_check_SLL:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_SLL)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == rt_data_ID << dcd_shamt_ID) && ctrl_we 
   );

  prop_check_SLLV:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_SLLV)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == rt_data_ID << rs_data_ID[4:0]) && ctrl_we 
   );

  prop_check_SRA:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_SRA)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == 32'({{32{rt_data_ID[31]}},rt_data_ID} >> dcd_shamt_ID)) && ctrl_we 
   );

  prop_check_SRAV:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_SRAV)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == 32'({{32{rt_data_ID[31]}},rt_data_ID} >> rs_data_ID[4:0])) && ctrl_we 
   );

  prop_check_SRL:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_SRL)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == 32'({32'b0,rt_data_ID} >> dcd_shamt_ID)) && ctrl_we 
   );

  prop_check_SRLV:assert property (@(posedge clk)
   ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_SRLV)) && !halted && (rt_data_ID>0) && (rs_data_ID>0)|-> (alu__out == 32'({32'b0,rt_data_ID} >> rs_data_ID[4:0])) && ctrl_we 
   );

 // prop_check_SLT:assert property (@(posedge clk)
 //  ((dcd_op == `OP_OTHER0) && (dcd_funct2==`OP0_SLT)) && !halted && (rt_data_ID[30:0]>0) && (rs_data_ID[30:0]>0)|-> (alu__out ==  {31'b0,({rs_data_ID[30],rs_data_ID[30:0]} < {rt_data_ID[30],rt_data_ID[30:0]})}) && ctrl_we 
 //  );

  prop_check_ADDI:assert property (@(posedge clk)
   (dcd_op == `OP_ADDI) && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0)|-> (alu__out == (rs_data_ID + dcd_se_imm_ID)) && ctrl_we 
   );

  prop_check_ADDIU:assert property (@(posedge clk)
   (dcd_op == `OP_ADDIU) && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0)|-> (alu__out == (rs_data_ID + dcd_se_imm_ID)) && ctrl_we 
   );

  prop_check_ANDI:assert property (@(posedge clk)
   (dcd_op == `OP_ANDI) && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0)|-> (alu__out == (rs_data_ID & dcd_e_imm_ID)) && ctrl_we 
   );

  prop_check_ORI:assert property (@(posedge clk)
   (dcd_op == `OP_ORI) && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0)|-> (alu__out == (rs_data_ID | dcd_e_imm_ID)) && ctrl_we 
   );

  prop_check_XORI:assert property (@(posedge clk)
   (dcd_op == `OP_XORI) && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0)|-> (alu__out == (rs_data_ID ^ dcd_e_imm_ID)) && ctrl_we 
   );

 // prop_check_SLTI:assert property (@(posedge clk)
 //  (dcd_op == `OP_SLTI) && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0)|-> (alu__out ==  {31'b0,(rs_data_ID < dcd_se_imm_ID)}) && ctrl_we 
 //  );

  prop_check_SB:assert property (@(posedge clk)
   (dcd_op == `OP_SB) && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0) && (rt_data_ID>0) |-> (mem_data_in ==  rt_data_ID) && (mem_write_en==4'b1)  && (mem_addr== 30'(dcd_se_imm_ID+rs_data_ID)) && !ctrl_we  
   );
  
  prop_check_SH:assert property (@(posedge clk)
   (dcd_op == `OP_SH) && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0) && (rt_data_ID>0) |-> (mem_data_in ==  rt_data_ID) && (mem_write_en==4'b11)  && (mem_addr== 30'(dcd_se_imm_ID+rs_data_ID)) && !ctrl_we 
   );
   	
  prop_check_SW:assert property (@(posedge clk)
   (dcd_op == `OP_SW) && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0) && (rt_data_ID>0) |-> (mem_data_in ==  rt_data_ID) && (mem_write_en==4'b1111)  && (mem_addr== 30'(dcd_se_imm_ID+rs_data_ID)) && !ctrl_we 
   );


  prop_check_Load:assert property (@(posedge clk)
   ((dcd_op == `OP_LB) || (dcd_op == `OP_LBU) || (dcd_op == `OP_LH) || (dcd_op == `OP_LHU) || (dcd_op == `OP_LW))  && !halted && (dcd_se_imm_ID>0) && (rs_data_ID>0) |->  (mem_addr== 30'(dcd_se_imm_ID+rs_data_ID)) && !ctrl_we ##2 rt_data_ID==load_reg_data 
   );
*/
endmodule // mips_core


module mips_ALU(alu__out, alu__op1, alu__op2, alu__sel);

   output   [31:0]  alu__out;
   input    [31:0]  alu__op1;
   input    [31:0]  alu__op2;
   input    [3:0]   alu__sel;

   logic [31:0] addr_out;
   logic [31:0] log_out;
   logic [31:0] shift_out;

   adder                AdderUnit   (addr_out,  ((alu__sel==4'b1001)?{alu__op1[30],alu__op1[30:0]}:alu__op1),((alu__sel==4'b1001)?{alu__op2[30],alu__op2[30:0]}: alu__op2),     alu__sel);
   logical_operation    logical_unit(log_out,   alu__op1, alu__op2,     alu__sel);
   logical_shift        shift_unit  (shift_out, alu__op1, alu__op2[6:0],alu__sel);

   assign alu__out = ((alu__sel==4'b1001)?{31'b0,addr_out[31]}:addr_out) | log_out | shift_out ;


  endmodule


//// register: A register which may be reset to an arbirary value
module register #(

   parameter width = 32,
   parameter reset_value = 0)(
   
    input                    clk,
    input                    rst_b,
    input                    enable,
    input [(width-1):0]      d,
    output reg [(width-1):0] q
   );

   always @(posedge clk or negedge rst_b)
     if (~rst_b)
       q <= reset_value;
     else if (enable)
       q <= d;

endmodule // register


module adder(out, in1, in2, sub);
   output [31:0]  out;
   input  [31:0]  in1; 
   input  [31:0]  in2;
   input  [3:0]   sub;

   assign        out = (sub[2:1]==0)?sub[0]?(in1 - in2):(in1 + in2):0;

endmodule // adder

module logical_operation(out, in1, in2, opt);
   output [31:0]  out;
   input  [31:0]  in1; 
   input  [31:0]  in2;
   input  [3:0]   opt;

   assign        out = (opt==2)?(in1 & in2):((opt==3)?(in1 | in2):((opt==4)?(in1 ^ in2):((opt==5)?!(in1 ^ in2):0)));

endmodule // adder

module logical_shift(out, in1, shift, opt);
   output [31:0]  out;
   input  [31:0]  in1; 
   input  [6:0]   shift;
   input  [3:0]   opt;

   assign        out = (opt==6)?(in1 << shift[4:0]):((opt==7)?({(shift[6:5]==2'b10)?32'b0:{32{in1[31]}},in1} >> shift[4:0]):0);

endmodule // adder


