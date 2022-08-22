`timescale 1ns/1ns

module tb_OEC();

parameter IMAGE_WIDTH  = 2016; 
parameter IMAGE_HEIGHT = 1512; 
parameter WIN_W        = 26  ;
parameter WIN_H        = 14  ;
parameter DW_HEX       = 12  ;
parameter DW_IN        = 10  ;

parameter HB           = 52  ;
parameter VB           = 30  ;
parameter VB_ET        = 1   ;
parameter VB_ST        = 1   ;
parameter PCLK         = 4   ;
parameter TOTAL_FRAME  = 1   ;

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
    $readmemh("OEC_mat_4C.file", MEM_SIG);
    for(m = 0; m < IMAGE_HEIGHT; m = m+1)
        for(n = 0; n < IMAGE_WIDTH; n = n+1)
        begin
            MEM_2D[m][n] = MEM_SIG[m+n*IMAGE_HEIGHT];
        end
end

wire [12:0] MEM_col  = col_counter;
wire [12:0] MEM_row  = (row_counter>=12'd1) ? row_counter-1 : row_counter;

wire [DW_HEX*4-1:0] data1_tmp; 
wire [DW_HEX*4-1:0] data2_tmp; 
wire [DW_HEX*4-1:0] data3_tmp; 

assign data1_tmp = (MEM_row>=13'd3)? MEM_2D[MEM_row-3][MEM_col]:MEM_2D[0][MEM_col];
assign data2_tmp = (MEM_row>=13'd2)? MEM_2D[MEM_row-2][MEM_col]:MEM_2D[0][MEM_col];
assign data3_tmp = (MEM_row>=13'd1)? MEM_2D[MEM_row-1][MEM_col]:MEM_2D[0][MEM_col];

wire [DW_HEX*4-1:0] data4_tmp = MEM_2D[MEM_row  ][MEM_col];
wire [DW_HEX*4-1:0] data5_tmp = MEM_2D[MEM_row+1][MEM_col];
wire [DW_HEX*4-1:0] data6_tmp = MEM_2D[MEM_row+2][MEM_col];
wire [DW_HEX*4-1:0] data7_tmp = MEM_2D[MEM_row+3][MEM_col];

//data_in1
wire [DW_HEX-1:0] data1_tmpr  = data1_tmp[DW_HEX*4-1:DW_HEX*3];
wire [DW_HEX-1:0] data1_tmpg1 = data1_tmp[DW_HEX*3-1:DW_HEX*2];
wire [DW_HEX-1:0] data1_tmpg2 = data1_tmp[DW_HEX*2-1:DW_HEX  ];
wire [DW_HEX-1:0] data1_tmpb  = data1_tmp[DW_HEX-1  :0       ];

wire [DW_IN-1:0] data1_inr  = data1_tmpr [DW_IN-1:0];  // safe
wire [DW_IN-1:0] data1_ing1 = data1_tmpg1[DW_IN-1:0];
wire [DW_IN-1:0] data1_ing2 = data1_tmpg2[DW_IN-1:0];
wire [DW_IN-1:0] data1_inb  = data1_tmpb [DW_IN-1:0];

wire [DW_IN*4-1:0] data1_in = {data1_inr, data1_ing1, data1_ing2, data1_inb};

//data_in2
wire [DW_HEX-1:0] data2_tmpr  = data2_tmp[DW_HEX*4-1:DW_HEX*3];
wire [DW_HEX-1:0] data2_tmpg1 = data2_tmp[DW_HEX*3-1:DW_HEX*2];
wire [DW_HEX-1:0] data2_tmpg2 = data2_tmp[DW_HEX*2-1:DW_HEX  ];
wire [DW_HEX-1:0] data2_tmpb  = data2_tmp[DW_HEX-1  :0       ];

wire [DW_IN-1:0] data2_inr  = data2_tmpr [DW_IN-1:0];
wire [DW_IN-1:0] data2_ing1 = data2_tmpg1[DW_IN-1:0];
wire [DW_IN-1:0] data2_ing2 = data2_tmpg2[DW_IN-1:0];
wire [DW_IN-1:0] data2_inb  = data2_tmpb [DW_IN-1:0];

wire [DW_IN*4-1:0] data2_in = {data2_inr, data2_ing1, data2_ing2, data2_inb};

//data_in3
wire [DW_HEX-1:0] data3_tmpr  = data3_tmp[DW_HEX*4-1:DW_HEX*3];
wire [DW_HEX-1:0] data3_tmpg1 = data3_tmp[DW_HEX*3-1:DW_HEX*2];
wire [DW_HEX-1:0] data3_tmpg2 = data3_tmp[DW_HEX*2-1:DW_HEX  ];
wire [DW_HEX-1:0] data3_tmpb  = data3_tmp[DW_HEX-1  :0       ];

wire [DW_IN-1:0] data3_inr  = data3_tmpr [DW_IN-1:0];
wire [DW_IN-1:0] data3_ing1 = data3_tmpg1[DW_IN-1:0];
wire [DW_IN-1:0] data3_ing2 = data3_tmpg2[DW_IN-1:0];
wire [DW_IN-1:0] data3_inb  = data3_tmpb [DW_IN-1:0];

wire [DW_IN*4-1:0] data3_in = {data3_inr, data3_ing1, data3_ing2, data3_inb};

//data_in4
wire [DW_HEX-1:0] data4_tmpr  = data4_tmp[DW_HEX*4-1:DW_HEX*3];
wire [DW_HEX-1:0] data4_tmpg1 = data4_tmp[DW_HEX*3-1:DW_HEX*2];
wire [DW_HEX-1:0] data4_tmpg2 = data4_tmp[DW_HEX*2-1:DW_HEX  ];
wire [DW_HEX-1:0] data4_tmpb  = data4_tmp[DW_HEX-1  :0       ];

wire [DW_IN-1:0] data4_inr  = data4_tmpr [DW_IN-1:0];
wire [DW_IN-1:0] data4_ing1 = data4_tmpg1[DW_IN-1:0];
wire [DW_IN-1:0] data4_ing2 = data4_tmpg2[DW_IN-1:0];
wire [DW_IN-1:0] data4_inb  = data4_tmpb [DW_IN-1:0];

wire [DW_IN*4-1:0] data4_in = {data4_inr, data4_ing1, data4_ing2, data4_inb};

//data_in5
wire [DW_HEX-1:0] data5_tmpr  = data5_tmp[DW_HEX*4-1:DW_HEX*3];
wire [DW_HEX-1:0] data5_tmpg1 = data5_tmp[DW_HEX*3-1:DW_HEX*2];
wire [DW_HEX-1:0] data5_tmpg2 = data5_tmp[DW_HEX*2-1:DW_HEX  ];
wire [DW_HEX-1:0] data5_tmpb  = data5_tmp[DW_HEX-1  :0       ];

wire [DW_IN-1:0] data5_inr  = data5_tmpr [DW_IN-1:0];
wire [DW_IN-1:0] data5_ing1 = data5_tmpg1[DW_IN-1:0];
wire [DW_IN-1:0] data5_ing2 = data5_tmpg2[DW_IN-1:0];
wire [DW_IN-1:0] data5_inb  = data5_tmpb [DW_IN-1:0];

wire [DW_IN*4-1:0] data5_in = {data5_inr, data5_ing1, data5_ing2, data5_inb};

//data_in6
wire [DW_HEX-1:0] data6_tmpr  = data6_tmp[DW_HEX*4-1:DW_HEX*3];
wire [DW_HEX-1:0] data6_tmpg1 = data6_tmp[DW_HEX*3-1:DW_HEX*2];
wire [DW_HEX-1:0] data6_tmpg2 = data6_tmp[DW_HEX*2-1:DW_HEX  ];
wire [DW_HEX-1:0] data6_tmpb  = data6_tmp[DW_HEX-1  :0       ];

wire [DW_IN-1:0] data6_inr  = data6_tmpr [DW_IN-1:0];
wire [DW_IN-1:0] data6_ing1 = data6_tmpg1[DW_IN-1:0];
wire [DW_IN-1:0] data6_ing2 = data6_tmpg2[DW_IN-1:0];
wire [DW_IN-1:0] data6_inb  = data6_tmpb [DW_IN-1:0];

wire [DW_IN*4-1:0] data6_in = {data6_inr, data6_ing1, data6_ing2, data6_inb};

//data_in7
wire [DW_HEX-1:0] data7_tmpr  = data7_tmp[DW_HEX*4-1:DW_HEX*3];
wire [DW_HEX-1:0] data7_tmpg1 = data7_tmp[DW_HEX*3-1:DW_HEX*2];
wire [DW_HEX-1:0] data7_tmpg2 = data7_tmp[DW_HEX*2-1:DW_HEX  ];
wire [DW_HEX-1:0] data7_tmpb  = data7_tmp[DW_HEX-1  :0       ];

wire [DW_IN-1:0] data7_inr  = data7_tmpr [DW_IN-1:0];
wire [DW_IN-1:0] data7_ing1 = data7_tmpg1[DW_IN-1:0];
wire [DW_IN-1:0] data7_ing2 = data7_tmpg2[DW_IN-1:0];
wire [DW_IN-1:0] data7_inb  = data7_tmpb [DW_IN-1:0];

wire [DW_IN*4-1:0] data7_in = {data7_inr, data7_ing1, data7_ing2, data7_inb};

top_oec U_top_oec0(
    .clk     (clk     ),
    .rst_n   (rst_n   ),
    .vsync_in(vsync_in),
    .hsync_in(hsync_in),
    .data_in1(data1_in),
    .data_in2(data2_in),
    .data_in3(data3_in),
    .data_in4(data4_in),
    .data_in5(data5_in),
    .data_in6(data6_in),
    .data_in7(data7_in),
    .imo(imo),
    .hsync_out(hsync_out)
);

initial begin
    $fsdbDumpfile("wave_OEC.fsdb");
    $fsdbDumpvars;
end

endmodule


