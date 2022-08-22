module mc_top #(
    parameter APB_ADDR_WIDTH  = 16                                 ,
    parameter APB_DATA_WIDTH  = 32                                 ,
    parameter AXI_ADDR_WIDTH  = 20                                 ,
    parameter AXI_DATA_WIDTH  = 64                                 ,
    parameter AXI_LEN_WIDTH   = 6                                  ,
    parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3,    
    parameter AXI_RADDR_WIDTH = 14                                 ,
    parameter AXI_CADDR_WIDTH = AXI_ADDR_WIDTH - AXI_RADDR_WIDTH        
)(
    //global signal                                 
    input                            clk            ,
    input                            rst_n          ,
    // apb_pclk
    input                            apb_pclk       ,
    input                            apb_prstn      ,
    input                            apb_psel       ,
    input                            apb_penable    , 
    input                            apb_pwrite     ,
    input      [APB_ADDR_WIDTH-1:0]  apb_paddr      ,
    input      [APB_DATA_WIDTH-1:0]  apb_pwdata     ,
    output     [APB_DATA_WIDTH-1:0]  apb_prdata     ,
    output                           apb_pready     ,    
    //axi aw channel
    input                            axi_awvalid    ,
    output                           axi_awready    ,
    input      [AXI_LEN_WIDTH-1:0]   axi_awlen      ,
    input      [AXI_ADDR_WIDTH-1:0]  axi_awaddr     ,
    //axi w channel
    input                            axi_wvalid     ,
    output                           axi_wready     ,
    input      [AXI_DATA_WIDTH-1:0]  axi_wdata      ,
    input                            axi_wlast      ,
    //axi ar channel                       
    input                            axi_arvalid    ,
    output                           axi_arready    ,
    input      [AXI_LEN_WIDTH-1:0]   axi_arlen      ,
    input      [AXI_ADDR_WIDTH-1:0]  axi_araddr     ,
    //axi r channel
    output                           axi_rvalid     ,
    output     [AXI_DATA_WIDTH-1:0]  axi_rdata      ,
    output                           axi_rlast      ,
    //array 
    output                           array_banksel_n,
    output     [AXI_RADDR_WIDTH-1:0] array_raddr    ,
    output                           array_cas_wr   ,
    output     [AXI_CADDR_WIDTH-1:0] array_caddr_wr ,
    output                           array_cas_rd   ,
    output     [AXI_CADDR_WIDTH-1:0] array_caddr_rd ,
    output                           array_wdata_rdy,
    output     [AXI_DATA_WIDTH-1 :0] array_wdata    ,
    input                            array_rdata_rdy,
    input      [AXI_DATA_WIDTH-1 :0] array_rdata          
);

//mc_en signal
wire apb_mc_en;
reg  mc_en_tmp;
reg  mc_en    ;

//mc_apb_cfg and array_ctrl signal
wire [7:0]  mc_trc_cfg      ;
wire [7:0]  mc_tras_cfg     ;
wire [7:0]  mc_trp_cfg      ;
wire [7:0]  mc_trcd_cfg     ;
wire [7:0]  mc_twr_cfg      ;
wire [7:0]  mc_trtp_cfg     ;
wire [27:0] mc_rf_start_cfg ;
wire [27:0] mc_rf_period_cfg;

//axi_slave and array_ctrl
wire [AXI_FRAME_WIDTH-1:0] axi_frame_data ;
wire                       axi_frame_valid;
wire                       axi_frame_ready;
wire [AXI_DATA_WIDTH-1:0]  axi_array_rdata;
wire                       array_rvalid   ;

mc_apb_cfg U_mc_apb_cfg0(
    .apb_pclk             (apb_pclk        ),//in from pad
    .apb_prstn            (apb_prstn       ),
    .apb_psel             (apb_psel        ),
    .apb_penable          (apb_penable     ),
    .apb_pwrite           (apb_pwrite      ),
    .apb_paddr            (apb_paddr       ),
    .apb_pwdata           (apb_pwdata      ),
    .apb_prdata           (apb_prdata      ),
    .apb_pready           (apb_pready      ),
                                           
    .mc_en                (apb_mc_en       ),
    .mc_trc_cfg           (mc_trc_cfg      ),//out to array_ctrl
    .mc_tras_cfg          (mc_tras_cfg     ),
    .mc_trp_cfg           (mc_trp_cfg      ),
    .mc_trcd_cfg          (mc_trcd_cfg     ),
    .mc_twr_cfg           (mc_twr_cfg      ),
    .mc_trtp_cfg          (mc_trtp_cfg     ),
    .mc_rf_start_time_cfg (mc_rf_start_cfg ),
    .mc_rf_period_time_cfg(mc_rf_period_cfg)
);

//mc_en sync to clk
always@(posedge clk or negedge rst_n) begin
if(!rst_n) begin
    mc_en_tmp <= 1'b0;
    mc_en     <= 1'b0;
end    
else begin
    mc_en_tmp <= apb_mc_en;
    mc_en     <= mc_en_tmp;
end    
end

axi_slave U_axi_slave0(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .mc_en          (mc_en          ),
                                     
    .axi_awvalid    (axi_awvalid    ),
    .axi_awready    (axi_awready    ),
    .axi_awlen      (axi_awlen      ),
    .axi_awaddr     (axi_awaddr     ),
                                     
    .axi_wvalid     (axi_wvalid     ),
    .axi_wready     (axi_wready     ),
    .axi_wdata      (axi_wdata      ),
    .axi_wlast      (axi_wlast      ),
                                     
    .axi_arvalid    (axi_arvalid    ),
    .axi_arready    (axi_arready    ),
    .axi_arlen      (axi_arlen      ),
    .axi_araddr     (axi_araddr     ),
                                     
    .axi_rvalid     (axi_rvalid     ),
    .axi_rdata      (axi_rdata      ),
    .axi_rlast      (axi_rlast      ),
                                     
    .axi_frame_data (axi_frame_data ), //out to array_ctrl
    .axi_frame_valid(axi_frame_valid), //out to array_ctrl
    .axi_frame_ready(axi_frame_ready), //in from array_ctrl
    .array_rdata    (axi_array_rdata), //in from array_ctrl
    .array_rvalid   (array_rvalid   )  //in from array_ctrl
);

array_ctrl U_array_ctrl0(
    .clk             (clk             ), 
    .rst_n           (rst_n           ), 
    .mc_en           (mc_en           ), 
                                       
    .mc_rf_start_cfg (mc_rf_start_cfg ), 
    .mc_rf_period_cfg(mc_rf_period_cfg),
    .mc_tras_cfg     (mc_tras_cfg     ), 
    .mc_trp_cfg      (mc_trp_cfg      ), 
    .mc_trcd_cfg     (mc_trcd_cfg     ), 
    .mc_twr_cfg      (mc_twr_cfg      ), 
    .mc_trtp_cfg     (mc_trtp_cfg     ), 
                                       
    .axi_frame_data  (axi_frame_data  ), 
    .axi_frame_valid (axi_frame_valid ), 
    .axi_frame_ready (axi_frame_ready ), 
    .axi_array_rdata (axi_array_rdata ), //out to axi_slave
    .array_rvalid    (array_rvalid    ), 
                                       
    .array_banksel_n (array_banksel_n ), 
    .array_raddr     (array_raddr     ), 
    .array_cas_wr    (array_cas_wr    ), 
    .array_caddr_wr  (array_caddr_wr  ), 
    .array_cas_rd    (array_cas_rd    ), 
    .array_caddr_rd  (array_caddr_rd  ), 
    .array_wdata_rdy (array_wdata_rdy ), 
    .array_wdata     (array_wdata     ), 
    .array_rdata_rdy (array_rdata_rdy ), 
    .array_rdata     (array_rdata     ) 
);

endmodule
