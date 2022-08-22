`timescale 1ns/1ns
module tb_mc_apb_cfg();

parameter APB_ADDR_WIDTH = 16;
parameter APB_DATA_WIDTH = 32;

// apb_pclk
reg                           apb_pclk             ;
reg                           apb_prstn            ;
reg                           apb_psel             ;
reg                           apb_penable          ; 
reg                           apb_pwrite           ;
reg      [APB_ADDR_WIDTH-1:0] apb_paddr            ;
reg      [APB_DATA_WIDTH-1:0] apb_pwdata           ;
wire     [APB_DATA_WIDTH-1:0] apb_prdata           ;
wire                          apb_pready           ;
// register
wire                          mc_en                ;
wire     [7:0]                mc_trc_cfg           ;    
wire     [7:0]                mc_tras_cfg          ;
wire     [7:0]                mc_trp_cfg           ;
wire     [7:0]                mc_trcd_cfg          ;
wire     [7:0]                mc_twr_cfg           ;
wire     [7:0]                mc_trtp_cfg          ;
wire     [27:0]               mc_rf_start_time_cfg ;
wire     [27:0]               mc_rf_period_time_cfg;

mc_apb_cfg U_mc_apb_cfg0(
    .apb_pclk             (apb_pclk             ),
    .apb_prstn            (apb_prstn            ),
    .apb_psel             (apb_psel             ),
    .apb_penable          (apb_penable          ),
    .apb_pwrite           (apb_pwrite           ),
    .apb_paddr            (apb_paddr            ),
    .apb_pwdata           (apb_pwdata           ),
    .apb_prdata           (apb_prdata           ),
    .apb_pready           (apb_pready           ),
                                                 
    .mc_en                (mc_en                ),
    .mc_trc_cfg           (mc_trc_cfg           ),
    .mc_tras_cfg          (mc_tras_cfg          ),
    .mc_trp_cfg           (mc_trp_cfg           ),
    .mc_trcd_cfg          (mc_trcd_cfg          ),
    .mc_twr_cfg           (mc_twr_cfg           ),
    .mc_trtp_cfg          (mc_trtp_cfg          ),
    .mc_rf_start_time_cfg (mc_rf_start_time_cfg ),
    .mc_rf_period_time_cfg(mc_rf_period_time_cfg)
);

initial begin
    apb_pclk = 1'b0; apb_prstn = 1'b0; apb_psel = 1'b0; apb_penable = 1'b0;
    apb_pwrite = 1'b0; apb_paddr = 16'd0; apb_pwdata = 32'd0;
    #10 apb_prstn = 1'b1;
end

always #5 apb_pclk = ~apb_pclk;

initial begin
    #20 apb_reg_wr;
    repeat(2) @(posedge apb_pclk);
    apb_reg_rd;
    #20;
    $finish;
end

task apb_reg_wr;
begin
    @(posedge apb_pclk) begin
        apb_psel   <= 1'b1 ;
        apb_paddr  <= 16'h0;
        apb_pwrite <= 1'b1 ;
        apb_pwdata <= 32'h1;
    end
    @(posedge apb_pclk) 
        apb_penable <= 1'b1;
    @(posedge apb_pclk) begin
        apb_penable <= 1'b0 ;
        apb_paddr   <= 16'h4;
        apb_pwdata  <= {8'd15,8'd6,8'd3,8'd4};
    end
    @(posedge apb_pclk) begin
        apb_penable <= 1'b1;
    end
    @(posedge apb_pclk) begin
        apb_penable <= 1'b0;
        apb_paddr   <= 16'h8;
        apb_pwdata  <= {8'd0,8'd0,8'd11,8'd14};
    end
    @(posedge apb_pclk) begin
        apb_penable <= 1'b1;
    end
    @(posedge apb_pclk) begin
        apb_penable <= 1'b0;
        apb_paddr   <= 16'hc;
        apb_pwdata  <= {8'd0,28'd1001};        
    end
    @(posedge apb_pclk) begin
        apb_penable <= 1'b1;
    end
    @(posedge apb_pclk) begin
        apb_penable <= 1'b0;
        apb_paddr   <= 16'h10;
        apb_pwdata  <= {8'd0,28'd1300};
    end
    @(posedge apb_pclk) begin
        apb_penable <= 1'b1;
    end 
    @(posedge apb_pclk) begin
        apb_psel    <= 1'b0 ;
        apb_penable <= 1'b0 ;
        apb_paddr   <= 16'd0;
        apb_pwdata  <= 32'd0;
    end
end
endtask

task apb_reg_rd;
begin
    @(posedge apb_pclk) begin
        apb_psel   <= 1'b1;
        apb_pwrite <= 1'b0;
        apb_paddr  <= 16'h4;
    end
    @(posedge apb_pclk)
        apb_penable <= 1'b1;
    @(posedge apb_pclk) begin
        apb_penable <= 1'b0;
        apb_paddr   <= 16'h8;
    end
    @(posedge apb_pclk) begin
        apb_penable <= 1'b1;
    end
    @(posedge apb_pclk) begin
        apb_psel    <= 1'b0;
        apb_penable <= 1'b0;
        apb_paddr   <= 16'd0;
    end
end 
endtask

initial begin
    $fsdbDumpfile("wave_mc_apb_cfg.fsdb");
    $fsdbDumpvars;
end

endmodule
