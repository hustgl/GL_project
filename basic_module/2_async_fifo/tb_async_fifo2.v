`timescale 1ns/1ps
module tb_async_fifo();

parameter DATA_WIDTH  = 4             ;
parameter FIFO_DEPTH  = 8             ;
parameter FIFO_AFULL  = FIFO_DEPTH - 1;
parameter FIFO_AEMPTY = 1             ;

reg                   wr_clk  ;
reg                   wr_rst_n;
reg                   wr_en   ;
reg  [DATA_WIDTH-1:0] wr_data ;
reg                   rd_clk  ;
reg                   rd_rst_n;
reg                   rd_en   ;
wire [DATA_WIDTH-1:0] rd_data ;
wire                  full    ;
wire                  afull   ;
wire                  aempty  ;
wire                  empty   ;

integer  I;
integer II;

async_fifo #(
    .DATA_WIDTH (DATA_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH),
    .FIFO_AFULL (FIFO_AFULL),
    .FIFO_AEMPTY(FIFO_AEMPTY)
) u_async_fifo0(
    .wr_clk  (wr_clk  ),
    .wr_rst_n(wr_rst_n),
    .wr_en   (wr_en   ),
    .wr_data (wr_data ),
    .rd_clk  (rd_clk  ),
    .rd_rst_n(rd_rst_n),
    .rd_en   (rd_en   ),
    .rd_data (rd_data ),
    .full    (full    ),
    .afull   (afull   ),
    .aempty  (aempty  ),
    .empty   (empty   )
);

initial begin
    wr_clk = 0; wr_rst_n = 0; rd_clk = 0; rd_rst_n = 0;
    wr_en = 0; wr_data = {DATA_WIDTH{1'b0}}; rd_en = 0;
    #10 wr_rst_n = 1; rd_rst_n = 1;
end

initial begin
    #20 send_wr;
    send_rd;
    $finish;
end

/*
initial begin
    #20 send_rd;
end
*/

always #5  wr_clk = ~wr_clk;
always #12 rd_clk = ~rd_clk;

task send_wr;
begin
    for(I = 0; I < 10; I = I+1) begin
        @(posedge wr_clk) begin
            wr_en <= 1'b1;
            wr_data <= I + 13;
        end
    end
    @(posedge wr_clk) begin
        wr_en <= 1'b0;
        wr_data <= {DATA_WIDTH{1'b0}};
    end
    repeat(5) @(posedge wr_clk);  
end
endtask

task send_rd;
begin
    @(posedge rd_clk);
    for(II = 0; II < 10; II = II + 1) begin
        @(posedge rd_clk) begin
            rd_en <= 1'b1;
        end
    end
    @(posedge rd_clk) rd_en <= 1'b0;
    repeat(10) @(posedge rd_clk);
end
endtask

initial begin
    $fsdbDumpfile("wave_async_fifo.fsdb");
    $fsdbDumpvars;
    $fsdbDumpMDA();
end

endmodule
