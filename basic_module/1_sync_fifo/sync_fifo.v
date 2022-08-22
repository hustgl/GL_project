module sync_fifo #(
    parameter DATA_WIDTH   = 8           ,
    parameter FIFO_DEPTH   = 8           ,
    parameter AFULL_DEPTH  = FIFO_DEPTH-1,
    parameter AEMPTY_DEPTH = 1           ,
    parameter RDATA_MODE   = 0                //0: comb 1:reg,default 0 
)(
    input                       clk         ,
    input                       rst_n       ,
    //input signal
    input                       wr_en       ,
    input      [DATA_WIDTH-1:0] wr_data     ,
    input                       rd_en       ,
    output reg [DATA_WIDTH-1:0] rd_data     ,
    //fifo status
    output                      full        ,
    output                      almost_full ,
    output                      empty       ,
    output                      almost_empty,
    output reg                  overflow    ,
    output reg                  underflow    
);

//define ADDR_WIDTH with $clog2
localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

//internal signals
reg [ADDR_WIDTH-1:0] wr_ptr  ; //write pointer
reg [ADDR_WIDTH-1:0] rd_ptr  ; //read  pointer

reg [ADDR_WIDTH  :0] fifo_cnt;

//mem
reg [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

integer I;

//fifo_cnt logic 
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fifo_cnt <= {(ADDR_WIDTH+1){1'b0}};
else if(wr_en && ~full && rd_en && ~empty)
    fifo_cnt <= fifo_cnt;
else if(wr_en && ~full)
    fifo_cnt <= fifo_cnt + 1'b1;
else if(rd_en && ~empty)
    fifo_cnt <= fifo_cnt - 1'b1;
end

//write pointer logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    wr_ptr <= {ADDR_WIDTH{1'b0}};
else if(wr_en && ~full) begin
    if(wr_ptr == FIFO_DEPTH-1)
        wr_ptr <= {ADDR_WIDTH{1'b0}};
    else
        wr_ptr <= wr_ptr + 1'b1;
    end    
end

//read pointer logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rd_ptr <= {ADDR_WIDTH{1'b0}};
else if(rd_en && ~empty) begin
    if(rd_ptr == FIFO_DEPTH-1)
        rd_ptr <= {ADDR_WIDTH{1'b0}};
    else
        rd_ptr <= rd_ptr + 1'b1;
    end
end

//mem logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    for(I = 0; I < FIFO_DEPTH; I = I+1)
        mem[I] <= {DATA_WIDTH{1'b0}};
else if(wr_en && ~full)
    mem[wr_ptr] <= wr_data;       
end

generate 
if(RDATA_MODE == 1'b0) begin
    always@(*)
        rd_data = mem[rd_ptr];
end
else begin
    always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rd_data <= {DATA_WIDTH{1'b0}};
    else if(rd_en && ~empty)
        rd_data <= mem[rd_ptr];
    end
end
endgenerate

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    overflow <= 1'b0;
else if(wr_en && full)
    overflow <= 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    underflow <= 1'b0;
else if(rd_en && empty)
    underflow <= 1'b1;
end

assign full  = fifo_cnt==FIFO_DEPTH;

assign empty = fifo_cnt=={(ADDR_WIDTH+1){1'b0}};

assign almost_full  = fifo_cnt>=AFULL_DEPTH;

assign almost_empty = fifo_cnt<=AEMPTY_DEPTH;

endmodule
