`timescale 1ns/1ps
module tb_array_ctrl();

parameter AXI_ADDR_WIDTH  = 20                                 ;
parameter AXI_DATA_WIDTH  = 64                                 ;
parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3;
parameter AXI_RADDR_WIDTH = 14                                 ;
parameter AXI_CADDR_WIDTH = AXI_ADDR_WIDTH - AXI_RADDR_WIDTH   ; 

//global signal
reg                            clk             ;
reg                            rst_n           ;
reg                            mc_en           ;
//mc_apb_cfg
reg      [27:0]                mc_rf_start_cfg ;
reg      [27:0]                mc_rf_period_cfg;
reg      [7:0]                 mc_tras_cfg     ;
reg      [7:0]                 mc_trp_cfg      ;
reg      [7:0]                 mc_trcd_cfg     ;
reg      [7:0]                 mc_twr_cfg      ;
reg      [7:0]                 mc_trtp_cfg     ;
//axi_slave
reg      [AXI_FRAME_WIDTH-1:0] axi_frame_data  ;
reg                            axi_frame_valid ;
wire                           axi_frame_ready ;
wire     [AXI_DATA_WIDTH-1:0]  axi_array_rdata ;
wire                           array_rvalid    ;
//array 
wire                           array_banksel_n ;
wire     [AXI_RADDR_WIDTH-1:0] array_raddr     ;
wire                           array_cas_wr    ;
wire     [AXI_CADDR_WIDTH-1:0] array_caddr_wr  ;
wire                           array_cas_rd    ;
wire     [AXI_CADDR_WIDTH-1:0] array_caddr_rd  ;
wire                           array_wdata_rdy ;
wire     [AXI_DATA_WIDTH-1 :0] array_wdata     ;
reg                            array_rdata_rdy ;
reg      [AXI_DATA_WIDTH-1 :0] array_rdata     ;

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
    .axi_array_rdata (axi_array_rdata ),
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

initial begin
    clk = 1'b0; rst_n = 1'b0; mc_en = 1'b0;
    mc_tras_cfg = 8'd16; mc_trp_cfg = 8'd6;
    mc_trcd_cfg = 8'd7; mc_twr_cfg = 8'd6;
    mc_trtp_cfg = 8'd4; mc_rf_start_cfg = 28'd10; mc_rf_period_cfg = 28'd2400;
    axi_frame_data = 87'd0; axi_frame_valid = 1'b0; array_rdata_rdy = 1'b1; array_rdata = 64'd0;
    #5 rst_n = 1'b1; mc_en = 1'b1;
end

always #1.25 clk = ~clk;

task axi_frame_wr_continous_valid;
begin
    @(posedge clk) begin
        axi_frame_valid <= 1'b1;
        axi_frame_data  <= {1'b1,1'b0,1'b1,20'd100,64'd100};
    end  
    #0.1 wait(axi_frame_ready==1'b1);
    @(posedge clk) begin
        axi_frame_valid <= 1'b1;
        axi_frame_data  <= {1'b0,1'b0,1'b1,20'd101,64'd101};
    end
    #0.1 wait(axi_frame_ready==1'b1);
    @(posedge clk) begin
        axi_frame_valid <= 1'b1;
        axi_frame_data  <= {1'b0,1'b0,1'b1,20'd102,64'd102};
    end
    #0.1 wait(axi_frame_ready==1'b1);
    @(posedge clk) begin
        axi_frame_valid <= 1'b1;
        axi_frame_data  <= {1'b0,1'b1,1'b1,20'd103,64'd103};
    end
    #0.1 wait(axi_frame_ready==1'b1);
    @(posedge clk) begin
        axi_frame_valid <= 1'b0;
        axi_frame_data  <= 87'd0;
    end    
end
endtask

task axi_frame_rd;
fork
    begin
        @(posedge clk) begin
            axi_frame_valid <= 1'b1;
            axi_frame_data  <= {1'b1,1'b0,1'b0,20'd335,64'd0};
        end
        #0.1 wait(axi_frame_ready==1'b1);
        @(posedge clk) begin
            axi_frame_valid <= 1'b1;
            axi_frame_data  <= {1'b0,1'b0,1'b0,20'd336,64'd0};
        end
        #0.1 wait(axi_frame_ready==1'b1);
        @(posedge clk) begin
            axi_frame_valid <= 1'b1;
            axi_frame_data  <= {1'b0,1'b0,1'b0,20'd337,64'd0};
        end
        #0.1 wait(axi_frame_ready==1'b1);
        @(posedge clk) begin
            axi_frame_valid <= 1'b1;
            axi_frame_data  <= {1'b0,1'b1,1'b0,20'd338,64'd0};
        end
        #0.1 wait(axi_frame_ready==1'b1);
        @(posedge clk) begin
            axi_frame_valid <= 1'b0;
            axi_frame_data  <= 87'd0;
        end
    end
    begin
        wait(array_cas_rd==1'b1);
        wait(array_cas_rd==1'b0);
        #1.5 begin
            array_rdata_rdy <= 1'b0   ;
            array_rdata     <= 64'd100;
        end
        #2.5 array_rdata_rdy = 1'b1;
        #2.5 begin
            array_rdata_rdy <= 1'b0   ;
            array_rdata     <= 64'd101;    
        end
        #2.5 array_rdata_rdy = 1'b1;
        #2.5 begin
            array_rdata_rdy <= 1'b0   ;
            array_rdata     <= 64'd102;
        end
        #2.5 array_rdata_rdy = 1'b1;
        #2.5 begin
            array_rdata_rdy <= 1'b0;
            array_rdata     <= 64'd103;
        end 
        #2.5 array_rdata_rdy = 1'b1;
    end
join
endtask

initial begin
fork
    begin
        #10 axi_frame_wr_continous_valid;
        #10 axi_frame_rd;
    end
    begin
        repeat(5000) @(posedge clk);
        $finish;
    end
join
end

initial begin
    $fsdbDumpfile("wave_array_ctrl.fsdb");
    $fsdbDumpvars;
//    $fsdbDumpMDA(0,array_ctrl);    
end

endmodule
