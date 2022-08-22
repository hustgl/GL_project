`timescale 1ns/1ns

module tb_i2c_bit_shift;

`define SDA_IN_TEST

parameter CMD_WIDTH  = 6         ;
parameter DATA_WIDTH = 8         ;
parameter SYS_CLK    = 50_000_000;
parameter SCLK_FREQ  = 400_000   ;

reg                       clk         ;
reg                       rst_n       ;
                                  
reg      [CMD_WIDTH-1 :0] cmd         ;
reg                       work_en     ;
                                  
reg      [DATA_WIDTH-1:0] tx_data     ;
wire     [DATA_WIDTH-1:0] rx_data     ;
wire                      trans_done  ;
wire                      ack_o       ;

reg                       i2c_sda     ;
wire                      i2c_sda_wire;
wire                      i2c_sclk    ;

`ifdef SDA_IN_TEST
wire     [2           :0] fsm_cs_o    ;
wire                      flag_o      ;
reg      [2           :0] fsm_cs_o_d  ;
wire                      isout_o     ;
`endif

pullup PUP(i2c_sda_wire);

localparam WR    = 6'b000001,
           START = 6'b000010,
           RD    = 6'b000100,
           STOP  = 6'b001000,
           ACK   = 6'b010000,
           NACK  = 6'b100000;

i2c_bit_shift U_i2c_bit_shift0(
`ifdef SDA_IN_TEST
    .fsm_cs_o  (fsm_cs_o    ),
    .flag_o    (flag_o      ),
    .isout_o   (isout_o     ), 
`endif
    .clk       (clk         ),
    .rst_n     (rst_n       ),
                           
    .cmd       (cmd         ),
    .work_en   (work_en     ),
                           
    .tx_data   (tx_data     ),
    .rx_data   (rx_data     ),
    .trans_done(trans_done  ),
    .ack_o     (ack_o       ),
                           
    .i2c_sda   (i2c_sda_wire),
    .i2c_sclk  (i2c_sclk    )
);          

/*
M24LC04B M24LC04B(
    .A0   (1'b0    ), 
    .A1   (1'b0    ), 
    .A2   (1'b0    ), 
    .WP   (1'b0    ), 
    .SDA  (i2c_sda ), 
    .SCL  (i2c_sclk), 
    .RESET(~rst_n  )
); */

always #10 clk = ~clk;

`ifdef SDA_IN_TEST
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fsm_cs_o_d <= 3'd0;
else if(flag_o)
    fsm_cs_o_d <= fsm_cs_o;
end

assign i2c_sda_wire = (!isout_o)? i2c_sda: 1'bz;
`endif

initial begin
    clk = 1; rst_n = 0; cmd = 6'b000000; 
    work_en = 0; tx_data = 8'd0; i2c_sda = 1'b1;
    #50 rst_n = 1;

    @(posedge clk) begin
        cmd     <= START|WR|STOP;
        work_en <= 1'b1      ;
        tx_data <= 8'hAA|8'd0;
    end 
    @(posedge clk) work_en <= 1'b0;
`ifdef SDA_IN_TEST    
    @(negedge isout_o) i2c_sda <= 1'b0;
    @(posedge isout_o) i2c_sda <= 1'b1;
`endif    
    repeat(5000) @(posedge clk);
    $finish;
end

initial begin
    $fsdbDumpfile("wave_i2c_bit_shift.fsdb");
    $fsdbDumpvars;
end

endmodule
