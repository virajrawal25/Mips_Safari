 module mips_cache #(
     parameter ADDR_W   = 30,
     parameter LINES    = 10,
     parameter LINE_W   = $clog2(LINES), 
     parameter EXTRA_W  = 0,
     parameter TAG_W    = ADDR_W - EXTRA_W,
     parameter DATA_W   = 30
     ) (
         input                  clk,
         input                  rst_b,
         input                  cache_input_valid,
         input  [ADDR_W-1:0]    Addr_in,

         input                  write_en,
         input  [ADDR_W-1:0]    Addr_in_write,
         input  [DATA_W-1:0]    Data_in,
    
         output                 cache_hit,
         output                 cache_miss,
         output [DATA_W-1:0]    Data_out
     );



    reg  [(TAG_W+DATA_W)-1:0]       mem[LINES];
    reg  [LINES-1:0]                mem_valid;
    reg  [3:0]                      LRU_count[LINES];
    reg  [3:0]                      count;
    reg  [3:0]                      max_count;
    wire [TAG_W-1:0]                input_tag;
    wire [TAG_W-1:0]                write_tag;
    wire [LINES-1:0]                cache_hit_per_lines;
    wire [LINE_W-1:0]               cache_hit_line;

    assign input_tag 						= Addr_in[0+:TAG_W];
    assign write_tag 						= Addr_in_write[0+:TAG_W];

    genvar n;
    generate 
        for (n=0;n<LINES;n=n+1)begin
            assign cache_hit_per_lines[n] 	=cache_input_valid && mem_valid[n] && (input_tag==mem[n][DATA_W+:TAG_W]);
        end
    endgenerate 
    

    one_hot_to_binary #(.IN_W(LINES), .OUT_W(LINE_W)) one2bin(cache_hit_per_lines,cache_hit_line);
    assign cache_hit 						= |cache_hit_per_lines;
    assign cache_miss 						= !cache_hit && cache_input_valid;
    assign Data_out 						= cache_hit ? mem[cache_hit_line][DATA_W-1:0]:'b0;

    always @(*) begin
        count =0;
        max_count=0;

        if(write_en) begin
            if(!(&mem_valid)) begin
                if(mem_valid[0]==0)
                    count = 0;
                else if(mem_valid[1]==0)
                    count = 1;
                else if(mem_valid[2]==0)
                    count = 2;
                else if(mem_valid[3]==0)
                    count = 3;
                else if(mem_valid[4]==0)
                    count = 4;
                else if(mem_valid[5]==0)
                    count = 5;
                else if(mem_valid[6]==0)
                    count = 6;
                else if(mem_valid[7]==0)
                    count = 7;
                else if(mem_valid[8]==0)
                    count = 8;
                else if(mem_valid[9]==0)
                    count = 9;
            end 
            else begin
                for (int i=0; i < LINES; i=i+1) begin
                    if(max_count<LRU_count[i]) begin
                        max_count=LRU_count[i];
                        count=i;
                    end                    
                end 
            end
        end
    end

    always @(posedge clk, negedge rst_b) begin
        if(!rst_b) begin
            for (int i=0;i<LINES;i=i+1)begin
                mem[i] 			<= 'b0;
            end
            mem_valid 			<= 'b0;
        end
        else begin
            if(write_en) begin
               mem[count] 		<= {write_tag,Data_in};
               mem_valid[count] <= 1'b1;
            end
        end
    end


    genvar k;
    generate
        for (k=0; k<LINES; k=k+1) begin
            always @(posedge clk, negedge rst_b) begin
                if(!rst_b) 
                    LRU_count[k] 		<='b0;
                else 
                    if(cache_hit && (cache_hit_line == k))
                        LRU_count[k] 	<= 'b0;
                    else
                        LRU_count[k] 	<= LRU_count[k] + 1;        
            end
        end
    endgenerate

endmodule

module one_hot_to_binary #(
    parameter IN_W  =  10,
    parameter OUT_W =  4
    )( 
    input  [IN_W-1 :0] vector_one_hot, 
    output reg [OUT_W-1:0] vector_binary
    );

    always @(*) begin
        vector_binary = 0;
        foreach ( vector_one_hot [ index ] ) begin
            if ( vector_one_hot [ index ] == 1'b1 ) begin
                vector_binary = vector_binary | index ;
            end
        end
    end
endmodule
