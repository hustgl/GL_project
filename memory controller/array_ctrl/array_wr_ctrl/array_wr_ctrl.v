module array_wr_ctrl #(
    parameter AXI_ADDR_WIDTH  = 20                                 ,
    parameter AXI_DATA_WIDTH  = 64                                 ,
    parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3,
    parameter AXI_RADDR_WIDTH = 14                                 ,
    parameter AXI_CADDR_WIDTH = AXI_ADDR_WIDTH - AXI_RADDR_WIDTH
)(
    //global signal
    input                            clk               ,
    input                            rst_n             ,
    //mc_apb_cfg
    input      [7:0]                 mc_tras_cfg       ,
    input      [7:0]                 mc_trp_cfg        ,
    input      [7:0]                 mc_trcd_cfg       ,
    input      [7:0]                 mc_twr_cfg        ,
    //fsm_ctrl 
    input      [AXI_FRAME_WIDTH-1:0] axi_frame_wr_data ,
    input                            axi_frame_wr_valid,
    output                           axi_frame_wr_ready,
    output                           wr_done           ,
    //array_if_sel
    output reg                       array_banksel_n_wr,
    output reg [AXI_RADDR_WIDTH-1:0] array_raddr_wr    ,
    output reg                       array_cas_wr      ,
    output reg [AXI_CADDR_WIDTH-1:0] array_caddr_wr    ,
    output                           array_wdata_rdy   ,
    output reg [AXI_DATA_WIDTH-1:0]  array_wdata       
);

parameter IDLE  = 3'd0, UP_RADDR = 3'd1, W_TRCD = 3'd2, WDATA = 3'd3,
          WLAST = 3'd4, W_TWR    = 3'd5, W_TRP  = 3'd6;

reg [2:0] fsm_cs          ;
reg [2:0] fsm_ns          ;
reg       single_data_flag;

//fsm_ctrl signal
wire      sof             ;
wire      eof             ;

//mc_apb_cfg cnt signal
reg [7:0] trcd_cnt        ;
reg [7:0] tras_cnt        ;
reg [7:0] twr_cnt         ;
reg [7:0] trp_cnt         ;

//axi_frame_wr_data preprocess
assign sof                = axi_frame_wr_data[AXI_FRAME_WIDTH-1];
assign eof                = axi_frame_wr_data[AXI_FRAME_WIDTH-2];
assign axi_frame_wr_ready = fsm_cs==IDLE || (fsm_cs==WDATA && ~array_cas_wr); 

//fsm logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fsm_cs <= IDLE  ;
else
    fsm_cs <= fsm_ns;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    single_data_flag <= 1'b0;
else if(fsm_cs==IDLE && axi_frame_wr_valid)
    single_data_flag <= eof;
end

always@(*) begin
case(fsm_cs)
    IDLE: begin
        if(sof && axi_frame_wr_valid)
            fsm_ns = UP_RADDR;
        else
            fsm_ns = IDLE    ;
    end
    UP_RADDR:
        fsm_ns = W_TRCD;
    W_TRCD: begin
        if(trcd_cnt == mc_trcd_cfg-8'd1)
            fsm_ns = single_data_flag? WLAST:WDATA;
        else
            fsm_ns = W_TRCD;
    end        
    WDATA: begin
        if(eof && axi_frame_wr_valid && axi_frame_wr_ready)
            fsm_ns = WLAST;
        else
            fsm_ns = WDATA;
    end        
    WLAST:        
        fsm_ns = W_TWR;
    W_TWR: begin
        if(twr_cnt>=mc_twr_cfg-8'd1 && tras_cnt>=mc_tras_cfg-8'd1)
            fsm_ns = W_TRP;
        else
            fsm_ns = W_TWR;
    end        
    W_TRP: begin
        if(trp_cnt == mc_trp_cfg-8'd1)
            fsm_ns = IDLE;
        else 
            fsm_ns = W_TRP;
    end
    default: fsm_ns = IDLE;
endcase
end

//trcd twr trp cnt logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    trcd_cnt <= 8'd0;
else if(fsm_cs == W_TRCD)
    trcd_cnt <= trcd_cnt + 8'd1;
else
    trcd_cnt <= 8'd0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tras_cnt <= 8'd0;
else if(fsm_cs==W_TRCD || fsm_cs==WDATA || fsm_cs==WLAST || fsm_cs== W_TWR)
    tras_cnt <= tras_cnt + 8'd1;
else
    tras_cnt <= 8'd0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    twr_cnt <= 8'd0;
else if(fsm_cs == W_TWR)
    twr_cnt <= twr_cnt + 8'd1;
else
    twr_cnt <= 8'd0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    trp_cnt <= 8'd0;
else if(fsm_cs == W_TRP)
    trp_cnt <= trp_cnt + 8'd1;
else 
    trp_cnt <= 8'd0;
end

//array output logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_banksel_n_wr <= 1'b1;    
else if(fsm_cs==W_TWR && fsm_ns==W_TRP) // the last clk of W_TWR
    array_banksel_n_wr <= 1'b1;
else if(fsm_cs == UP_RADDR) 
    array_banksel_n_wr <= 1'b0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_raddr_wr <= {AXI_RADDR_WIDTH{1'b0}};
else if(fsm_cs==IDLE && axi_frame_wr_valid) // axi_frame_wr_ready = 1 while IDLE
    array_raddr_wr <= axi_frame_wr_data[83:70];
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_caddr_wr <= {AXI_CADDR_WIDTH{1'b0}};
else if((fsm_cs==IDLE && axi_frame_wr_valid) || (fsm_cs==WDATA && axi_frame_wr_valid && axi_frame_wr_ready)) 
    array_caddr_wr <= axi_frame_wr_data[69:64];
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_wdata <= {AXI_DATA_WIDTH{1'b0}};
else if((fsm_cs==IDLE && axi_frame_wr_valid) || (fsm_cs==WDATA && axi_frame_wr_valid && axi_frame_wr_ready)) 
    array_wdata <= axi_frame_wr_data[63:0];
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_cas_wr <= 1'b0;
else if((fsm_cs==WDATA && array_cas_wr) || fsm_cs==WLAST)  
    array_cas_wr <= 1'b0;
else if((fsm_cs==W_TRCD && trcd_cnt==mc_trcd_cfg-8'd1) || (fsm_cs==WDATA && axi_frame_wr_valid && ~array_cas_wr))
    array_cas_wr <= 1'b1;
end

assign array_wdata_rdy = ~array_cas_wr; //wdata rdy

assign wr_done = trp_cnt==mc_trp_cfg-8'd1; //the last clk of W_TRP, array_wr_ctrl and fsm_ctrl jump to IDLE at the same time

endmodule
