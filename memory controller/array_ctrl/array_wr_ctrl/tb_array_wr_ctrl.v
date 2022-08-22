`timescale 1ns/1ns
module tb_array_wr_ctrl();

parameter AXI_ADDR_WIDTH  = 20                                 ;
parameter AXI_DATA_WIDTH  = 64                                 ;
parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3;
parameter AXI_RADDR_WIDTH = 14                                 ;
parameter AXI_CADDR_WIDTH = AXI_ADDR_WIDTH - AXI_RADDR_WIDTH   ;

//global signal
reg                            clk               ;
reg                            rst_n             ;
//mc_apb_cfg
reg      [7:0]                 mc_tras_cfg       ;
reg      [7:0]                 mc_trp_cfg        ;
reg      [7:0]                 mc_trcd_cfg       ;
reg      [7:0]                 mc_twr_cfg        ;
//fsm_ctrl 
reg      [AXI_FRAME_WIDTH-1:0] axi_frame_wr_data ;
reg                            axi_frame_wr_valid;
wire                           axi_frame_wr_ready;
wire                           wr_done           ;
//array_if_sel
wire                           array_banksel_n_wr;
wire     [AXI_RADDR_WIDTH-1:0] array_raddr_wr    ;
wire                           array_cas_wr      ;
wire     [AXI_CADDR_WIDTH-1:0] array_caddr_wr    ;
wire                           array_wdata_rdy   ;
wire     [AXI_DATA_WIDTH-1:0]  array_wdata       ;

array_wr_ctrl U_array_wr_ctrl0(
    .clk               (clk               ),
    .rst_n             (rst_n             ),
                                           
    .mc_tras_cfg       (mc_tras_cfg       ),
    .mc_trp_cfg        (mc_trp_cfg        ),
    .mc_trcd_cfg       (mc_trcd_cfg       ),
    .mc_twr_cfg        (mc_twr_cfg        ),
                                           
    .axi_frame_wr_data (axi_frame_wr_data ),
    .axi_frame_wr_valid(axi_frame_wr_valid),
    .axi_frame_wr_ready(axi_frame_wr_ready),
    .wr_done           (wr_done           ),
                                           
    .array_banksel_n_wr(array_banksel_n_wr),
    .array_raddr_wr    (array_raddr_wr    ),
    .array_cas_wr      (array_cas_wr      ),
    .array_caddr_wr    (array_caddr_wr    ),
    .array_wdata_rdy   (array_wdata_rdy   ),
    .array_wdata       (array_wdata       )
);       

initial begin
    clk = 0; rst_n = 0; mc_tras_cfg = 8'd16; mc_trp_cfg = 8'd6;
    mc_trcd_cfg = 8'd7; mc_twr_cfg = 8'd6; axi_frame_wr_data = 0;
    axi_frame_wr_valid = 0;
    #10 rst_n = 1;
end

always #5 clk = ~clk;

initial begin
    #20 array_wr_continous_valid;
    repeat(100) @(posedge clk);
    array_wr_single_data;
    repeat(100) @(posedge clk);
    array_wr_discrete_valid;
    repeat(100) @(posedge clk);
    $finish;
end

task array_wr_continous_valid;
begin
    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b1;
        axi_frame_wr_data  <= {1'b1,1'b0,1'b1,20'd100,64'd100};
    end
    #1 wait(axi_frame_wr_ready==1'b1);
    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b1;
        axi_frame_wr_data  <= {1'b0,1'b0,1'b1,20'd101,64'd101};
    end
    #1 wait(axi_frame_wr_ready==1'b1);
    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b1;
        axi_frame_wr_data  <= {1'b0,1'b0,1'b1,20'd102,64'd102};
    end
    #1 wait(axi_frame_wr_ready==1'b1);
    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b1;
        axi_frame_wr_data  <= {1'b0,1'b1,1'b1,20'd103,64'd103};
    end
    #1 wait(axi_frame_wr_ready==1'b1);
    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b0;
        axi_frame_wr_data  <= 87'd0;
    end
end
endtask

task array_wr_single_data;
begin
    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b1;
        axi_frame_wr_data  <= {1'b1,1'b1,1'b1,20'd100,64'd100};
    end
    #1 wait(axi_frame_wr_ready==1'b1);
    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b0;
        axi_frame_wr_data  <= 87'd0;
    end
end
endtask

task array_wr_discrete_valid;
begin
    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b1;
        axi_frame_wr_data  <= {1'b1,1'b0,1'b1,20'd100,64'd100};
    end
    #1 wait(axi_frame_wr_ready==1'b1);
    @(posedge clk) axi_frame_wr_valid <= 1'b0;
    repeat(4) @(posedge clk);
    
    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b1;
        axi_frame_wr_data  <= {1'b0,1'b0,1'b1,20'd101,64'd101};
    end
    #1 wait(axi_frame_wr_ready==1'b1);
    @(posedge clk) axi_frame_wr_valid <= 1'b0;
    repeat(4) @(posedge clk);

    @(posedge clk) begin
        axi_frame_wr_valid <= 1'b1;
        axi_frame_wr_data  <= {1'b0,1'b1,1'b1,20'd102,64'd102};
    end
    #1 wait(axi_frame_wr_ready==1'b1);
    @(posedge clk) axi_frame_wr_valid <= 1'b0;
    repeat(4) @(posedge clk);     
end
endtask

endmodule
