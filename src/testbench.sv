`timescale 1ns/1ps


// Top module for the MIPS processor core
// NOT synthesizable Verilog!
module testbench;

   reg [31:0] i;
   reg [29:0] addr;

   wire       clk, inst_excpt, mem_excpt, halted;
   wire [29:0] pc, mem_addr;
   wire [31:0] mem_data_in, mem_data_out;
   wire [3:0]  mem_write_en;
   reg 	       rst_b;
   wire  [31:0] inst;
   reg boot;
   reg [31:0] bootload_code;
   reg [31:0] bootload_code_in;
   reg [31:0] bootload_addr;

   reg     [3:0] test;
   reg  jump;
   
   // The clock
   clock CLK(clk);

   // The MIPS core
   mips_core core(
            .clk(boot?1'b0:clk), 
            .inst_addr_PC(pc), 
            .inst(inst),
		    .inst_excpt(inst_excpt), 
		    .mem_addr(mem_addr),
		    .mem_data_in(mem_data_in), 
		    .mem_data_out(mem_data_out),
		    .mem_write_en(mem_write_en), 
		    .mem_excpt(mem_excpt),
		    .halted(halted), 
		    .rst_b(rst_b));

   // Memory
   mips_mem Memory(// Port 1 (instructions)
		   .addr1(pc), 
		   .data_in1(), 
		   .data_out1(inst), 
		   .we1(4'b0),
		   .excpt1(inst_excpt), 
		   .allow_kernel1(1'b1), 
		   .kernel1(),

		   // Port 2 (data)
		   .addr2(boot?bootload_addr[31:2]:mem_addr), 
		   .data_in2(boot?bootload_code_in:mem_data_in),
		   .data_out2(mem_data_out), 
		   .we2(boot?4'hF:mem_write_en),
		   .excpt2(mem_excpt), 
		   .allow_kernel2(1'b1), 
		   .kernel2(),
		   .rst_b(boot?rst_b:1'b1), 
		   .clk(clk));


   initial
     begin
    test=9;
     $dumpfile("sim.fsdb");
$dumpvars;
boot=1;
jump=0;
bootload_code=32'h0;
rst_b = 0;
#150;
rst_b = 1;

//#100;	

if(test==1) begin
//TEST 1//
//// ADD ////

//addiu v0, zero, 0xa --> 
	bootload_code=32'h2402000A;
	#100;
//addiu t0, zero,0x5 --> 
    bootload_code=32'h24080005;
    #100;
//addiu t1, t0, 0x12C -->   
    bootload_code=32'h2509012C;
    #100;
//addiu t2, zero, 0x1F4 --> 
    bootload_code=32'h240A01F4;
    #100;
//addiu t3, t2, 0x22; --> 
    bootload_code=32'h254B0022;
    #100;
//addiu t3, t3, 0x2D --> 
    bootload_code=32'h256B002D;
	#100;
end 
else if(test==2) begin

//TEST2//
//Add//

//addi $4, $zero, 512
	bootload_code=32'h20040200;
	#100;
//add  a1, $4, $zero
    bootload_code=32'h00802820;
    #100;
//add  $6, a1, a1
    bootload_code=32'h00A53020;
    #100;
//add  $7, $6, $6
    bootload_code=32'h00C63820;
    #100;
//addiu $v0, $zero, 0xa
    bootload_code=32'h2402000A;
    #100;
end
else if(test==3) begin

//TEST 3//
//Arithmatic//

//        addiu   $2, $zero, 1024
    bootload_code=32'h24020400;
    #100;
        
//        addu    v1, $2, $2
    bootload_code=32'h00421821;
    #100;

//        or      $4, v1, $2
    bootload_code=32'h00622025;
    #100;

//        addi     a1, $zero, 1234
    bootload_code=32'h200504D2;
    #100;

//        sll     $6, a1, 16
    bootload_code=32'h00053400;
    #100;
//        addiu   $7, $6, 9999
    bootload_code=32'h24C7270F;
    #100;
//        subu    $8, $7, $2
    bootload_code=32'h00E24023;
    #100;
//        xor     $9, $4, v1
    bootload_code=32'h00834826;
    #100;
//        xori    $10, $2, 255
    bootload_code=32'h384A00FF;
    #100;
//        srl     $11, $6, 5
    bootload_code=32'h00065942;
    #100;
//        sra     $12, $6, 4
    bootload_code=32'h00066103;
    #100;
//        and     $13, $11, a1
    bootload_code=32'h01656824;
    #100;
//        andi    $14, $4, 100
    bootload_code=32'h308E0064;
    #100;
//        sub     $15, $zero, $10
    bootload_code=32'h000A7822;
    #100;
//        lui     s1, 100
    bootload_code=32'h3C110064;
    #100;
//        addiu   $v0, $zero, 0xa
    bootload_code=32'h2402000A;
    #100;
end
else if(test==4) begin

//TEST 4//
//Shift//

//ori v1, $zero, 65535
    bootload_code=32'h3403FFFF;
    #100;
//sll   $4, v1, 16
    bootload_code=32'h00032400;
    #100;
//sll   a1, v1, 6
    bootload_code=32'h00032980;
    #100;
//sra   $6, $4, 10
    bootload_code=32'h00043283;
    #100;
//sra   $7, a1, 16
    bootload_code=32'h00053C03;
    #100;
//srl   $8, $4, 8
    bootload_code=32'h00044202;
    #100;
//srl   $9, a1, 16
    bootload_code=32'h00054C02;
    #100;
//addiu $2, $zero, 0xa
    bootload_code=32'h2402000A;
    #100;
end
else if(test==5) begin

//TEST 5//
//Load Store Memory 1//

//#;;  Set a base address
//lui    v1, 0x0400
    bootload_code=32'h3C030400;
    #100;
//addiu  a1, $zero, 255
    bootload_code=32'h240500FF;
    #100;
//add    $6, a1, a1
    bootload_code=32'h00A53020;
    #100;
//add    $7, $6, $6
    bootload_code=32'h00C63820;
    #100;
//addiu  $8, $7, 30000
    bootload_code=32'h24E87530;
    #100;
//#;; Place a test pattern in memory
//sw     a1, 0x0,v1
    bootload_code=32'hAC650000;
    #100;
//sw     $6, 0x4,v1
    bootload_code=32'hAC660004;
    #100;
//sw     $7, 0x8,v1
    bootload_code=32'hAC670008;
    #100;
//sw     $8, 0xc,v1
    bootload_code=32'hAC68000C;
    #100;
//lw     $9,  0x0,v1
    bootload_code=32'h8C690000;
    #100;
//w     $10, 0x4,v1
    bootload_code=32'h8C6A0004;
    #100;
//lw     $11, 0x8,v1
    bootload_code=32'h8C6B0008;
    #100;
//lw     $12, 0xc,v1
    bootload_code=32'h8C6C000C;
    #100;
//addiu  v1, v1, 4
    bootload_code=32'h24630004;
    #100;
//sw     a1, 0x0,v1
    bootload_code=32'hAC650000;
    #100;
//sw     $6, 0x4,v1
    bootload_code=32'hAC660004;
    #100;
//sw     $7, 0x8,v1
    bootload_code=32'hAC670008;
    #100;
//sw     $8, 0xc,v1
    bootload_code=32'hAC68000C;
    #100;
//lw     $13,  0xFFFC,v1
    bootload_code=32'h8C6DFFFC;
    #100;
//lw     $14,  0x0,v1
    bootload_code=32'h8C6E0000;
    #100;
//lw     $15,  0x4,v1
    bootload_code=32'h8C6F0004;
    #100;
//lw     $16,  0x8,v1
    bootload_code=32'h8C700008;
    #100;
//#;; Calculate a "checksum" for easy comparison
//add    s1, $zero, $9
    bootload_code=32'h00098820;
    #100;
//add    s1, s1, $10
    bootload_code=32'h022A8820;
    #100;
//add    s1, s1, $11
    bootload_code=32'h22B8820;
    #100;
//add    s1, s1, $12
    bootload_code=32'h022C8820;
    #100;
//add    s1, s1, $13
    bootload_code=32'h022D8820;
    #100;
//add    s1, s1, $14
    bootload_code=32'h022E8820;
    #100;
//add    s1, s1, $15
    bootload_code=32'h022F8820;
    #100;
//add    s1, s1, $16
    bootload_code=32'h02308820;
    #100;
//#;;  Quit out 
//addiu $v0, $zero, 0xa
    bootload_code=32'h2402000A;
    #100;
end
else if(test==6) begin

//TEST 6//
//Load Store Memory 2//
//#;;  Set a base address
//lui    v1, 0x0400
    bootload_code=32'h3C030400;
    #100;
//addiu  a1, $zero, 0xcafe
    bootload_code=32'h2405CAFE;
    #100;
//addiu  $6, $zero, 0xfeca
    bootload_code=32'h2406FECA;
    #100;
//addiu  $7, $zero, 0xbeef
    bootload_code=32'h2407BEEF;
    #100;
//addiu  $8, $zero, 0xefbe
    bootload_code=32'h2408EFBE;
    #100;        
//#;; Place a test pattern in memory
//sb     a1, 0x0,v1
    bootload_code=32'hA0650000;
    #100;
//sb     $6, 0x1,v1
    bootload_code=32'hA0660001;
    #100;
//sb     $7, 0x6,v1
    bootload_code=32'hA0670006;
    #100;
//sb     $8, 0x7,v1
    bootload_code=32'hA0680007;
    #100;

//lbu     $9,  0x0,v1
    bootload_code=32'h90690000;
    #100;
//lbu     $10, 0x1,v1
    bootload_code=32'h906A0001;
    #100;
//lb      $11, 0x6,v1
    bootload_code=32'h806B0006;
    #100;
//lb      $12, 0x7,v1
    bootload_code=32'h806C0007;
    #100;

//addiu  v1, v1, 0x4
    bootload_code=32'h24630004;
    #100;
//sh     a1, 0x0,v1
    bootload_code=32'hA4650000;
    #100;
//sh     $6, 0x2,v1
    bootload_code=32'hA4660002;
    #100;
//sh     $7, 0x4,v1
    bootload_code=32'hA4670004;
    #100;
//sh     $8, 0x6,v1
    bootload_code=32'hA4680006;
    #100;

//lhu     $13,  0x0,v1
    bootload_code=32'h946D0000;
    #100;
//lhu     $14,  0x2,v1
    bootload_code=32'h946E0002;
    #100;
//lh     $15,  0x4,v1
    bootload_code=32'h846F0004;
    #100;
//lh     $16,  0x6,v1
    bootload_code=32'h84700006;
    #100;
       
//#;; Calculate a "checksum" for easy comparison
//add    s1, $zero, $9
    bootload_code=32'h00098820;
    #100;
//add    s1, s1, $10
    bootload_code=32'h022A8820;
    #100;
//add    s1, s1, $11
    bootload_code=32'h022B8820;
    #100;
//add    s1, s1, $12
    bootload_code=32'h022C8820;
    #100;
//add    s1, s1, $13
    bootload_code=32'h022D8820;
    #100;
//add    s1, s1, $14
    bootload_code=32'h022E8820;
    #100;
//add    s1, s1, $15
    bootload_code=32'h022F8820;
    #100;
//add    s1, s1, $16
    bootload_code=32'h02308820;
    #100;
//#;;  Quit out 
//addiu $v0, $zero, 0xa
    bootload_code=32'h2402000A;
    #100;
end

else if(test==7) begin
//100002
//lui    v1, 0x0400
    bootload_code=32'h3C030400;
    #100;
//addiu  a1, $zero, 0xcafe
    bootload_code=32'h2405CAFE;
    #100;
//addiu  $6, $zero, 0xfeca
    bootload_code=32'h2406FECA;
    #100;
//addiu  $7, $zero, 0xbeef
    bootload_code=32'h2407BEEF;
    #100;
//addiu  $8, $zero, 0xefbe
    bootload_code=32'h2408EFBE;
    #100;
//100007
 //   j 0x10000f
    bootload_code=32'h810000f;
    #100;

//////////////////////////////////////
//100008
//#;; Place a test pattern in memory
//sb     a1, 0x0,v1
    bootload_code=32'hA0650000;
    #100;
//100009
//sb     $6, 0x1,v1
    bootload_code=32'hA0660001;
    #100;
//10000a
//sb     $7, 0x6,v1
    bootload_code=32'hA0670006;
    #100;
//10000b
//sb     $8, 0x7,v1
    bootload_code=32'hA0680007;
    #100;
//10000c
//lbu     $9,  0x0,v1
    bootload_code=32'h90690000;
    #100;
//10000d
//addiu  v1, v1, 0x4
    bootload_code=32'h24630004;
    #100;
//10000e
//sh     a1, 0x0,v1
    bootload_code=32'hA4650000;
    #100
//////////////////////////////////////
//10000F
// Jump from J    
//lbu     $10, 0x1,v1
    bootload_code=32'h906A0001;
    #100;


//100010
 //   jal 0x100018
    bootload_code=32'h0C100018;
    #100;

//////////////////////////////////////
//////////////////////////////////////
//100011
//#;; Place a test pattern in memory
//sb     a1, 0x0,v1
    bootload_code=32'hA0650000;
    #100;
//100012
//sb     $6, 0x1,v1
    bootload_code=32'hA0660001;
    #100;
//100013
//sb     $7, 0x6,v1
    bootload_code=32'hA0670006;
    #100;
//100014
//sb     $8, 0x7,v1
    bootload_code=32'hA0680007;
    #100;
//100015
//lbu     $9,  0x0,v1
    bootload_code=32'h90690000;
    #100;
//100016
//addiu  v1, v1, 0x4
    bootload_code=32'h24630004;
    #100;
//100017
//sh     a1, 0x0,v1
    bootload_code=32'hA4650000;
    #100
//////////////////////////////////////

//////////////////////////////////////
//100018
//Jump from JAL
//lb      $12, 0x7,v1
    bootload_code=32'h806C0007;
    #100;
//100019
//addiu  v1, v1, 0x4
    bootload_code=32'h24630004;
    #100;
//10001a
//lui    v1, 0x40
    bootload_code=32'h3C030040;
    #100;
//10001b
//addiu  v1, v1, 0x90
    bootload_code=32'h24630090;
    #100;
//10001c
 //   jalr a0,v1
    bootload_code=32'h00602009;
    #100;


//////////////////////////////////////
//////////////////////////////////////
//10001d
//#;; Place a test pattern in memory
//sb     a1, 0x0,v1
    bootload_code=32'hA0650000;
    #100;
//10001e
//sb     $6, 0x1,v1
    bootload_code=32'hA0660001;
    #100;
//10001f
//sb     $7, 0x6,v1
    bootload_code=32'hA0670006;
    #100;
//100020
//sb     $8, 0x7,v1
    bootload_code=32'hA0680007;
    #100;
//100021
//lbu     $9,  0x0,v1
    bootload_code=32'h90690000;
    #100;
//100022
//sb     $8, 0x7,v1
    bootload_code=32'hA0680007;
    #100;
//100023
//sh     a1, 0x0,v1
    bootload_code=32'hA4650000;
    #100
//////////////////////////////////////
//////////////////////////////////////
//100024
// Jump from JALR
//sh     $6, 0x2,v1
    bootload_code=32'hA4660002;
    #100;
//100025
//addiu  v1, v1, 0x28
bootload_code=32'h24630028;
#100;

//100026
 //   jr v1
    bootload_code=32'h00600008;
    #100;


//////////////////////////////////////
//////////////////////////////////////
//100027
//#;; Place a test pattern in memory
//sb     a1, 0x0,v1
    bootload_code=32'hA0650000;
    #100;
//100028
//sb     $6, 0x1,v1
    bootload_code=32'hA0660001;
    #100;
//100029
//sb     $7, 0x6,v1
    bootload_code=32'hA0670006;
    #100;
//10002a
//sb     $8, 0x7,v1
    bootload_code=32'hA0680007;
    #100;
//10002b
//lbu     $9,  0x0,v1
    bootload_code=32'h90690000;
    #100;
//10002c
//addiu  v1, v1, 0x4
    bootload_code=32'h24630004;
    #100;
//10002d
//sh     a1, 0x0,v1
    bootload_code=32'hA4650000;
    #100
//////////////////////////////////////
//////////////////////////////////////
//10002e
// Jump from JR
//sh     $8, 0x6,v1
    bootload_code=32'hA4680006;
    #100;
//10002f
//lui    s2, 0x0400
    bootload_code=32'h3C120400;
    #100;
//100030
//lui    s3, 0x0400
    bootload_code=32'h3C130400;
    #100;
//100031
//BEQ s2, s3, 0x08
    bootload_code=32'h12530007;
    #100;
//////////////////////////////////////
//////////////////////////////////////
//100032
//#;; Place a test pattern in memory
//sb     a1, 0x0,v1
    bootload_code=32'hA0650000;
    #100;
//100033
//sb     $6, 0x1,v1
    bootload_code=32'hA0660001;
    #100;
//100034
//sb     $7, 0x6,v1
    bootload_code=32'hA0670006;
    #100;
//100035
//sb     $8, 0x7,v1
    bootload_code=32'hA0680007;
    #100;
//100036
//lbu     $9,  0x0,v1
    bootload_code=32'h90690000;
    #100;
//100037
//addiu  v1, v1, 0x4
    bootload_code=32'h24630004;
    #100;
//100038
//sh     a1, 0x0,v1
    bootload_code=32'hA4650000;
    #100
//////////////////////////////////////
//////////////////////////////////////
//100039
// Branch from BEQ
//lh     $16,  0x6,v1
    bootload_code=32'h84700006;
    #100;
//10003a       
//#;; Calculate a "checksum" for easy comparison
//add    s1, $zero, $9
    bootload_code=32'h00098820;
    #100;
//add    s1, s1, $10
    bootload_code=32'h022A8820;
    #100;
//add    s1, s1, $11
    bootload_code=32'h022B8820;
    #100;
//add    s1, s1, $12
    bootload_code=32'h022C8820;
    #100;
//add    s1, s1, $13
    bootload_code=32'h022D8820;
    #100;
//add    s1, s1, $14
    bootload_code=32'h022E8820;
    #100;
//add    s1, s1, $15
    bootload_code=32'h022F8820;
    #100;
//add    s1, s1, $16
    bootload_code=32'h02308820;
    #100;
//#;;  Quit out 
//addiu $v0, $zero, 0xa
    bootload_code=32'h2402000A;
    #100;     



    //jump=1

end

else if(test==8) begin
//100001
//        addiu $v0, $zero, 0xa
        bootload_code=32'h2402000A;
        #100;

//100002
l_0:    
//        addiu a1, $zero, 1
            bootload_code=32'h24050001;
        #100;

//100003
//        j 0x10000d //l_1
        bootload_code=32'h0810000d;
        #100;

//100004
//        addiu $10, $10, 0xf00
        bootload_code=32'h254A0F00;
        #100;

//100005
//        ori $0, $0, 0
        bootload_code=32'h34000000;
        #100;

//100006
//        ori $0, $0, 0
        bootload_code=32'h34000000;
        #100;

//100007
//        addiu a1, $zero, 100
        bootload_code=32'h24050064;
        #100;

//100008-b
    bootload_code=32'hdeadbeef;
	#400;
//10000c
    // SYSCALL
    bootload_code=32'h00XXXX0C;
	#100;
//10000d
l_1:
//        bne $zero, $zero, 0xd //10001a //l_3
        bootload_code=32'h1400000D;
        #100;

//10000e
//        ori $0, $0, 0
        bootload_code=32'h34000000;
        #100;

//10000f
//        ori $0, $0, 0
        bootload_code=32'h34000000;
        #100;

//100010
//        addiu $6, $zero, 0x1337
        bootload_code=32'h24061337;
        #100;

//100011
l_2:
//        beq $zero, $zero, 0xf //100020//l_4
        bootload_code=32'h1000000F;
        #100;

//100012

//        ori $0, $0, 0
        bootload_code=32'h34000000;
        #100;

//100013
//        ori $0, $0, 0
        bootload_code=32'h34000000;
        #100;

//100014
//        # Should not reach here
//        addiu $7, $zero, 0x347
        bootload_code=32'h24070347;
        #100;

//100015-8
        bootload_code=32'hdeadbeef;
	    #400;
//100019
        // SYSCALL
    bootload_code=32'h00XXXX0C;
	#100;
//10001a
l_3:
//        # Should not reach here
//        addiu $8, $zero, 0x347
        bootload_code=32'h24080347;
        #100;

//10001b-e
        bootload_code=32'hdeadbeef;
	    #400;
//10001f
        // SYSCALL
    bootload_code=32'h00XXXX0C;
	#100;
//100020

l_4:
//        addiu $7, $zero, 0xd00d
        bootload_code=32'h2407D00D;
        #100;
end
else if(test==9) begin
//100001
//main: 
//addiu $v0, $zero, 0xa
        bootload_code=32'h2402000A;
        #100;
//        # Set up some comparison values in registers
//100002
//        addiu $3, $zero, 1
        bootload_code=32'h24030001;
        #100;
//100003
//        addiu $4, $zero, -1
        bootload_code=32'h2404FFFF;
        #100;

//        # Checksum register
//100004
//        addiu a1, $zero, 0x1234
        bootload_code=32'h24051234;
        #100;        

//        # Test jump
//100005
//        j l_1
        bootload_code=32'h08100009;
        #100;
//100006
//l_0:
//        nop
        bootload_code=32'h00000020;
        #100;
//100007
//        addu a1, a1, $ra
        bootload_code=32'h00BF2821;
        #100;
//100008
//        beq   $zero, $zero, l_2
        bootload_code=32'h10000007;
        #100;
//100009
//l_1:
//        nop
        bootload_code=32'h00000020;
        #100;
//10000a
//        addiu a1, a1, 7
        bootload_code=32'h24A50007;
        #100;
//10000b
//        jal l_0
        bootload_code=32'h0C100006;
        #100;
//10000c
//        nop
        bootload_code=32'h00000020;
        #100;
//10000d
//        nop
        bootload_code=32'h00000020;
        #100;
//10000e
//        j l_8
        bootload_code=32'h08100025;
        #100;
//10000f
//l_2:    nop
        bootload_code=32'h00000020;
        #100;
//100010
//        addiu a1, a1, 9
        bootload_code=32'h24A50009;
        #100;
//100011
//        bne $3, $4, l_4
        bootload_code=32'h14640004;
        #100;
//100012
//l_3: 
//    //# Taken
//        nop
        bootload_code=32'h00000020;
        #100;
//100013
//        addiu a1, a1, 5
        bootload_code=32'h24A50005;
        #100;
//100014
//        bgez $zero, l_6
        bootload_code=32'h04010007;
        #100;
//100015
//l_4:
//        # Not taken
//        nop
        bootload_code=32'h00000020;
        #100;
//100016
//        addiu a1, a1, 11
        bootload_code=32'h24A5000B;
        #100;
//100017
//        blez  $3, l_3
        bootload_code=32'h1860FFFB;
        #100;
//100018
//l_5:
//        # Taken

//        nop
        bootload_code=32'h00000020;
        #100;
//100019
//        addiu a1, a1, 99
        bootload_code=32'h24A50063;
        #100;
//10001a
//        bgtz  $3, l_3
        bootload_code=32'h1C60FFF8;
        #100;
//10001b
//l_6:
//        # here
//        nop
        bootload_code=32'h00000020;
        #100;
//10001c
//        addiu a1, a1, 111
        bootload_code=32'h24A5006F;
        #100;
//10001d
//        jr $ra
//        # Should go to l_1, then go to l_8
        bootload_code=32'h03E00008;
        #100;
//10001e
//l_7:
//        # Should not get here
//        nop
        bootload_code=32'h00000020;
        #100;
//10001f
//        addiu a1, a1, 200
        bootload_code=32'h24A500C8;
        #100;
//100020-4       
//        syscall
        bootload_code=32'hdeadbeef;
	    #400;
        bootload_code=32'h00XXXX0C;
        #100;
//100025
//l_8:    
//        nop
        bootload_code=32'h00000020;
        #100;
//100026
//        addiu a1, a1, 215
        bootload_code=32'h24A500D7;
        #100;
//100027
//        jal l_10
        bootload_code=32'h0C10002F;
        #100;
//100028
//l_9:
//        # Should not get here
//        nop
        bootload_code=32'h00000020;
        #100;
//100029
//        addiu a1, a1, 1
        bootload_code=32'h24A50001;
        #100;
//10002a-e
//        syscall  
        bootload_code=32'hdeadbeef;
	    #400;
        bootload_code=32'h00XXXX0C;
        #100;
//10002f
//l_10:    
//        nop
        bootload_code=32'h00000020;
        #100;
//100030
//        addu a1, a1, $6
        bootload_code=32'h00A62821;
        #100;
//100031
//        bltzal $4, l_12
        bootload_code=32'h04900008;
        #100;
//100032
//l_11:
//        # Should not get here
//        nop
        bootload_code=32'h00000020;
        #100;
//100033
 //       addiu a1, a1, 400
        bootload_code=32'h24A50190;
        #100;
//100034-8
//        syscall
        bootload_code=32'hdeadbeef;
	    #400;
        bootload_code=32'h00XXXX0C;
        #100;
//100039
//l_12:    
//        nop
        bootload_code=32'h00000020;
        #100;
//10003a
//        addu a1, a1, $6
        bootload_code=32'h00A62821;
        #100;
//10003b
//        bgezal $4, l_11
        bootload_code=32'h0491FFF7;
        #100;        
//10003c
//l_13:    
//        nop
        bootload_code=32'h00000020;
        #100;
//10003d
//        addiu a1, a1, 0xbeb0063d
        bootload_code=32'h24A5063D;
        #100;
//10000b
//        jal l_0
//        bootload_code=32'h0C100006;
//        #100;

end


//100021-4

    bootload_code=32'hdeadbeef;
	#400;
//100025
// SYSCALL
    bootload_code=32'h00XXXX0C;
	#200;

	boot=0;
	rst_b = 0;
	#160;
	rst_b = 1;

	#500;
//	  $finish;
     end


   always @(posedge clk) begin
       if(!rst_b) begin
		    bootload_addr<=32'h400000;
		    bootload_code_in <= 'b0;
		end
        else if(boot) begin
		        bootload_addr<=bootload_addr+4;
		        bootload_code_in<= bootload_code;
	    end
	end
     


   always @(halted)
     begin
	#0;
	if(halted === 1'b1)
	  $finish;
     end
   

endmodule


// Clock module for the MIPS core.  You may increase the clock period
// if your design requires it.
module clock(clockSignal);
   parameter start = 0, halfPeriod = 50;
   output    clockSignal;
   reg 	     clockSignal;
   
   initial
     clockSignal = start;
   
   always
     #halfPeriod clockSignal = ~clockSignal;
   
endmodule
