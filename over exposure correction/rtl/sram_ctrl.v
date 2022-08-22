module sram_ctrl #(
    parameter DW_IN         = 10,
    parameter HB            = 52,
    parameter WIN_W         = 26,    
    parameter ROW_CNT_WIDTH = 4 ,
    parameter COL_CNT_WIDTH = 5 ,
    parameter HB_CNT_WIDTH  = 6 
)(
    input                          clk                 ,
    input                          rst_n               ,
    input      [ROW_CNT_WIDTH-1:0] row_cnt             ,
    input      [COL_CNT_WIDTH-1:0] col_cnt             ,
    input      [HB_CNT_WIDTH-1 :0] hb_cnt              ,
    input                          hsync_out           ,
    input      [DW_IN*4-1      :0] imo                 ,

    output reg                     sram1_cen           ,
    output reg                     sram1_wen           ,
    output reg [11             :0] sram1_addr          ,
    output reg                     sram2_cen           ,
    output reg                     sram2_wen           ,
    output reg [11             :0] sram2_addr          ,
    output reg                     sram3_cen           ,
    output reg                     sram3_wen           ,
    output reg [11             :0] sram3_addr          ,    
    output reg                     sram4_cen           ,
    output reg                     sram4_wen           ,  
    output reg [11             :0] sram4_addr          ,    
    output reg [DW_IN*4-1      :0] sram1_wr_data       ,
    output reg [DW_IN*4-1      :0] sram2_wr_data       ,
    output reg [DW_IN*4-1      :0] sram3_wr_data       ,
    output reg [DW_IN*4-1      :0] sram4_wr_data       ,
    output                         sram_prefetch_rd_req,
    output                         sram_flow_rd_req    ,
    output reg [11             :0] wr_addr             ,
    output reg [11             :0] prefetch_addr       ,
    output reg [11             :0] rd_addr             
);

assign sram_prefetch_rd_req = (hb_cnt>=HB-9 && hb_cnt<=HB-3);
assign sram_flow_rd_req     = (col_cnt>=5'd12 && col_cnt<=WIN_W-1);

always@(*) begin
if(hsync_out && row_cnt[1:0]==2'b00) //line0 4 8... write
    sram1_cen = 1'b0;
else if(sram_prefetch_rd_req && row_cnt[1:0]!=2'b11) //line3 7... not prefetch
    sram1_cen = 1'b0;
else if(sram_flow_rd_req && row_cnt[1:0]!=2'b00) //line0 4 8... not read
    sram1_cen = 1'b0;
else 
    sram1_cen = 1'b1;
end

always@(*) begin
if(hsync_out && row_cnt[1:0] == 2'b00)
    sram1_wen = 1'b0;
else
    sram1_wen = 1'b1;
end

always@(*) begin
if(hsync_out && row_cnt[1:0]==2'b01) //line1 5 9... write
    sram2_cen = 1'b0;
else if(sram_prefetch_rd_req && row_cnt[1:0]!=2'b00) //line0 4 8... not prefetch
    sram2_cen = 1'b0;
else if(sram_flow_rd_req && row_cnt!=4'd0 && row_cnt[1:0]!=2'b01) //line 0 1 5 9... not read
    sram2_cen = 1'b0;
else 
    sram2_cen = 1'b1;
end

always@(*) begin
if(hsync_out && row_cnt[1:0] == 2'b01)
    sram2_wen = 1'b0;
else
    sram2_wen = 1'b1;
end

always@(*) begin
if(hsync_out && row_cnt[1:0]==2'b10) //line2 6 10... write
    sram3_cen = 1'b0;
else if(sram_prefetch_rd_req && row_cnt!=4'd0 && row_cnt[1:0]!=2'b01) //line0 1 5 9 ... not prefetch
    sram3_cen = 1'b0;
else if(sram_flow_rd_req && row_cnt!=4'd0 && row_cnt!= 4'd1 && row_cnt[1:0]!=2'b10) //line0 1 2 6 10... not read
    sram3_cen = 1'b0;
else 
    sram3_cen = 1'b1;
end

always@(*) begin
if(hsync_out && row_cnt[1:0] == 2'b10)
    sram3_wen = 1'b0;
else
    sram3_wen = 1'b1;
end

always@(*) begin
if(hsync_out && row_cnt[1:0]==2'b11) //line 3 7 11...
    sram4_cen = 1'b0;
else if(sram_prefetch_rd_req && row_cnt!=4'd0 && row_cnt!=4'd1 && row_cnt[1:0]!=2'b10)    
    sram4_cen = 1'b0;
else if(sram_flow_rd_req && row_cnt!=4'd0 && row_cnt!=4'd1 && row_cnt!=4'd2 && row_cnt[1:0]!=2'b11)
    sram4_cen = 1'b0;
else 
    sram4_cen = 1'b1;
end

always@(*) begin
if(hsync_out && row_cnt[1:0]==2'b11)
    sram4_wen = 1'b0;
else
    sram4_wen = 1'b1;
end

always@(*) begin
if(hsync_out && row_cnt[1:0] == 2'b00)
    sram1_wr_data = imo;
else
    sram1_wr_data = {DW_IN*4{1'b0}};    
end

always@(*) begin
if(hsync_out && row_cnt[1:0] == 2'b01)
    sram2_wr_data = imo;
else
    sram2_wr_data = {DW_IN*4{1'b0}};    
end

always@(*) begin
if(hsync_out && row_cnt[1:0] == 2'b10)
    sram3_wr_data = imo;
else
    sram3_wr_data = {DW_IN*4{1'b0}};  
end

always@(*) begin
if(hsync_out && row_cnt[1:0] == 2'b11)
    sram4_wr_data = imo;
else
    sram4_wr_data = {DW_IN*4{1'b0}};  
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    wr_addr <= 12'd0;
else if(hsync_out)
    wr_addr <= wr_addr + 12'd1;
else    
    wr_addr <= 12'd0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    prefetch_addr <= 12'd6;
else if(sram_prefetch_rd_req)
    prefetch_addr <= prefetch_addr + 12'd1;
else 
    prefetch_addr <= 12'd6;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rd_addr <= 12'd13;
else if(sram_flow_rd_req)
    rd_addr <= rd_addr + 12'd1;
else
    rd_addr <= 12'd13;
end

always@(*) begin
    if(sram1_cen == 1'b0) begin
        if(hsync_out)
            sram1_addr = wr_addr;
        else if(sram_prefetch_rd_req)
            sram1_addr = prefetch_addr;
        else if(sram_flow_rd_req)
            sram1_addr = rd_addr;
        else
            sram1_addr = 12'd0;
    end
    else
        sram1_addr = 12'd0;
end

always@(*) begin
    if(sram2_cen == 1'b0) begin
        if(hsync_out)
            sram2_addr = wr_addr;
        else if(sram_prefetch_rd_req)
            sram2_addr = prefetch_addr;
        else if(sram_flow_rd_req)
            sram2_addr = rd_addr;
        else
            sram2_addr = 12'd0;
    end
    else
        sram2_addr = 12'd0;
end

always@(*) begin
    if(sram3_cen == 1'b0) begin
        if(hsync_out)
            sram3_addr = wr_addr;
        else if(sram_prefetch_rd_req)
            sram3_addr = prefetch_addr;
        else if(sram_flow_rd_req)
            sram3_addr = rd_addr;
        else
            sram3_addr = 12'd0;
    end
    else
        sram3_addr = 12'd0;
end

always@(*) begin
    if(sram4_cen == 1'b0) begin
        if(hsync_out)
            sram4_addr = wr_addr;
        else if(sram_prefetch_rd_req)
            sram4_addr = prefetch_addr;
        else if(sram_flow_rd_req)
            sram4_addr = rd_addr;
        else
            sram4_addr = 12'd0;
    end
    else
        sram4_addr = 12'd0;
end



endmodule
