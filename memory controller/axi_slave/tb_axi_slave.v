`timescale 1ns/1ns
module tb_axi_slave();

parameter AXI_ADDR_WIDTH = 20;
parameter AXI_DATA_WIDTH = 64;
parameter AXI_LEN_WIDTH  = 6 ;
parameter AXI_FRAME_WIDTH = AXI_ADDR_WIDTH + AXI_DATA_WIDTH + 3;

reg clk      ;
reg rst_n    ;
reg mc_en    ;

//axi aw channel
reg                       axi_awvalid;
wire                      axi_awready;
reg  [AXI_LEN_WIDTH-1:0]  axi_awlen  ;
reg  [AXI_ADDR_WIDTH-1:0] axi_awaddr ;
//axi w channel
reg                       axi_wvalid ;
wire                      axi_wready ;
reg  [AXI_DATA_WIDTH-1:0] axi_wdata  ;
reg                       axi_wlast  ;
//axi ar channel
reg                       axi_arvalid;
wire                      axi_arready;
reg  [AXI_LEN_WIDTH-1:0]  axi_arlen  ;
reg  [AXI_ADDR_WIDTH-1:0] axi_araddr ;
//axi r channel
wire                      axi_rvalid ;
wire [AXI_DATA_WIDTH-1:0] axi_rdata  ;
wire                      axi_rlast  ;
//axi frame
wire [AXI_FRAME_WIDTH-1:0] axi_frame_data ;
wire                       axi_frame_valid;
reg                        axi_frame_ready;
reg  [AXI_DATA_WIDTH-1:0]  array_rdata    ;
reg                        array_rvalid   ;

integer I;
integer II;

axi_slave U_axi_slave0(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .mc_en          (mc_en          ),
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

    .axi_frame_data (axi_frame_data ),  
    .axi_frame_valid(axi_frame_valid),
    .axi_frame_ready(axi_frame_ready),
    .array_rdata    (array_rdata    ),
    .array_rvalid   (array_rvalid   )
);

initial begin
    clk = 0;rst_n = 0; mc_en = 0;
    axi_awvalid = 0; axi_awlen = 0; axi_awaddr = 0;
    axi_wvalid = 0; axi_wdata = 0; axi_wlast = 0;
    axi_arvalid = 0; axi_arlen = 0; axi_araddr = 0;
    axi_frame_ready = 0; array_rdata = 0; array_rvalid = 0;
    #10 rst_n = 1; mc_en = 1'b1;
end

always #5 clk = ~clk;

initial begin
    #20 send_axi_wr;
    #20 send_axi_rd;
    #100 $finish;
end

initial begin
    $fsdbDumpfile("axi_slave.fsdb");
    $fsdbDumpvars;
end

task send_axi_wr;
begin
    fork 
        begin
            @(posedge clk) begin
                axi_awvalid <= 1'b1;
                axi_awlen   <= 6'd4;
                axi_awaddr  <= {14'd100,6'd50};
            end
            #1 wait(axi_awready==1'b1);
            @(posedge clk) 
                axi_awvalid <= 1'b0;
        end
        begin
            //awlen=4 means 5 datas
            for(I=0; I<4; I=I+1) begin
                @(posedge clk) begin
                    axi_wvalid <= 1'b1;
                    axi_wdata  <= I+1 ;
                end
                #1 wait(axi_wready==1'b1);
            end
            @(posedge clk) begin
                axi_wvalid <= 1'b1;
                axi_wdata  <= 64'd4;
                axi_wlast  <= 1'b1;
                #1 wait(axi_wready==1'b1);
            end
            @(posedge clk) begin
                axi_wvalid <= 1'b0 ;
                axi_wdata  <= 64'd0;
                axi_wlast  <= 1'b0 ;
            end    
        end
        begin
            @(posedge clk) axi_frame_ready <= 1'b0;
            repeat(4) @(posedge clk);
            @(posedge clk) axi_frame_ready <= 1'b1;
            repeat(20) @(posedge clk);
            @(posedge clk) axi_frame_ready <= 1'b0;
        end
    join
end
endtask

task send_axi_rd;
begin
    fork
        begin
            @(posedge clk) begin
                axi_arvalid <= 1'b1;
                axi_arlen   <= 6'd4;
                axi_araddr  <= {14'd100,6'd50};   
            end
            #1 wait(axi_arready==1'b1);
            @(posedge clk)
                axi_arvalid <= 1'b0;
        end
        begin
            @(posedge clk)
                axi_frame_ready <= 1'b1;
        end
        begin
            repeat(20) @(posedge clk);
            for(II=0; II<=4; II=II+1) 
                @(posedge clk) begin
                    array_rdata  <= II+1;
                    array_rvalid <= 1'b1;
                end
            @(posedge clk) begin
                array_rdata  <= 64'd0;
                array_rvalid <= 1'b0 ;
            end
        end
    join
end
endtask


endmodule
