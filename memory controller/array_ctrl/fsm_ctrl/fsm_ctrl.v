module fsm_ctrl #(
    parameter AXI_ADDR_WIDTH  = 20,
    parameter AXI_DATA_WIDTH  = 64,
    parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3
)(
    //global signal
    input                            clk               ,
    input                            rst_n             ,
    input                            mc_en             ,
    //mc_apb_cfg
    input      [27:0]                mc_rf_start_cfg   ,
    input      [27:0]                mc_rf_period_cfg  ,
    //axi_slave
    input      [AXI_FRAME_WIDTH-1:0] axi_frame_data    ,
    input                            axi_frame_valid   ,
    output reg                       axi_frame_ready   ,
    output     [AXI_DATA_WIDTH-1:0]  array_rdata       ,
    output                           array_rvalid      ,
    //array_wr_ctrl
    output     [AXI_FRAME_WIDTH-1:0] axi_frame_wr_data ,
    output                           axi_frame_wr_valid,
    input                            axi_frame_wr_ready,
    input                            wr_done           ,
    //array_rd_ctrl
    output     [AXI_FRAME_WIDTH-1:0] axi_frame_rd_data ,
    output                           axi_frame_rd_valid,
    input                            axi_frame_rd_ready,
    input                            rd_done           ,
    input      [AXI_DATA_WIDTH-1:0]  array_rd_rdata    ,  //read datas from array_rd_ctrl
    input                            array_rd_rvalid   ,
    //array_rf_ctrl
    output                           rf_start          ,
    input                            rf_done           ,
    //array_if_sel
    output reg [1:0]                 fsm_cs            
);

//fsm signal
parameter IDLE = 2'd0, RF = 2'd1, WR = 2'd2, RD = 2'd3;
reg [1:0]  fsm_ns     ;
//rf signal
reg [27:0] rf_cnt     ;
wire       rf_req     ;
reg        rf_req_wait;  
//rw req signal
wire       rw_flag    ;
wire       wr_req     ;
wire       rd_req     ;

//fsm logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fsm_cs <= IDLE  ;
else
    fsm_cs <= fsm_ns;
end 

always@(*) begin
case(fsm_cs)
    IDLE: begin
        if(mc_en) begin
            if(rf_req || rf_req_wait)
                fsm_ns = RF;
            else if(wr_req)
                fsm_ns = WR;
            else if(rd_req)
                fsm_ns = RD;
            else
                fsm_ns = IDLE;
        end   
        else 
            fsm_ns = IDLE;
    end
    WR: begin
        if(wr_done)
            fsm_ns = IDLE;
        else
            fsm_ns = WR  ;
    end
    RD: begin
        if(rd_done)
            fsm_ns = IDLE;
        else
            fsm_ns = RD  ;
    end
    RF: begin
        if(rf_done)
            fsm_ns = IDLE;
        else
            fsm_ns = RF  ;
    end
    default: fsm_ns = IDLE;
endcase
end


//rf logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rf_cnt <= 28'd0;
else if(mc_en) begin
    if(rf_cnt == mc_rf_period_cfg-28'd1)
        rf_cnt <= 28'd0;
    else
        rf_cnt <= rf_cnt + 28'd1;
end
end 

assign rf_req = rf_cnt==mc_rf_start_cfg;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rf_req_wait <= 1'b0;
else if(fsm_cs==RF)
    rf_req_wait <= 1'b0;
else if((fsm_cs==WR || fsm_cs==RD) && rf_req)
    rf_req_wait <= 1'b1;
end

assign rf_start = (fsm_cs==IDLE) && (fsm_ns==RF);

//rw req ready logic
assign rw_flag = axi_frame_data[AXI_FRAME_WIDTH-3];
assign wr_req  = axi_frame_valid &&  rw_flag && (~rf_req) && (~rf_req_wait);
assign rd_req  = axi_frame_valid && ~rw_flag && (~rf_req) && (~rf_req_wait);

always@(*) begin
if(fsm_cs == WR)
    axi_frame_ready = axi_frame_wr_ready;
else if(fsm_cs == RD)
    axi_frame_ready = axi_frame_rd_ready;
else 
    axi_frame_ready = 1'b0;
end

//array_wr_ctrl logic
assign axi_frame_wr_valid = (fsm_cs==WR)? axi_frame_valid:1'b0;
assign axi_frame_wr_data  = axi_frame_data;

//array_rd_ctrl logic
assign axi_frame_rd_valid = (fsm_cs==RD)? axi_frame_valid:1'b0;
assign axi_frame_rd_data  = axi_frame_data;

//array_rdata logic
assign array_rdata  = array_rd_rdata ;
assign array_rvalid = array_rd_rvalid; 


endmodule
