module array_ctrl #(
    parameter AXI_ADDR_WIDTH  = 20                                 ,
    parameter AXI_DATA_WIDTH  = 64                                 ,
    parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3,
    parameter AXI_RADDR_WIDTH = 14                                 ,
    parameter AXI_CADDR_WIDTH = AXI_ADDR_WIDTH - AXI_RADDR_WIDTH    
)(
    //global signal
    input                            clk             ,
    input                            rst_n           ,
    input                            mc_en           ,
    //mc_apb_cfg
    input      [27:0]                mc_rf_start_cfg ,
    input      [27:0]                mc_rf_period_cfg,
    input      [7:0]                 mc_tras_cfg     ,
    input      [7:0]                 mc_trp_cfg      ,
    input      [7:0]                 mc_trcd_cfg     ,
    input      [7:0]                 mc_twr_cfg      ,
    input      [7:0]                 mc_trtp_cfg     ,    
    //axi_slave
    input      [AXI_FRAME_WIDTH-1:0] axi_frame_data  ,
    input                            axi_frame_valid ,
    output                           axi_frame_ready ,
    output     [AXI_DATA_WIDTH-1:0]  axi_array_rdata ,
    output                           array_rvalid    ,
    //array 
    output                           array_banksel_n ,
    output     [AXI_RADDR_WIDTH-1:0] array_raddr     ,
    output                           array_cas_wr    ,
    output     [AXI_CADDR_WIDTH-1:0] array_caddr_wr  ,
    output                           array_cas_rd    ,
    output     [AXI_CADDR_WIDTH-1:0] array_caddr_rd  ,
    output                           array_wdata_rdy ,
    output     [AXI_DATA_WIDTH-1 :0] array_wdata     ,
    input                            array_rdata_rdy ,
    input      [AXI_DATA_WIDTH-1 :0] array_rdata           
);

//fsm_ctrl and array_wr_ctrl signal
wire [AXI_FRAME_WIDTH-1:0] axi_frame_wr_data ;
wire                       axi_frame_wr_valid;
wire                       axi_frame_wr_ready;
wire                       wr_done           ;

//fsm_ctrl and array_rd_ctrl signal
wire [AXI_FRAME_WIDTH-1:0] axi_frame_rd_data ;
wire                       axi_frame_rd_valid;
wire                       axi_frame_rd_ready;
wire                       rd_done           ;
wire [AXI_DATA_WIDTH-1:0]  array_rd_rdata    ;
wire                       array_rd_rvalid   ;

//fsm_ctrl and array_rf_ctrl signal
wire                       rf_start          ;
wire                       rf_done           ;

//fsm_ctrl and array_if_sel
wire [1:0]                 fsm_cs            ;

//array_wr_ctrl and array_if_sel
wire                       array_banksel_n_wr    ;
wire [AXI_RADDR_WIDTH-1:0] array_raddr_wr        ;
wire                       bypass_array_cas_wr   ;
wire [AXI_CADDR_WIDTH-1:0] bypass_array_caddr_wr ;
wire                       bypass_array_wdata_rdy;
wire [AXI_DATA_WIDTH-1:0]  bypass_array_wdata    ;

//array_rd_ctrl and array_if_sel
wire                       array_banksel_n_rd    ;
wire [AXI_CADDR_WIDTH-1:0] array_raddr_rd        ;
wire                       bypass_array_cas_rd   ;
wire [AXI_CADDR_WIDTH-1:0] bypass_array_caddr_rd ;
wire                       bypass_array_rdata_rdy;
wire [AXI_DATA_WIDTH-1:0]  bypass_array_rdata    ;

//array_rf_ctrl and array_if_sel
wire                       array_banksel_n_rf    ;
wire [AXI_RADDR_WIDTH-1:0] array_raddr_rf        ;

fsm_ctrl U_fsm_ctrl0(
    .clk               (clk               ),
    .rst_n             (rst_n             ),
    .mc_en             (mc_en             ),
                                           
    .mc_rf_start_cfg   (mc_rf_start_cfg   ),
    .mc_rf_period_cfg  (mc_rf_period_cfg  ),
    //axi_slave                                           
    .axi_frame_data    (axi_frame_data    ),
    .axi_frame_valid   (axi_frame_valid   ),
    .axi_frame_ready   (axi_frame_ready   ),
    .array_rdata       (axi_array_rdata   ), //out to axi_slave
    .array_rvalid      (array_rvalid      ),
    //array_wr_ctrl                                       
    .axi_frame_wr_data (axi_frame_wr_data ), //out
    .axi_frame_wr_valid(axi_frame_wr_valid),
    .axi_frame_wr_ready(axi_frame_wr_ready),
    .wr_done           (wr_done           ),
    //array_rd_ctrl                                       
    .axi_frame_rd_data (axi_frame_rd_data ), //out
    .axi_frame_rd_valid(axi_frame_rd_valid), //out
    .axi_frame_rd_ready(axi_frame_rd_ready), 
    .rd_done           (rd_done           ), //in
    .array_rd_rdata    (array_rd_rdata    ), //in 
    .array_rd_rvalid   (array_rd_rvalid   ), //in
    //array_rf_ctrl                                           
    .rf_start          (rf_start          ), //out
    .rf_done           (rf_done           ), //in
    //array_if_sel                                       
    .fsm_cs            (fsm_cs            )  //out
);

array_wr_ctrl U_array_wr_ctrl0(
    .clk               (clk                   ),
    .rst_n             (rst_n                 ),
                                               
    .mc_tras_cfg       (mc_tras_cfg           ),
    .mc_trp_cfg        (mc_trp_cfg            ),
    .mc_trcd_cfg       (mc_trcd_cfg           ),
    .mc_twr_cfg        (mc_twr_cfg            ),
                                               
    .axi_frame_wr_data (axi_frame_wr_data     ), //in
    .axi_frame_wr_valid(axi_frame_wr_valid    ),
    .axi_frame_wr_ready(axi_frame_wr_ready    ),
    .wr_done           (wr_done               ), //out
                                               
    .array_banksel_n_wr(array_banksel_n_wr    ), //out
    .array_raddr_wr    (array_raddr_wr        ), //out
    .array_cas_wr      (bypass_array_cas_wr   ), //out
    .array_caddr_wr    (bypass_array_caddr_wr ), //out
    .array_wdata_rdy   (bypass_array_wdata_rdy),
    .array_wdata       (bypass_array_wdata    )
);

array_rd_ctrl U_array_rd_ctrl0(
    .clk               (clk                   ),
    .rst_n             (rst_n                 ),
                                               
    .mc_tras_cfg       (mc_tras_cfg           ),
    .mc_trp_cfg        (mc_trp_cfg            ),
    .mc_trcd_cfg       (mc_trcd_cfg           ),
    .mc_trtp_cfg       (mc_trtp_cfg           ),
                                               
    .axi_frame_rd_data (axi_frame_rd_data     ), //in
    .axi_frame_rd_valid(axi_frame_rd_valid    ),
    .axi_frame_rd_ready(axi_frame_rd_ready    ),
    .rd_done           (rd_done               ), //out to fsm_ctrl
    .array_rd_rdata    (array_rd_rdata        ), //out to fsm_ctrl
    .array_rd_rvalid   (array_rd_rvalid       ),
                                           
    .array_banksel_n_rd(array_banksel_n_rd    ), //out to array_if_sel
    .array_raddr_rd    (array_raddr_rd        ),
    .array_cas_rd      (bypass_array_cas_rd   ), //out to array_if_sel
    .array_caddr_rd    (bypass_array_caddr_rd ),
    .array_rdata_rdy   (bypass_array_rdata_rdy), //in from array_if_sel
    .array_rdata       (bypass_array_rdata    )  //in from array_if_sel
);

array_rf_ctrl U_array_rf_ctrl0(
    .clk               (clk               ),
    .rst_n             (rst_n             ),
                                           
    .mc_tras_cfg       (mc_tras_cfg       ),
    .mc_trp_cfg        (mc_trp_cfg        ),
                                           
    .rf_start          (rf_start          ),
    .rf_done           (rf_done           ),
                                           
    .array_banksel_n_rf(array_banksel_n_rf),
    .array_raddr_rf    (array_raddr_rf    )
);

array_if_sel U_array_if_sel0(
    .clk                   (clk                   ),
    .rst_n                 (rst_n                 ),
                                                   
    .fsm_cs                (fsm_cs                ),
                                                   
    .array_banksel_n       (array_banksel_n       ),
    .array_raddr           (array_raddr           ),
    .array_cas_wr          (array_cas_wr          ),
    .array_caddr_wr        (array_caddr_wr        ),
    .array_cas_rd          (array_cas_rd          ),
    .array_caddr_rd        (array_caddr_rd        ),
    .array_wdata_rdy       (array_wdata_rdy       ),
    .array_wdata           (array_wdata           ), //out to array
    .array_rdata_rdy       (array_rdata_rdy       ), //in from array
    .array_rdata           (array_rdata           ), //in from array
                                                   
    .array_banksel_n_wr    (array_banksel_n_wr    ), //in from array_wr_ctrl
    .array_raddr_wr        (array_raddr_wr        ), //in
    .bypass_array_cas_wr   (bypass_array_cas_wr   ),
    .bypass_array_caddr_wr (bypass_array_caddr_wr ),
    .bypass_array_wdata_rdy(bypass_array_wdata_rdy),
    .bypass_array_wdata    (bypass_array_wdata    ),
                                                   
    .array_banksel_n_rd    (array_banksel_n_rd    ), 
    .array_raddr_rd        (array_raddr_rd        ),
    .bypass_array_cas_rd   (bypass_array_cas_rd   ),
    .bypass_array_caddr_rd (bypass_array_caddr_rd ),
    .bypass_array_rdata_rdy(bypass_array_rdata_rdy), //out to array_rd_ctrl
    .bypass_array_rdata    (bypass_array_rdata    ),
                                                   
    .array_banksel_n_rf    (array_banksel_n_rf    ),
    .array_raddr_rf        (array_raddr_rf        )
);

endmodule
