module array_rd_ctrl #(
    parameter AXI_ADDR_WIDTH  = 20                                 ,
    parameter AXI_DATA_WIDTH  = 64                                 ,
    parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3,
    parameter AXI_RADDR_WIDTH = 14                                 ,
    parameter AXI_CADDR_WIDTH = AXI_ADDR_WIDTH - AXI_RADDR_WIDTH
)(
    // global signal
    input                            clk               ,
    input                            rst_n             ,
    //mc_apb_cfg
    input      [7:0]                 mc_tras_cfg       ,
    input      [7:0]                 mc_trp_cfg        ,
    input      [7:0]                 mc_trcd_cfg       ,
    input      [7:0]                 mc_trtp_cfg       ,
    //fsm_ctrl
    input      [AXI_FRAME_WIDTH-1:0] axi_frame_rd_data ,
    input                            axi_frame_rd_valid,
    output                           axi_frame_rd_ready,
    output                           rd_done           ,
    output     [AXI_DATA_WIDTH-1:0]  array_rd_rdata    ,
    output                           array_rd_rvalid   ,
    //array_if_sel
    output reg                       array_banksel_n_rd,
    output reg [AXI_RADDR_WIDTH-1:0] array_raddr_rd    ,
    output reg                       array_cas_rd      ,
    output reg [AXI_CADDR_WIDTH-1:0] array_caddr_rd    ,
    input                            array_rdata_rdy   ,
    input      [AXI_DATA_WIDTH-1:0]  array_rdata
); 

parameter IDLE        = 3'd0, UP_RADDR = 3'd1, R_TRCD  = 3'd2, R_SEND_CADDR = 3'd3,
          R_SEND_LAST = 3'd4, R_TRTP   = 3'd5, PRE_TRP = 3'd6, R_TRP        = 3'd7;

reg [2:0] fsm_cs          ;
reg [2:0] fsm_ns          ;
reg       single_send_flag;

//fsm_ctrl signal
wire      sof             ;
wire      eof             ;

//mc_apb_cfg cnt signal
reg [7:0] tras_cnt        ;
reg [7:0] trcd_rtp_rp_cnt ;

//async fifo signal
wire                      asyncfifo_array_rdata_wr_clk ;
wire                      asyncfifo_array_rdata_rd_en  ;
wire [AXI_DATA_WIDTH-1:0] asyncfifo_array_rdata_rd_data;
wire                      asyncfifo_array_rdata_empty  ;

//axi_frame_rd_data preprocess
assign sof                = axi_frame_rd_data[AXI_FRAME_WIDTH-1];
assign eof                = axi_frame_rd_data[AXI_FRAME_WIDTH-2];
assign axi_frame_rd_ready = fsm_cs==IDLE || (fsm_cs==R_SEND_CADDR && ~array_cas_rd); 

//fsm logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fsm_cs <= IDLE  ;
else
    fsm_cs <= fsm_ns;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    single_send_flag <= 1'b0;
else if(fsm_cs==IDLE && axi_frame_rd_valid)
    single_send_flag <= eof;
end

always@(*) begin
case(fsm_cs)
    IDLE: begin
        if(sof && axi_frame_rd_valid)
            fsm_ns = UP_RADDR;
        else
            fsm_ns = IDLE    ;
    end
    UP_RADDR: begin
        fsm_ns = R_TRCD;
    end
    R_TRCD: begin
        if(trcd_rtp_rp_cnt == 8'd0) 
            fsm_ns = single_send_flag? R_SEND_LAST: R_SEND_CADDR;
        else
            fsm_ns = R_TRCD;
    end
    R_SEND_CADDR: begin
        if(eof && axi_frame_rd_valid && axi_frame_rd_ready)
            fsm_ns = R_SEND_LAST;
        else
            fsm_ns = R_SEND_CADDR;
    end
    R_SEND_LAST: 
        fsm_ns = R_TRTP;
    R_TRTP: begin
        if(trcd_rtp_rp_cnt<=8'd1 && tras_cnt<=8'd1) //the last clk of trtp is PRE_TRP
            fsm_ns = PRE_TRP;
        else
            fsm_ns = R_TRTP;
    end
    PRE_TRP:
        fsm_ns = R_TRP;
    R_TRP: begin
        if(trcd_rtp_rp_cnt == 8'd0)
            fsm_ns = IDLE;
        else
            fsm_ns = R_TRP;
    end
    default: fsm_ns = IDLE;
endcase
end

//trcd trtp trp cnt logic
/*
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
end*/

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    trcd_rtp_rp_cnt <= 8'd0;
else begin
    case(fsm_cs) 
    UP_RADDR   : trcd_rtp_rp_cnt <= mc_trcd_cfg-8'd1;
    R_SEND_LAST: trcd_rtp_rp_cnt <= mc_trtp_cfg-8'd1;
    PRE_TRP    : trcd_rtp_rp_cnt <= mc_trp_cfg -8'd1;
    default:     trcd_rtp_rp_cnt <= (trcd_rtp_rp_cnt==8'd0)? trcd_rtp_rp_cnt:trcd_rtp_rp_cnt-8'd1;
    endcase
end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tras_cnt <= 8'd0;
else if(fsm_cs==UP_RADDR)
    tras_cnt <= mc_tras_cfg - 8'd1;
else if(tras_cnt==8'd0)
    tras_cnt <= tras_cnt;
else    
    tras_cnt <= tras_cnt - 8'd1;
end

//array output logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_banksel_n_rd <= 1'b1;
else if(fsm_cs==PRE_TRP)
    array_banksel_n_rd <= 1'b1;
else if(fsm_cs == UP_RADDR)
    array_banksel_n_rd <= 1'b0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_raddr_rd <= {AXI_RADDR_WIDTH{1'b0}};
else if(fsm_cs==IDLE && axi_frame_rd_valid)
    array_raddr_rd <= axi_frame_rd_data[(AXI_DATA_WIDTH+AXI_CADDR_WIDTH)+:AXI_RADDR_WIDTH];
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_caddr_rd <= {AXI_CADDR_WIDTH{1'b1}};
else if((fsm_cs==IDLE || (fsm_cs==R_SEND_CADDR && axi_frame_rd_ready)) && axi_frame_rd_valid) 
    array_caddr_rd <= axi_frame_rd_data[AXI_DATA_WIDTH+:AXI_CADDR_WIDTH];
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_cas_rd <= 1'b0;
else if((fsm_cs==R_SEND_CADDR && array_cas_rd) || fsm_cs==R_SEND_LAST)
    array_cas_rd <= 1'b0;
else if((fsm_cs==R_TRCD && trcd_rtp_rp_cnt==8'd0) || (fsm_cs==R_SEND_CADDR && axi_frame_rd_valid && ~array_cas_rd))
    array_cas_rd <= 1'b1;
end

//async read data from array
assign rd_done = fsm_cs==R_TRP && trcd_rtp_rp_cnt==8'd0;

assign asyncfifo_array_rdata_wr_clk  = array_rdata_rdy             ;
assign asyncfifo_array_rdata_rd_en   = ~asyncfifo_array_rdata_empty;

async_fifo #(
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .FIFO_DEPTH(8)
)U_async_array_rdata0(
    .wr_clk  (asyncfifo_array_rdata_wr_clk ),
    .wr_rst_n(rst_n                        ),
    .wr_en   (1'b1                         ),
    .wr_data (array_rdata                  ),
    .rd_clk  (clk                          ),
    .rd_rst_n(rst_n                        ),
    .rd_en   (asyncfifo_array_rdata_rd_en  ),
    .rd_data (asyncfifo_array_rdata_rd_data),
    .full    (                             ),
    .afull   (                             ),
    .aempty  (                             ),
    .empty   (asyncfifo_array_rdata_empty  )
);

assign array_rd_rdata  = asyncfifo_array_rdata_rd_data;
assign array_rd_rvalid = ~asyncfifo_array_rdata_empty ;

endmodule
