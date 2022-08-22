`timescale 1ns/1ns
module tb_array_rf_ctrl();

parameter AXI_RADDR_WIDTH = 14;

//global signal
reg                            clk               ;
reg                            rst_n             ;
//mc_apb_cfg
reg      [7:0]                 mc_tras_cfg       ;
reg      [7:0]                 mc_trp_cfg        ;
//fsm_ctrl
reg                            rf_start          ;
wire                           rf_done           ;
//array_if_sel
wire                           array_banksel_n_rf;
wire     [AXI_RADDR_WIDTH-1:0] array_raddr_rf    ;

initial begin
    clk = 1'b0; rst_n = 1'b0; mc_tras_cfg = 8'd16;
    mc_trp_cfg = 8'd6; rf_start = 1'b0;
    #10 rst_n = 1;
end

always #5 clk = ~clk;

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

task array_refresh;
begin
    @(posedge clk) rf_start <= 1'b1;
    @(posedge clk) rf_start <= 1'b0;
end 
endtask

initial begin
    #20 array_refresh;
    #2000 $finish;
end

initial begin
    $fsdbDumpfile("wave_array_rf_ctrl.fsdb");
    $fsdbDumpvars;
end

endmodule
