`timescale 1ns/1ns
module tb_fsm_ctrl();

parameter AXI_ADDR_WIDTH  = 20;
parameter AXI_DATA_WIDTH  = 64;
parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3;

reg                        clk               ;
reg                        rst_n             ;
reg                        mc_en             ;

reg  [27:0]                mc_rf_start_cfg   ;
reg  [27:0]                mc_rf_period_cfg  ;

reg  [AXI_FRAME_WIDTH-1:0] axi_frame_data    ;
reg                        axi_frame_valid   ;
wire                       axi_frame_ready   ;
wire [AXI_DATA_WIDTH-1:0]  array_rdata       ;
wire                       array_rvalid      ;

wire [AXI_FRAME_WIDTH-1:0] axi_frame_wr_data ;
wire                       axi_frame_wr_valid;
reg                        axi_frame_wr_ready;
reg                        wr_done           ;

wire [AXI_FRAME_WIDTH-1:0] axi_frame_rd_data ;
wire                       axi_frame_rd_valid;
reg                        axi_frame_rd_ready;
reg                        rd_done           ;
reg  [AXI_DATA_WIDTH-1:0]  array_rd_rdata    ;  
reg                        array_rd_rvalid   ;

wire                       rf_start          ;
reg                        rf_done           ;

wire [1:0]                 fsm_cs            ;

initial begin
    clk = 0; rst_n = 0; mc_en = 0; 
    mc_rf_start_cfg = 28'd100; mc_rf_period_cfg = 28'd2400;
    axi_frame_data = 0; axi_frame_valid = 0; axi_frame_wr_ready = 0; wr_done = 0;
    axi_frame_rd_ready = 0; rd_done = 0; array_rd_rdata = 0; array_rd_rvalid = 0;
    rf_done = 0;
    #10 rst_n = 1; mc_en = 1;
end

always #5 clk = ~clk;

fsm_ctrl U_fsm_ctrl0(
    .clk               (clk               ),
    .rst_n             (rst_n             ),
    .mc_en             (mc_en             ),
                                           
    .mc_rf_start_cfg   (mc_rf_start_cfg   ),
    .mc_rf_period_cfg  (mc_rf_period_cfg  ),
                                           
    .axi_frame_data    (axi_frame_data    ),
    .axi_frame_valid   (axi_frame_valid   ),
    .axi_frame_ready   (axi_frame_ready   ),
    .array_rdata       (array_rdata       ),
    .array_rvalid      (array_rvalid      ),
                                           
    .axi_frame_wr_data (axi_frame_wr_data ),
    .axi_frame_wr_valid(axi_frame_wr_valid),
    .axi_frame_wr_ready(axi_frame_wr_ready),
    .wr_done           (wr_done           ),
                                           
    .axi_frame_rd_data (axi_frame_rd_data ),
    .axi_frame_rd_valid(axi_frame_rd_valid),
    .axi_frame_rd_ready(axi_frame_rd_ready),
    .rd_done           (rd_done           ),
    .array_rd_rdata    (array_rd_rdata    ),
    .array_rd_rvalid   (array_rd_rvalid   ),
                                           
    .rf_start          (rf_start          ),
    .rf_done           (rf_done           ),
                                           
    .fsm_cs            (fsm_cs            )
);

task send_frame_wr;
begin
    fork
        begin
            @(posedge clk) begin
                axi_frame_valid <= 1'b1;
                axi_frame_data  <= {1'b1,1'b0,1'b1,20'd100,64'd100};
            end
            #1 wait(axi_frame_ready==1'b1);
            @(posedge clk) begin
                axi_frame_valid <= 1'b1;
                axi_frame_data  <= {1'b0,1'b0,1'b1,20'd101,64'd101};
            end
            #1 wait(axi_frame_ready==1'b1);
            @(posedge clk) begin
                axi_frame_valid <= 1'b1;
                axi_frame_data  <= {1'b0,1'b1,1'b1,20'd102,64'd102};
            end
            #1 wait(axi_frame_ready==1'b1);  
            @(posedge clk) begin
                axi_frame_valid <= 1'b0;
                axi_frame_data  <= 87'd0;
            end
            repeat(20) @(posedge clk);
            @(posedge clk) begin
                wr_done <= 1'b1;
            end
            @(posedge clk) begin
                wr_done <= 1'b0;
            end
        end 
        begin
            @(posedge clk) axi_frame_wr_ready <= 1'b0;
            repeat(3) @(posedge clk);
            @(posedge clk) axi_frame_wr_ready <= 1'b1;
        end
        begin
            wait(rf_start==1'b1);
            repeat(100) @(posedge clk);
            @(posedge clk) rf_done <= 1'b1;
            @(posedge clk) rf_done <= 1'b0;
        end
    join
end
endtask

initial begin
    #20 send_frame_wr;
    repeat(3000) @(posedge clk);
    $finish;
end

endmodule
