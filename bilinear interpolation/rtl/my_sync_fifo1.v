module my_sync_fifo1 #(
    parameter DW           = 8   ,
    parameter DATA_WIDTH   = DW*2,
    parameter INPUT_WIDTH  = DW*6,
    parameter OUTPUT_WIDTH = DW*4,
    parameter FIFO_DEPTH   = 64
)(
    input                         clk    ,
    input                         rst_n  ,
    input                         wr_en1 ,
    input                         wr_en2 ,
    input      [INPUT_WIDTH-1:0]  wr_data,
    input                         rd_en  ,
    output reg [OUTPUT_WIDTH-1:0] rd_data,
    output                        full   ,
    output                        empty
);

//define localparam with $clog2
localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

//--------internal signals define--------//
reg [ADDR_WIDTH-1:0] wr_ptr  ;
reg [ADDR_WIDTH-1:0] rd_ptr  ;
reg [ADDR_WIDTH  :0] fifo_cnt;

reg [DATA_WIDTH-1:0] buf_mem[FIFO_DEPTH-1:0];

integer I;

//fifo_cnt logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fifo_cnt <= {(ADDR_WIDTH+1){1'b0}};
else if(wr_en1 && !wr_en2)
    fifo_cnt <= fifo_cnt + 2'd2;
else if(wr_en1 && wr_en2 && !full)
    fifo_cnt <= fifo_cnt + 1'b1;
else if(!wr_en1 && wr_en2)
    fifo_cnt <= fifo_cnt - 1'b1;
else if(rd_en && !empty)
    fifo_cnt <= fifo_cnt - 2'd2;            
end

//wr_ptr logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    wr_ptr <= {(ADDR_WIDTH){1'b0}};
else if(wr_en1 && !wr_en2)
    wr_ptr <= wr_ptr + 2'd2;
else if(wr_en1 && wr_en2 && !full)
    wr_ptr <= wr_ptr + 2'd3;
else if(!wr_en1 && wr_en2)
    wr_ptr <= wr_ptr + 2'd1;    
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rd_ptr <= {(ADDR_WIDTH){1'b0}};
else if(rd_en && ~empty)
    rd_ptr <= rd_ptr + 2'd2;
end

//mem logic  write only when wr_en && ~full
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(I = 0; I < FIFO_DEPTH; I = I+1)
            buf_mem[I] <= {DATA_WIDTH{1'b0}};
    end
    else if(wr_en1 && !wr_en2) begin
        buf_mem[wr_ptr     ] <= wr_data[DW*4-1:DW*2];
        buf_mem[wr_ptr+1'b1] <= wr_data[DW*2-1:0   ];
    end      
    else if(wr_en1 && wr_en2 && !full) begin
        buf_mem[wr_ptr     ] <= wr_data[DW*6-1:DW*4];
        buf_mem[wr_ptr+1'b1] <= wr_data[DW*4-1:DW*2];
        buf_mem[wr_ptr+2'd2] <= wr_data[DW*2-1:0   ];
    end
    else if(!wr_en1 && wr_en2) begin
        buf_mem[wr_ptr     ] <= wr_data[DW*6-1:DW*4];
    end  
end

always@(*) begin
    rd_data = {buf_mem[rd_ptr][2*DW-1:DW], buf_mem[rd_ptr+1'b1][2*DW-1:DW], buf_mem[rd_ptr][DW-1:0], buf_mem[rd_ptr+1'b1][DW-1:0]};
end

assign full = fifo_cnt==FIFO_DEPTH;

assign empty = fifo_cnt=={(ADDR_WIDTH+1){1'b0}};

endmodule