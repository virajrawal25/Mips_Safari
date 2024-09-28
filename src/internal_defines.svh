////
//// Internal signal constants
////

// ALU
`define ALU_ADD         4'b0000
`define ALU_SUB         4'b0001
`define ALU_AND	        4'b0010
`define ALU_OR	        4'b0011
`define ALU_XOR	        4'b0100
`define ALU_NOR	        4'b0101
`define ALU_SHIFT_LEFT	4'b0110
`define ALU_SHIFT_RIGHT	4'b0111
`define ALU_LOAD_STORE  4'b1000
`define ALU_LESS_THAN   4'b1001


`define NOT_TAKEN       2'b00
`define LIKELY_NOT_TAKEN 2'b01;
`define LIKELY_TAKEN    2'b10;
`define TAKEN           2'b11;
