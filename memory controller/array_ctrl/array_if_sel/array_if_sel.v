module array_if_sel #(
    parameter AXI_ADDR_WIDTH  = 20                                 ,
    parameter AXI_DATA_WIDTH  = 64                                 ,
    parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3,
    parameter AXI_RADDR_WIDTH = 14                                 ,
    parameter AXI_CADDR_WIDTH = AXI_ADDR_WIDTH - AXI_RADDR_WIDTH    
)(
    //gloabl signal
    input                            clk                   ,
    input                            rst_n                 ,
    //fsm_ctrl
    input      [1:0]                 fsm_cs                ,
    //array
    output reg                       array_banksel_n       ,
    output reg [AXI_RADDR_WIDTH-1:0] array_raddr           ,
    output                           array_cas_wr          ,
    output     [AXI_CADDR_WIDTH-1:0] array_caddr_wr        ,
    output                           array_cas_rd          ,
    output     [AXI_CADDR_WIDTH-1:0] array_caddr_rd        ,
    output                           array_wdata_rdy       ,
    output     [AXI_DATA_WIDTH-1 :0] array_wdata           ,
    input                            array_rdata_rdy       ,
    input      [AXI_DATA_WIDTH-1 :0] array_rdata           ,
    //array_wr_ctrl
    input                            array_banksel_n_wr    ,
    input      [AXI_RADDR_WIDTH-1:0] array_raddr_wr        ,
    input                            bypass_array_cas_wr   ,
    input      [AXI_CADDR_WIDTH-1:0] bypass_array_caddr_wr ,
    input                            bypass_array_wdata_rdy,
    input      [AXI_DATA_WIDTH-1:0]  bypass_array_wdata    ,  
    //array_rd_ctrl
    input                            array_banksel_n_rd    ,
    input      [AXI_RADDR_WIDTH-1:0] array_raddr_rd        ,
    input                            bypass_array_cas_rd   ,
    input      [AXI_CADDR_WIDTH-1:0] bypass_array_caddr_rd ,
    output                           bypass_array_rdata_rdy,
    output     [AXI_DATA_WIDTH -1:0] bypass_array_rdata    ,
    //array_rf_ctrl
    input                            array_banksel_n_rf    ,
    input      [AXI_RADDR_WIDTH-1:0] array_raddr_rf          
);

parameter IDLE = 2'd0, RF = 2'd1, WR = 2'd2, RD = 2'd3;

always@(*) begin
case(fsm_cs)
    IDLE: array_banksel_n = 1'b1              ;
    RF  : array_banksel_n = array_banksel_n_rf;
    WR  : array_banksel_n = array_banksel_n_wr;
    RD  : array_banksel_n = array_banksel_n_rd;
    default: array_banksel_n = 1'b1           ;
endcase
end

always@(*) begin
case(fsm_cs)
    IDLE: array_raddr = {AXI_RADDR_WIDTH{1'b0}}   ;
    RF  : array_raddr = array_raddr_rf            ;
    WR  : array_raddr = array_raddr_wr            ;
    RD  : array_raddr = array_raddr_rd            ;
    default: array_raddr = {AXI_RADDR_WIDTH{1'b0}};
endcase
end

assign array_cas_wr    = bypass_array_cas_wr   ;      
assign array_caddr_wr  = bypass_array_caddr_wr ;        
assign array_cas_rd    = bypass_array_cas_rd   ;         
assign array_caddr_rd  = bypass_array_caddr_rd ;       
assign array_wdata_rdy = bypass_array_wdata_rdy;       
assign array_wdata     = bypass_array_wdata    ;   

assign bypass_array_rdata_rdy =  array_rdata_rdy;       
assign bypass_array_rdata     =  array_rdata    ;         

endmodule
