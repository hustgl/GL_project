`timescale 1ns/1ns

module tb_sync_fifo;

parameter DATA_WIDTH   = 8           ;
parameter FIFO_DEPTH   = 8           ;
parameter AFULL_DEPTH  = FIFO_DEPTH-1;
parameter AEMPTY_DEPTH = 1           ;
parameter RDATA_MODE   = 0           ; 

reg                   clk         ;
reg                   rst_n       ;
reg                   wr_en       ;
reg  [DATA_WIDTH-1:0] wr_data     ;
reg                   rd_en       ;
wire [DATA_WIDTH-1:0] rd_data     ;
wire                  full        ;
wire                  almost_full ;
wire                  empty       ;
wire                  almost_empty;
wire                  overflow    ;
wire                  underflow   ;

integer I, II;

sync_fifo #(
    .DATA_WIDTH  (DATA_WIDTH  ),
    .FIFO_DEPTH  (FIFO_DEPTH  ),
    .AFULL_DEPTH (AFULL_DEPTH ),
    .AEMPTY_DEPTH(AEMPTY_DEPTH),
    .RDATA_MODE  (RDATA_MODE  )
)U_sync_fifo1(
    .clk         (clk         ),
    .rst_n       (rst_n       ),
                 
    .wr_en       (wr_en       ),
    .wr_data     (wr_data     ),
    .rd_en       (rd_en       ),
    .rd_data     (rd_data     ),

    .full        (full        ),
    .almost_full (almost_full ),
    .empty       (empty       ),
    .almost_empty(almost_empty),
    .overflow    (overflow    ),
    .underflow   (underflow   )
);

initial begin
    clk = 0; rst_n = 0; wr_en = 0; wr_data = 0; rd_en = 0;
    #50 rst_n = 1;
end

always #5 clk = ~clk;

initial begin
    #60;
    fork 
        send_wr_cmd;
        send_rd_cmd;
    join    
end

task send_wr_cmd;
begin
    for(I = 0; I < 10; I = I+1) begin
        @(posedge clk) begin
            wr_en   <= 1   ;
            wr_data <= I+1 ;
        end
    end
    @(posedge clk) begin
        wr_en   <= 0;
        wr_data <= 0;
    end
    repeat(10) @(posedge clk);
    $finish;
end
endtask

task send_rd_cmd;
begin
    @(posedge clk);
    for(II = 0; II < 2; II = II+1) begin
        @(posedge clk) begin
            rd_en <= 1'b1;
        end
    end
    @(posedge clk) rd_en <= 1'b0;
end
endtask

initial begin
    $fsdbDumpfile("wave_sync_fifo.fsdb");
    $fsdbDumpvars;
end


endmodule
