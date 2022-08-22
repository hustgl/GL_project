module mc_apb_cfg #(
    parameter APB_ADDR_WIDTH = 16,
    parameter APB_DATA_WIDTH = 32
)(
    // apb_pclk
    input                           apb_pclk             ,
    input                           apb_prstn            ,
    input                           apb_psel             ,
    input                           apb_penable          , 
    input                           apb_pwrite           ,
    input      [APB_ADDR_WIDTH-1:0] apb_paddr            ,
    input      [APB_DATA_WIDTH-1:0] apb_pwdata           ,
    output reg [APB_DATA_WIDTH-1:0] apb_prdata           ,
    output                          apb_pready           ,
    // register
    output reg                      mc_en                ,
    output reg [7:0]                mc_trc_cfg           ,    
    output reg [7:0]                mc_tras_cfg          ,
    output reg [7:0]                mc_trp_cfg           ,
    output reg [7:0]                mc_trcd_cfg          ,
    output reg [7:0]                mc_twr_cfg           ,
    output reg [7:0]                mc_trtp_cfg          ,
    output reg [27:0]               mc_rf_start_time_cfg ,
    output reg [27:0]               mc_rf_period_time_cfg
);

wire apb_wr_en;
wire apb_rd_en;

assign apb_wr_en  = apb_penable &&  apb_pwrite                 ;
assign apb_rd_en  = apb_psel    &&  ~apb_penable && ~apb_pwrite; 
assign apb_pready = 1'b1;

// write logic
always@(posedge apb_pclk or negedge apb_prstn) begin
if(!apb_prstn) begin
    mc_en                 <= 1'b0 ;
    mc_trc_cfg            <= 8'd22; //55/2.5=22
    mc_tras_cfg           <= 8'd16; //40ns/2.5ns=16
    mc_trp_cfg            <= 8'd6 ; //15/2.5=6
    mc_trcd_cfg           <= 8'd7 ; //17.5/2.5=7
    mc_twr_cfg            <= 8'd6 ; //15/2.5=6
    mc_trtp_cfg           <= 8'd4 ; //8/2.5 =4
    mc_rf_start_time_cfg  <= 28'hfffffff; 
    mc_rf_period_time_cfg <= 28'h16E3600; //24000000*2.5ns=60ms
end
else if(apb_wr_en) begin
    case(apb_paddr) 
    16'h0: mc_en <= apb_pwdata[0];
    16'h4: begin
        mc_trc_cfg  <= apb_pwdata[7:0]  ;
        mc_tras_cfg <= apb_pwdata[15:8] ;
        mc_trp_cfg  <= apb_pwdata[23:16];
        mc_trcd_cfg <= apb_pwdata[31:24];
    end
    16'h8: begin
        mc_twr_cfg  <= apb_pwdata[7:0] ;
        mc_trtp_cfg <= apb_pwdata[15:8];
    end
    16'hc:  mc_rf_start_time_cfg  <= apb_pwdata[27:0];
    16'h10: mc_rf_period_time_cfg <= apb_pwdata[27:0];
    default: begin
        mc_en                 <= 1'b0 ;
        mc_trc_cfg            <= 8'd22; 
        mc_tras_cfg           <= 8'd16; 
        mc_trp_cfg            <= 8'd6 ; 
        mc_trcd_cfg           <= 8'd7 ; 
        mc_twr_cfg            <= 8'd6 ; 
        mc_trtp_cfg           <= 8'd4 ; 
        mc_rf_start_time_cfg  <= 28'hfffffff; 
        mc_rf_period_time_cfg <= 28'h16E3600; 
    end
    endcase
end
end

always@(posedge apb_pclk or negedge apb_prstn) begin
if(!apb_prstn) begin
    apb_prdata <= {APB_DATA_WIDTH{1'b0}};
end
else if (apb_rd_en) begin
    case(apb_paddr)
    16'h0: apb_prdata <= {31'd0,mc_en};
    16'h4: apb_prdata <= {mc_trcd_cfg,mc_trp_cfg,mc_tras_cfg,mc_trc_cfg};
    16'h8: apb_prdata <= {16'd0,mc_trtp_cfg,mc_twr_cfg};
    16'hc: apb_prdata <= {8'd0,mc_rf_start_time_cfg};
    16'h10:apb_prdata <= {8'd0,mc_rf_period_time_cfg};
    default: apb_prdata <= {APB_DATA_WIDTH{1'b0}}; 
    endcase
end
end

endmodule
