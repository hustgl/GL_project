module phy_tx(
    input        clk     ,   //48M
    input        rst_n   ,

    input        tx_sop  ,
    input        tx_eop  ,
    input        tx_valid,
    output       tx_ready,
    input  [7:0] tx_data ,

    output       t_d0    ,
    output       t_d1    
);

//phy_tx_p2s output port and phy_tx_nrzi input port
wire tx_dat      ;
wire tx_dat_en   ;
wire tx_nrzi_stop;
wire tx_nrzi_en  ;
wire tx_se_en    ;

//phy_tx_nrzi output port and phy_tx_s2d input port
wire tx_nrzi_dat   ;
wire tx_nrzi_dat_en;
wire tx_nrzi_se_en ;

phy_tx_p2s U_phy_tx_p2s0(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
                               
    .tx_sop      (tx_sop      ),
    .tx_eop      (tx_eop      ),
    .tx_valid    (tx_valid    ),
    .tx_ready    (tx_ready    ),
    .tx_data     (tx_data     ),
                               
    .tx_dat      (tx_dat      ),
    .tx_dat_en   (tx_dat_en   ),
    .tx_nrzi_stop(tx_nrzi_stop),
    .tx_nrzi_en  (tx_nrzi_en  ),
    .tx_se_en    (tx_se_en    )
);

phy_tx_nrzi U_phy_tx_nrzi0(
    .clk           (clk           ),
    .rst_n         (rst_n         ),
                                   
    .tx_dat        (tx_dat        ),
    .tx_dat_en     (tx_dat_en     ),
    .tx_nrzi_stop  (tx_nrzi_stop  ),
    .tx_nrzi_en    (tx_nrzi_en    ),
    .tx_se_en      (tx_se_en      ),
                                   
    .tx_nrzi_dat   (tx_nrzi_dat   ),
    .tx_nrzi_dat_en(tx_nrzi_dat_en),
    .tx_nrzi_se_en (tx_nrzi_se_en )
);

phy_tx_s2d U_phy_tx_s2d(
    .clk           (clk           ),
    .rst_n         (rst_n         ),
                                   
    .tx_nrzi_dat   (tx_nrzi_dat   ),
    .tx_nrzi_dat_en(tx_nrzi_dat_en),
    .tx_nrzi_se_en (tx_nrzi_se_en ),
                                   
    .t_d0          (t_d0          ),
    .t_d1          (t_d1          )
);


endmodule
