module axi_slave #(
    parameter AXI_ADDR_WIDTH = 20,
    parameter AXI_DATA_WIDTH = 64,
    parameter AXI_LEN_WIDTH  = 6 ,
    parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3
)(
    //global signal
    input clk      ,
    input rst_n    ,
    input mc_en    ,
//    input prio_ctrl,
    //axi aw channel
    input                       axi_awvalid,
    output                      axi_awready,
    input  [AXI_LEN_WIDTH-1:0]  axi_awlen  ,
    input  [AXI_ADDR_WIDTH-1:0] axi_awaddr ,
    //axi w channel
    input                       axi_wvalid ,
    output                      axi_wready ,
    input  [AXI_DATA_WIDTH-1:0] axi_wdata  ,
    input                       axi_wlast  ,
    //axi ar channel                      
    input                       axi_arvalid,
    output                      axi_arready,
    input  [AXI_LEN_WIDTH-1:0]  axi_arlen  ,
    input  [AXI_ADDR_WIDTH-1:0] axi_araddr ,
    //axi r channel
    output                      axi_rvalid ,
    output [AXI_DATA_WIDTH-1:0] axi_rdata  ,
    output                      axi_rlast  ,
    //axi frame
    output [AXI_FRAME_WIDTH-1:0] axi_frame_data ,
    output                       axi_frame_valid,
    input                        axi_frame_ready,
    input  [AXI_DATA_WIDTH-1:0]  array_rdata    ,
    input                        array_rvalid   
);

parameter IDLE = 3'd0, WADDR = 3'd1, WDATA = 3'd2, RADDR = 3'd3, SEND_RADDR = 3'd4;

reg [2:0] fsm_cs;
reg [2:0] fsm_ns;

//aw signal
wire                                    awfifo_wr_en ;
wire                                    awfifo_rd_en ;
wire                                    awfifo_full  ;
wire                                    awfifo_empty ;
wire [AXI_ADDR_WIDTH+AXI_LEN_WIDTH-1:0] awfifo_wdata ;
wire [AXI_ADDR_WIDTH+AXI_LEN_WIDTH-1:0] awfifo_rdata ;
reg                                     prio_flag    ;   //priority control
reg  [AXI_ADDR_WIDTH-1:0]               rw_frame_addr;
reg  [AXI_LEN_WIDTH -1:0]               rw_burst_len ;
wire                                    rw_flag      ;

//w signal
wire                       wfifo_wr_en;
wire                       wfifo_rd_en;
wire                       wfifo_full ;
wire                       wfifo_empty;
wire [AXI_DATA_WIDTH-1:0]  wfifo_wdata;
wire [AXI_DATA_WIDTH-1:0]  wfifo_rdata;
wire                       sof        ;
wire                       eof        ;
reg  [5:0]                 rw_data_cnt;

//ar signal
wire                                    arfifo_wr_en;
wire                                    arfifo_rd_en;
wire [AXI_ADDR_WIDTH+AXI_LEN_WIDTH-1:0] arfifo_wdata;
wire [AXI_ADDR_WIDTH+AXI_LEN_WIDTH-1:0] arfifo_rdata;
wire                                    arfifo_full ;
wire                                    arfifo_empty;

//rlastfifo signal
wire rlastfifo_wr_en;
wire rlastfifo_rd_en;
wire rlastfifo_wdata;
wire rlastfifo_rdata;
wire rlastfifo_full ;
wire rlastfifo_empty;

//fsm logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fsm_cs <= IDLE;
else
    fsm_cs <= fsm_ns;
end

always@(*) begin
case(fsm_cs)
    IDLE: begin
        if(mc_en) begin
            case({awfifo_empty, arfifo_empty})
            2'b00: if(prio_flag) fsm_ns = WADDR; else fsm_ns = RADDR;
            2'b01: fsm_ns = WADDR;
            2'b10: fsm_ns = RADDR;
            2'b11: fsm_ns = IDLE ;
            default: fsm_ns = IDLE;
            endcase
        end
        else
            fsm_ns = IDLE;
    end
    WADDR:
        fsm_ns = WDATA;
    WDATA: begin
        if(rw_data_cnt==rw_burst_len && axi_frame_valid && axi_frame_ready)
            fsm_ns = IDLE;
        else
            fsm_ns = WDATA;
    end
    RADDR:
        fsm_ns = SEND_RADDR;
    SEND_RADDR: begin
        if(rw_data_cnt==rw_burst_len && axi_frame_valid && axi_frame_ready)
            fsm_ns = IDLE;
        else
            fsm_ns = SEND_RADDR;
    end
    default: fsm_ns = IDLE;
endcase
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    prio_flag <= 1'b1; //default write higher priority 
else if(fsm_cs == IDLE && {awfifo_empty, arfifo_empty} == 2'b00)   
    prio_flag <= ~prio_flag;
end

//awfifo logic
assign awfifo_wr_en = axi_awvalid && axi_awready;
assign axi_awready  = ~awfifo_full;
assign awfifo_wdata = {axi_awlen, axi_awaddr};
assign awfifo_rd_en = fsm_cs==WADDR;

sync_fifo #(
    .FIFO_DEPTH(8),
    .DATA_WIDTH(AXI_ADDR_WIDTH+AXI_LEN_WIDTH)
)axi_awfifo(
    .clk    (clk         ),
    .rst_n  (rst_n       ),
    .wr_en  (awfifo_wr_en),
    .wr_data(awfifo_wdata),
    .rd_en  (awfifo_rd_en),
    .rd_data(awfifo_rdata),
    .full   (awfifo_full ),
    .empty  (awfifo_empty),
    .almost_full (),
    .almost_empty(),
    .overflow    (),
    .underflow   ()
);

/*
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rw_flag <= 1'b0;
else if(fsm_cs == WADDR) 
    rw_flag <= 1'b1;
else if(fsm_cs == RADDR) 
    rw_flag <= 1'b0;
else
    rw_flag <= 1'b0;
end */
assign rw_flag = fsm_cs==WDATA;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rw_frame_addr <= {AXI_ADDR_WIDTH{1'b0}};
else if(fsm_cs == WADDR)
    rw_frame_addr <= awfifo_rdata[19:0];
else if(fsm_cs == RADDR)
    rw_frame_addr <= arfifo_rdata[19:0];
else if(axi_frame_valid && axi_frame_ready)
    rw_frame_addr <= rw_frame_addr + 20'd1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rw_burst_len <= {AXI_LEN_WIDTH{1'b0}};
else if(fsm_cs == WADDR) 
    rw_burst_len <= awfifo_rdata[25:20];
else if(fsm_cs == RADDR)
    rw_burst_len <= arfifo_rdata[25:20];
end

//wfifo logic
assign wfifo_wr_en = axi_wvalid && axi_wready          ;
assign axi_wready  = ~wfifo_full                       ;
assign wfifo_wdata = axi_wdata                         ;
assign wfifo_rd_en = axi_frame_valid && axi_frame_ready;  //axi_frame_valid = (fsm_cs==WDATA && ~wfifo_empty) || fsm_cs==SEND_RADDR

sync_fifo #(
    .FIFO_DEPTH(8),
    .DATA_WIDTH(AXI_DATA_WIDTH)
)axi_wfifo(
    .clk    (clk        ),
    .rst_n  (rst_n      ),
    .wr_en  (wfifo_wr_en),
    .wr_data(wfifo_wdata),
    .rd_en  (wfifo_rd_en),
    .rd_data(wfifo_rdata),
    .full   (wfifo_full ),
    .empty  (wfifo_empty),
    .almost_full (),
    .almost_empty(),
    .overflow    (),
    .underflow   ()
);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rw_data_cnt <= 6'd0;
else if(rw_data_cnt==rw_burst_len && axi_frame_valid && axi_frame_ready)
    rw_data_cnt <= 6'd0;
else if((fsm_cs==WDATA || fsm_cs==SEND_RADDR) && axi_frame_valid && axi_frame_ready)  
    rw_data_cnt <= rw_data_cnt + 6'd1;
end

assign sof = (rw_data_cnt==6'd0 || rw_frame_addr[5:0]==6'd0) && (fsm_cs==WDATA || fsm_cs==SEND_RADDR);
assign eof = (rw_data_cnt==rw_burst_len || rw_frame_addr[5:0]==6'h3f) && axi_frame_valid && axi_frame_ready;

assign axi_frame_data  = {sof,eof,rw_flag,rw_frame_addr,wfifo_rdata};
assign axi_frame_valid = (fsm_cs==WDATA && ~wfifo_empty) || fsm_cs==SEND_RADDR;

//arfifo logic
assign arfifo_wr_en = axi_arvalid && axi_arready;
assign axi_arready  = ~arfifo_full;
assign arfifo_wdata = {axi_arlen, axi_araddr};
assign arfifo_rd_en = fsm_cs==RADDR;

sync_fifo #(
    .FIFO_DEPTH(8),
    .DATA_WIDTH(AXI_ADDR_WIDTH+AXI_LEN_WIDTH)
)axi_arfifo(
    .clk    (clk         ),
    .rst_n  (rst_n       ),
    .wr_en  (arfifo_wr_en),
    .wr_data(arfifo_wdata),
    .rd_en  (arfifo_rd_en),
    .rd_data(arfifo_rdata),
    .full   (arfifo_full ),
    .empty  (arfifo_empty),
    .almost_full (),
    .almost_empty(),
    .overflow    (),
    .underflow   ()    
);

//rlast fifo logic
assign rlastfifo_wr_en = axi_frame_valid && axi_frame_ready && ~rw_flag;
assign rlastfifo_wdata = (rw_data_cnt==rw_burst_len) && axi_frame_valid && axi_frame_ready;
assign rlastfifo_rd_en = array_rvalid;

//depth at least 64
sync_fifo #(
    .FIFO_DEPTH(64),
    .DATA_WIDTH(1)
)axi_rlastfifo(
    .clk    (clk            ),
    .rst_n  (rst_n          ),
    .wr_en  (rlastfifo_wr_en),
    .wr_data(rlastfifo_wdata),
    .rd_en  (rlastfifo_rd_en),
    .rd_data(rlastfifo_rdata),
    .full   (rlastfifo_full ),
    .empty  (rlastfifo_empty),
    .almost_full (),
    .almost_empty(),
    .overflow    (),
    .underflow   ()    
);

assign axi_rdata  = array_rdata    ;
assign axi_rvalid = array_rvalid   ;
assign axi_rlast  = rlastfifo_rdata;

endmodule
