module regfile (/*AUTOARG*/
   // Outputs
   rs_data, rt_data,
   // Inputs
   rs_num, rt_num, rd_num, rd_data, rd_we, clk, rst_b, halted
   );
   	input               clk;
   	input               rst_b;

   	input               rd_we;

	input  [4:0]        rs_num; 
	input  [4:0]        rt_num; 
	input  [4:0]        rd_num; 
	input  [31:0]       rd_data;

	output [31:0]       rs_data;
	output [31:0]       rt_data;
	
	input               halted;


	reg   [31:0]       mem[0:31];
	integer            i;

	always @(posedge clk or negedge rst_b) begin 
		if (!rst_b) begin
			`include "regfile_init.svh"
		end else if (rd_we && (rd_num != 0)) begin 
			mem[rd_num] <= rd_data; 
		end 
	end 

	assign rs_data = (rs_num == 0) ? 32'h0 : mem[rs_num];
	assign rt_data = (rt_num == 0) ? 32'h0 : mem[rt_num];
	
	// synthesis translate_off
	integer fd;
	always @(halted) begin
		if (rst_b && halted) begin
			fd = $fopen("regdump.txt");

			$display("--- 18-447 Register file dump ---");
			$display("=== Simulation Cycle %d ===", $time);
			
			$fdisplay(fd, "--- 18-447 Register file dump ---");
			$fdisplay(fd, "=== Simulation Cycle %d ===", $time);
			
			for(i = 0; i < 32; i = i+1) begin
				$display("R%d\t= 0x%8x\t( %0d )", i, mem[i], mem[i]);
				$fdisplay(fd, "R%d\t= 0x%8h\t( %0d )", i, mem[i], mem[i]); 
			end
			
			$display("--- End register file dump ---");
			$fdisplay(fd, "--- End register file dump ---");
			
			$fclose(fd);
		end
	end
	// synthesis translate_on
 endmodule

