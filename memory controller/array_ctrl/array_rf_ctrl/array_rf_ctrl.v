module array_rf_ctrl #(
    parameter AXI_RADDR_WIDTH = 14
)(
    //global signal
    input                            clk               ,
    input                            rst_n             ,
    //mc_apb_cfg
    input      [7:0]                 mc_tras_cfg       ,
    input      [7:0]                 mc_trp_cfg        ,
    //fsm_ctrl
    input                            rf_start          ,
    output                           rf_done           ,
    //array_if_sel
    output reg                       array_banksel_n_rf,
    output reg [AXI_RADDR_WIDTH-1:0] array_raddr_rf    
);

parameter IDLE = 2'd0, UP_RADDR = 2'd1, RF_TRAS = 2'd2, RF_TRP = 2'd3;

reg [1:0] fsm_cs;
reg [1:0] fsm_ns;

reg [7:0] tras_cnt;
reg [7:0] trp_cnt ;
/*
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
end*/
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fsm_cs <= IDLE;
else
    fsm_cs <= fsm_ns;
end

always@(*) begin
case(fsm_cs)
    IDLE: begin
        if(rf_start) 
            fsm_ns = UP_RADDR;
        else
            fsm_ns = IDLE;
    end
    UP_RADDR:
        fsm_ns = RF_TRAS;
    RF_TRAS: begin
        if(tras_cnt == mc_tras_cfg - 8'd1)
            fsm_ns = RF_TRP;
        else
            fsm_ns = RF_TRAS;
    end
    RF_TRP: begin
        if(trp_cnt == mc_trp_cfg - 8'd1)
            if(array_raddr_rf == 14'd0)
                fsm_ns = IDLE;
            else
                fsm_ns = RF_TRAS;
        else
            fsm_ns = RF_TRP;
    end
endcase
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tras_cnt <= 8'd0;
else if(fsm_cs == RF_TRAS)
    tras_cnt <= tras_cnt + 8'd1;
else
    tras_cnt <= 8'd0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    trp_cnt <= 8'd0;
else if(fsm_cs == RF_TRP)
    trp_cnt <= trp_cnt + 8'd1;
else
    trp_cnt <= 8'd0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_raddr_rf <= {AXI_RADDR_WIDTH{1'b0}};    
else if(rf_start)
    array_raddr_rf <= 14'h3ffa;
else begin
    if(mc_trp_cfg == 8'd1) begin
        if(tras_cnt == mc_tras_cfg-8'd1)
            array_raddr_rf <= array_raddr_rf + 14'd1;
    end        
    else begin
        if(trp_cnt == mc_trp_cfg-8'd2)
            array_raddr_rf <= array_raddr_rf + 14'd1; 
    end        
end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_banksel_n_rf <= 1'b1;
else if(tras_cnt == mc_tras_cfg-8'd1)
    array_banksel_n_rf <= 1'b1;
else if(fsm_cs==UP_RADDR || (fsm_cs==RF_TRP && fsm_ns==RF_TRAS))
    array_banksel_n_rf <= 1'b0;
end

assign rf_done = fsm_cs==RF_TRP && fsm_ns==IDLE;

endmodule
