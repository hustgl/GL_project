`timescale 1ns/1ns

module tb_upscaler();

parameter IMAGE_WIDTH  = 1280/2; 
parameter IMAGE_HEIGHT = 720/2 ; 
parameter WIN_W        = 40/2  ;
parameter WIN_H        = 16/2  ;
parameter DW_HEX       = 8     ;
parameter DW_IN        = 8     ;

parameter HB           = 20    ;
parameter VB           = 10    ;
parameter VB_ET        = 1     ;
parameter VB_ST        = 1     ;
parameter PCLK         = 4     ;
parameter TOTAL_FRAME  = 1     ;

integer m,n;

reg [12:0] col_counter  ;
reg [7:0]  vsync_counter;
reg [12:0] row_counter  ;

reg clk     ,hclk    ,rst_n     ;
reg vsync_in,hsync_in,start_flag;

reg [DW_HEX*4-1:0] MEM_SIG[0:IMAGE_WIDTH*IMAGE_HEIGHT-1]     ;
reg [DW_HEX*4-1:0] MEM_2D [0:IMAGE_HEIGHT-1][0:IMAGE_WIDTH-1];

wire [DW_IN*4-1:0] imo;
wire               hsync_out;

initial begin
    clk      = 1; hclk       = 1;
    vsync_in = 0; hsync_in   = 0;
    rst_n    = 1; start_flag = 0;
    #20  rst_n      = 0;
    #20  rst_n      = 1;
    #100 start_flag = 1;
end

always #(PCLK/2) clk  = ~clk ;
always #(PCLK)   hclk = ~hclk;

always @(posedge start_flag)
begin
    repeat(TOTAL_FRAME+1)
    begin
        vsync_in <= 1;
        #((VB_ST+WIN_H+VB_ET)*(WIN_W+HB)*PCLK);  
        vsync_in <= 0;
        #(VB*(WIN_W+HB)*PCLK);
    end 
end

always @(posedge vsync_in)
begin
    hsync_in <= 0;
    #(VB_ST*(WIN_W+HB)*PCLK);
    repeat (WIN_H) // hsync_in period = WIN_W+HB
    begin
        hsync_in <= 1;
        #(WIN_W*PCLK);
        hsync_in <= 0;
        #(HB*PCLK);
    end
end

reg vsync_in_d,hsync_in_d;
always @(posedge clk or negedge rst_n)
if(~rst_n) begin
    vsync_in_d <= 1'b0;
    hsync_in_d <= 1'b0;
end
else begin
    vsync_in_d <= vsync_in; // vsync_in default 0
    hsync_in_d <= hsync_in;
end

wire vsync_in_pos = vsync_in & ~vsync_in_d; 

always @(posedge vsync_in or negedge rst_n)
if(~rst_n)
    vsync_counter <= 8'd0;
else begin
    vsync_counter <= vsync_counter+1;
    $display("Frame: %d",vsync_counter);
    if(vsync_counter >= TOTAL_FRAME)
        $finish;
end

always @(posedge hsync_in or posedge vsync_in_pos)
if(vsync_in_pos)
	row_counter <= 0;
else if(~&row_counter) begin  //not all 1
	row_counter <= row_counter+1;
    if(row_counter%40 == 0)
        $display("    Row: %d",row_counter);
end

always @(posedge clk or negedge rst_n)
if(~rst_n)
	col_counter <= 13'd0;
else if(hsync_in | hsync_in_d)
	col_counter <= col_counter+1;
else
	col_counter <= 13'd0;


initial
begin
    $readmemh("test_mat.file", MEM_SIG);
    for(m = 0; m < IMAGE_HEIGHT; m = m+1)
        for(n = 0; n < IMAGE_WIDTH; n = n+1)
        begin
            MEM_2D[m][n] = MEM_SIG[m+n*IMAGE_HEIGHT];
        end
end

wire [12:0] MEM_col  = col_counter;
wire [12:0] MEM_row  = (row_counter>=12'd1) ? row_counter-1 : row_counter;

wire [DW_HEX*4-1:0] data1_tmp = MEM_2D[MEM_row][MEM_col]; // 4 pixel

//data_in1
wire [DW_HEX-1:0] data1_tmp_00 = data1_tmp[DW_HEX*4-1:DW_HEX*3];
wire [DW_HEX-1:0] data1_tmp_10 = data1_tmp[DW_HEX*3-1:DW_HEX*2];
wire [DW_HEX-1:0] data1_tmp_01 = data1_tmp[DW_HEX*2-1:DW_HEX  ];
wire [DW_HEX-1:0] data1_tmp_11 = data1_tmp[DW_HEX-1  :0       ];

wire [DW_IN-1:0] data1_00 = data1_tmp_00[DW_IN-1:0];  // safe
wire [DW_IN-1:0] data1_10 = data1_tmp_10[DW_IN-1:0];
wire [DW_IN-1:0] data1_01 = data1_tmp_01[DW_IN-1:0];
wire [DW_IN-1:0] data1_11 = data1_tmp_11[DW_IN-1:0];

wire [DW_IN*4-1:0] data1_in = {data1_00, data1_10, data1_01, data1_11};

top_upscaler U_top_upscaler0(
    .clk     (clk     ),
    .rst_n   (rst_n   ),
    .vsync_in(vsync_in),
    .hsync_in(hsync_in),
    .data_in (data1_in),
    .data_out(        ),
    .vsync_o (        ),
    .hsync_o (        )
);

initial begin
    $fsdbDumpfile("wave_upscaler.fsdb");
    $fsdbDumpvars;
end

endmodule


