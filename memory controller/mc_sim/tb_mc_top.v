`timescale 1ns/1ps
module tb_mc_top();

parameter APB_ADDR_WIDTH  = 16                                 ;
parameter APB_DATA_WIDTH  = 32                                 ;
parameter AXI_ADDR_WIDTH  = 20                                 ;
parameter AXI_DATA_WIDTH  = 64                                 ;
parameter AXI_LEN_WIDTH   = 6                                  ;
parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3;    
parameter AXI_RADDR_WIDTH = 14                                 ;
parameter AXI_CADDR_WIDTH = AXI_ADDR_WIDTH - AXI_RADDR_WIDTH   ;

//global signal                                 
reg                            clk            ;
reg                            rst_n          ;
// apb_pclk
reg                            apb_pclk       ;
reg                            apb_prstn      ;
reg                            apb_psel       ;
reg                            apb_penable    ;
reg                            apb_pwrite     ;
reg      [APB_ADDR_WIDTH-1:0]  apb_paddr      ;
reg      [APB_DATA_WIDTH-1:0]  apb_pwdata     ;
wire     [APB_DATA_WIDTH-1:0]  apb_prdata     ;
wire                           apb_pready     ;
//axi aw channel
reg                            axi_awvalid    ;
wire                           axi_awready    ;
reg      [AXI_LEN_WIDTH-1:0]   axi_awlen      ;
reg      [AXI_ADDR_WIDTH-1:0]  axi_awaddr     ;
//axi w channel
reg                            axi_wvalid     ;
wire                           axi_wready     ;
reg      [AXI_DATA_WIDTH-1:0]  axi_wdata      ;
reg                            axi_wlast      ;
//axi ar channel                       
reg                            axi_arvalid    ;
wire                           axi_arready    ;
reg      [AXI_LEN_WIDTH-1:0]   axi_arlen      ;
reg      [AXI_ADDR_WIDTH-1:0]  axi_araddr     ;
//axi r channel
wire                           axi_rvalid     ;
wire     [AXI_DATA_WIDTH-1:0]  axi_rdata      ;
wire                           axi_rlast      ;
//array 
wire                           array_banksel_n;
wire     [AXI_RADDR_WIDTH-1:0] array_raddr    ;
wire                           array_cas_wr   ;
wire     [AXI_CADDR_WIDTH-1:0] array_caddr_wr ;
wire                           array_cas_rd   ;
wire     [AXI_CADDR_WIDTH-1:0] array_caddr_rd ;
wire                           array_wdata_rdy;
wire     [AXI_DATA_WIDTH-1 :0] array_wdata    ;
reg                            array_rdata_rdy;
reg      [AXI_DATA_WIDTH-1 :0] array_rdata    ;

mc_top U_mc_top0(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
                                     
    .apb_pclk       (apb_pclk       ),
    .apb_prstn      (apb_prstn      ),
    .apb_psel       (apb_psel       ),
    .apb_penable    (apb_penable    ),
    .apb_pwrite     (apb_pwrite     ),
    .apb_paddr      (apb_paddr      ),
    .apb_pwdata     (apb_pwdata     ),
    .apb_prdata     (apb_prdata     ),
    .apb_pready     (apb_pready     ),
                                     
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
                                     
    .array_banksel_n(array_banksel_n),
    .array_raddr    (array_raddr    ),
    .array_cas_wr   (array_cas_wr   ),
    .array_caddr_wr (array_caddr_wr ),
    .array_cas_rd   (array_cas_rd   ),
    .array_caddr_rd (array_caddr_rd ),
    .array_wdata_rdy(array_wdata_rdy),
    .array_wdata    (array_wdata    ),
    .array_rdata_rdy(array_rdata_rdy),
    .array_rdata    (array_rdata    )
);

integer I;

initial begin
    clk = 1'b0; rst_n = 1'b0; apb_pclk = 1'b0; apb_prstn = 1'b0;
    apb_psel = 1'b0; apb_penable = 1'b0; apb_pwrite = 1'b0;
    apb_paddr = 0; apb_pwdata = 0; 
    axi_awvalid = 0; axi_awlen = 0; axi_awaddr = 0;
    axi_wvalid = 0; axi_wdata = 0; axi_wlast = 0;
    axi_arvalid = 0; axi_arlen = 0; axi_araddr = 0; 
    array_rdata_rdy = 1; array_rdata = 0;
    #10 rst_n = 1'b1; apb_prstn = 1'b1;
end

always #1.25 clk = ~clk;
always #5 apb_pclk = ~apb_pclk;

task mc_apb_cfg;
begin
    @(posedge apb_pclk) begin
        apb_psel <= 1'b1;
        apb_paddr <= 16'hc;
        apb_pwrite <= 1'b1;
        apb_pwdata <= {8'd0, 28'd100};
    end
    @(posedge apb_pclk) 
        apb_penable <= 1'b1;
    @(posedge apb_pclk) begin
        apb_penable <= 1'b0;
        apb_paddr <= 16'h10;
        apb_pwdata <= {8'd0, 28'd2400};
    end
    @(posedge apb_pclk)
        apb_penable <= 1'b1;
    @(posedge apb_pclk) begin
        apb_penable <= 1'b0;
        apb_paddr <= 16'h0;
        apb_pwdata <= 32'h1;
    end
    @(posedge apb_pclk)
        apb_penable <= 1'b1;
    @(posedge apb_pclk) begin
        apb_psel <= 1'b0;
        apb_penable <= 1'b0;
        apb_pwrite <= 1'b0;
        apb_pwdata <= 32'h0;
    end
end
endtask

task axi_array_wr_notcrossrow;
begin
    fork 
        begin
            @(posedge clk) begin
                axi_awvalid <= 1'b1;
                axi_awlen   <= 6'd4;
                axi_awaddr  <= {14'd100,6'd50};
            end
            #0.1 wait(axi_awready==1'b1);
            @(posedge clk) 
                axi_awvalid <= 1'b0;
        end
        begin
            //awlen=4 means 5 datas
            for(I=0; I<4; I=I+1) begin
                @(posedge clk) begin
                    axi_wvalid <= 1'b1;
                    axi_wdata  <= I+10;
                end
                #0.1 wait(axi_wready==1'b1);
            end
            @(posedge clk) begin
                axi_wvalid <= 1'b1;
                axi_wdata  <= 64'd57;
                axi_wlast  <= 1'b1;
                #0.1 wait(axi_wready==1'b1);
            end
            @(posedge clk) begin
                axi_wvalid <= 1'b0 ;
                axi_wdata  <= 64'd0;
                axi_wlast  <= 1'b0 ;
            end    
        end
    join        
end
endtask

task axi_array_rd_crossrow;
begin
    fork 
        begin
            @(posedge clk) begin
                axi_arvalid <= 1'b1;
                axi_arlen   <= 6'd4;
                axi_araddr  <= {14'd100,6'd63};   
            end
            #0.1 wait(axi_arready==1'b1);
            @(posedge clk)
                axi_arvalid <= 1'b0;           
        end
        begin
            wait(array_cas_rd==1'b1);
            wait(array_cas_rd==1'b0);  
            #1.5 begin
                array_rdata_rdy <= 1'b0   ;
                array_rdata     <= 64'd100;
            end
            #2.5 array_rdata_rdy = 1'b1;
            wait(array_cas_rd==1'b1);
            wait(array_cas_rd==1'b0);              
            #1.5 begin
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
            #2.5 begin
                array_rdata_rdy <= 1'b0;
                array_rdata     <= 64'd104;                
            end
            #2.5 array_rdata_rdy = 1'b1;
        end
    join
end
endtask

initial begin
    #20 mc_apb_cfg;
    repeat(10) @(posedge clk); //wait mc_en==1'b1
    axi_array_wr_notcrossrow;
    repeat(500) @(posedge clk);
    axi_array_rd_crossrow;
    repeat(500) @(posedge clk);
    repeat(5000) @(posedge clk);
    $finish;
end

initial begin
    $fsdbDumpfile("wave_mc_top.fsdb");
    $fsdbDumpvars;
end

endmodule
