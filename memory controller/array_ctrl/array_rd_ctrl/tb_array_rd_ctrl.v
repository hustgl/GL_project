`timescale 1ns/1ps
module tb_array_rd_ctrl();

parameter AXI_ADDR_WIDTH  = 20                                 ;
parameter AXI_DATA_WIDTH  = 64                                 ;
parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3;
parameter AXI_RADDR_WIDTH = 14                                 ;
parameter AXI_CADDR_WIDTH = AXI_ADDR_WIDTH - AXI_RADDR_WIDTH   ;

// global signal
reg                            clk               ;
reg                            rst_n             ;
//mc_apb_cfg
reg      [7:0]                 mc_tras_cfg       ;
reg      [7:0]                 mc_trp_cfg        ;
reg      [7:0]                 mc_trcd_cfg       ;
reg      [7:0]                 mc_trtp_cfg       ;
//fsm_ctrl
reg      [AXI_FRAME_WIDTH-1:0] axi_frame_rd_data ;
reg                            axi_frame_rd_valid;
wire                           axi_frame_rd_ready;
wire                           rd_done           ;
wire     [AXI_DATA_WIDTH-1:0]  array_rd_rdata    ;
wire                           array_rd_rvalid   ;
//array_if_sel
wire                           array_banksel_n_rd;
wire     [AXI_RADDR_WIDTH-1:0] array_raddr_rd    ;
wire                           array_cas_rd      ;
wire     [AXI_CADDR_WIDTH-1:0] array_caddr_rd    ;
reg                            array_rdata_rdy   ;
reg      [AXI_DATA_WIDTH-1:0]  array_rdata       ;

array_rd_ctrl U_array_rd_ctrl0(
    .clk               (clk               ),
    .rst_n             (rst_n             ),
                                          
    .mc_tras_cfg       (mc_tras_cfg       ),
    .mc_trp_cfg        (mc_trp_cfg        ),
    .mc_trcd_cfg       (mc_trcd_cfg       ),
    .mc_trtp_cfg       (mc_trtp_cfg       ),
                                          
    .axi_frame_rd_data (axi_frame_rd_data ),
    .axi_frame_rd_valid(axi_frame_rd_valid),
    .axi_frame_rd_ready(axi_frame_rd_ready),
    .rd_done           (rd_done           ),
    .array_rd_rdata    (array_rd_rdata    ),
    .array_rd_rvalid   (array_rd_rvalid   ),
                                          
    .array_banksel_n_rd(array_banksel_n_rd),
    .array_raddr_rd    (array_raddr_rd    ),
    .array_cas_rd      (array_cas_rd      ),
    .array_caddr_rd    (array_caddr_rd    ),
    .array_rdata_rdy   (array_rdata_rdy   ),
    .array_rdata       (array_rdata       )
);

initial begin
    clk = 0; rst_n = 0; mc_tras_cfg = 8'd16; mc_trp_cfg = 8'd6;
    mc_trcd_cfg = 8'd7; mc_trtp_cfg = 8'd4; axi_frame_rd_data = 0;
    axi_frame_rd_valid = 0; array_rdata_rdy = 1; array_rdata = 0;
    #10 rst_n = 1;
end

always #1.25 clk = ~clk;

initial begin
    #20 array_rd_continous_valid;
    repeat(100) @(posedge clk);
//    array_rd_single_data;
//    repeat(100) @(posedge clk);
    $finish;
end

task array_rd_continous_valid;
fork
    begin
        @(posedge clk) begin
            axi_frame_rd_valid <= 1'b1;
            axi_frame_rd_data  <= {1'b1,1'b0,1'b0,20'd100,64'd0};
        end
        #1 wait(axi_frame_rd_ready==1'b1);
        @(posedge clk) begin
            axi_frame_rd_valid <= 1'b1;
            axi_frame_rd_data  <= {1'b0,1'b0,1'b0,20'd101,64'd0};
        end
        #1 wait(axi_frame_rd_ready==1'b1);
        @(posedge clk) begin
            axi_frame_rd_valid <= 1'b1;
            axi_frame_rd_data  <= {1'b0,1'b0,1'b0,20'd102,64'd0};
        end
        #1 wait(axi_frame_rd_ready==1'b1);
        @(posedge clk) begin
            axi_frame_rd_valid <= 1'b1;
            axi_frame_rd_data  <= {1'b0,1'b1,1'b0,20'd103,64'd0};
        end
        #1 wait(axi_frame_rd_ready==1'b1);
        @(posedge clk) begin
            axi_frame_rd_valid <= 1'b0;
            axi_frame_rd_data  <= 87'd0;
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
    $fsdbDumpfile("wave_array_rd_ctrl.fsdb");
    $fsdbDumpvars;
    $fsdbDumpMDA();
end


endmodule
