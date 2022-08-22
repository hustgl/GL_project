module top_oec #(
    parameter DW_IN  = 10,
    parameter DW_DEC = 8 ,
    parameter WIN_W  = 26,
    parameter WIN_H  = 14,
    parameter HB     = 52
)(
    input                    clk      ,
    input                    rst_n    ,
    input                    vsync_in ,
    input                    hsync_in ,
    input      [DW_IN*4-1:0] data_in1 ,
    input      [DW_IN*4-1:0] data_in2 ,
    input      [DW_IN*4-1:0] data_in3 ,
    input      [DW_IN*4-1:0] data_in4 ,
    input      [DW_IN*4-1:0] data_in5 ,
    input      [DW_IN*4-1:0] data_in6 ,
    input      [DW_IN*4-1:0] data_in7 ,

    output reg [DW_IN*4-1:0] imo      ,
    output reg               hsync_out
);

localparam ROW_CNT_WIDTH = 4;
localparam COL_CNT_WIDTH = 5;
localparam HB_CNT_WIDTH  = 6;
localparam IMCORW_DELAY  = 8; 

//output from array_load
wire [DW_IN*4-1:0]  row1_buf1, row1_buf2, row1_buf3 , row1_buf4 , row1_buf5 , row1_buf6 , row1_buf7; 
wire [DW_IN*4-1:0]  row1_buf8, row1_buf9, row1_buf10, row1_buf11, row1_buf12, row1_buf13;

wire [DW_IN*4-1:0]  row2_buf1, row2_buf2, row2_buf3 , row2_buf4 , row2_buf5 , row2_buf6 , row2_buf7; 
wire [DW_IN*4-1:0]  row2_buf8, row2_buf9, row2_buf10, row2_buf11, row2_buf12, row2_buf13;

wire [DW_IN*4-1:0]  row3_buf1, row3_buf2, row3_buf3 , row3_buf4 , row3_buf5 , row3_buf6 , row3_buf7; 
wire [DW_IN*4-1:0]  row3_buf8, row3_buf9, row3_buf10, row3_buf11, row3_buf12, row3_buf13;

wire [DW_IN*4-1:0]  row4_buf1, row4_buf2, row4_buf3 , row4_buf4 , row4_buf5 , row4_buf6 , row4_buf7; 
wire [DW_IN*4-1:0]  row4_buf8, row4_buf9, row4_buf10, row4_buf11, row4_buf12, row4_buf13;

wire [DW_IN*4-1:0]  row5_buf1, row5_buf2, row5_buf3 , row5_buf4 , row5_buf5 , row5_buf6 , row5_buf7; 
wire [DW_IN*4-1:0]  row5_buf8, row5_buf9, row5_buf10, row5_buf11, row5_buf12, row5_buf13;

wire [DW_IN*4-1:0]  row6_buf1, row6_buf2, row6_buf3 , row6_buf4 , row6_buf5 , row6_buf6 , row6_buf7; 
wire [DW_IN*4-1:0]  row6_buf8, row6_buf9, row6_buf10, row6_buf11, row6_buf12, row6_buf13;

wire [DW_IN*4-1:0]  row7_buf1, row7_buf2, row7_buf3 , row7_buf4 , row7_buf5 , row7_buf6 , row7_buf7;
wire [DW_IN*4-1:0]  row7_buf8, row7_buf9, row7_buf10, row7_buf11, row7_buf12, row7_buf13;

//imo prefetch replace
reg [DW_IN*4-1:0] imo_replace_line1_7 , imo_replace_line1_8 , imo_replace_line1_9 , imo_replace_line1_10;
reg [DW_IN*4-1:0] imo_replace_line1_11, imo_replace_line1_12, imo_replace_line1_13;

reg [DW_IN*4-1:0] imo_replace_line2_7 , imo_replace_line2_8 , imo_replace_line2_9 , imo_replace_line2_10;
reg [DW_IN*4-1:0] imo_replace_line2_11, imo_replace_line2_12, imo_replace_line2_13;

reg [DW_IN*4-1:0] imo_replace_line3_7 , imo_replace_line3_8 , imo_replace_line3_9 , imo_replace_line3_10;
reg [DW_IN*4-1:0] imo_replace_line3_11, imo_replace_line3_12, imo_replace_line3_13;                    

reg [DW_IN*4-1:0] imo_replace_line1_in    , imo_replace_line2_in    , imo_replace_line3_in    ;
reg [DW_IN*4-1:0] imo_replace_line1_in_reg, imo_replace_line2_in_reg, imo_replace_line3_in_reg;

//counter logic
reg  [ROW_CNT_WIDTH-1:0] row_cnt     ;
reg  [COL_CNT_WIDTH-1:0] col_cnt     ;
wire [ROW_CNT_WIDTH-1:0] row_cnt_comb;
reg  [HB_CNT_WIDTH-1:0 ] hb_cnt      ;
reg                      hb_cnt_en   ;

//detect hsync posedge 
reg  hsync_d1 ;
wire hsync_pos;

//array flag
wire array_load_start;
wire array_load_done ;
reg  array_flow_en;

//imcinww signal
wire               wb_en                  ;
wire [DW_IN*4-1:0] wb_gain_data_out3      ;
wire [DW_IN*4-1:0] wb_gain_data_out4      ;
wire [DW_IN*4-1:0] wb_gain_data_out5      ;
wire               filter_start           ;
wire               filter_end             ;
wire               wb_gain_vsync_out3     ; 
wire               wb_gain_vsync_out4     ; 
wire               wb_gain_vsync_out5     ;
wire               wb_gain_hsync_out3     ; 
wire               wb_gain_hsync_out4     ; 
wire               wb_gain_hsync_out5     ;
wire               imcorw_mixrb_hsync_out3;
wire [DW_DEC   :0] imcorw_mixrb3          ;
wire               imcorw_mixrb_hsync_out4;
wire [DW_DEC   :0] imcorw_mixrb4          ;
wire               imcorw_mixrb_hsync_out5;
wire [DW_DEC   :0] imcorw_mixrb5          ;
wire [DW_DEC   :0] imcorww                ;
wire               imcorww_valid          ;
wire [DW_IN*4-1:0] imcinww                ;


//first 6 and last 6 signal
reg [2:0] first_6_cnt    ;
wire      first_6_cnt_en ;
reg [2:0] last_6_cnt     ;
wire      last_6_cnt_en  ;
wire      imosum_valid   ;
reg       imosum_valid_d1;
reg       imosum_valid_d2;
reg       imosum_valid_d3;
reg       imosum_valid_d4;

reg [DW_IN*4-1:0] col0_buf , col1_buf , col2_buf , col3_buf , col4_buf , col5_buf ; // the first 6 buf
reg [DW_IN*4-1:0] col_1_buf, col_2_buf, col_3_buf, col_4_buf, col_5_buf, col_6_buf; // the last 6 buf

//imo signal
wire               imo1_valid      ;
wire [DW_IN*4-1:0] imo4            ;
wire               imo4_valid      ;
wire [DW_IN*4-1:0] imcin_d1        ; //not delay 1clk, wait for imo
reg  [DW_IN*4-1:0] imcin_d2        ;
reg  [DW_IN*4-1:0] imo5            ;
reg                imo5_valid      ;
reg  [5:0]         imo5_valid_delay;
wire               hsync_out_tmp   ;

wire [DW_IN+DW_DEC:0] imo6_1_tmp1 , imo6_1_tmp2 , imo6_1      ;
wire [DW_IN+DW_DEC:0] imo6_2_tmp1 , imo6_2_tmp2 , imo6_2      ;
wire [DW_IN+DW_DEC:0] imo6_3_tmp1 , imo6_3_tmp2 , imo6_3      ;
wire [DW_IN+DW_DEC:0] imo6_4_tmp1 , imo6_4_tmp2 , imo6_4      ;

wire [DW_IN-1     :0] imo6_1_clamp, imo6_2_clamp, imo6_3_clamp, imo6_4_clamp;

//SRAM signal
wire sram1_cen, sram1_wen;
wire sram2_cen, sram2_wen;
wire sram3_cen, sram3_wen;
wire sram4_cen, sram4_wen;

wire [DW_IN*4-1:0] sram1_wr_data, sram2_wr_data, sram3_wr_data, sram4_wr_data;
wire [11:0]        sram1_addr   , sram2_addr   , sram3_addr   , sram4_addr   ;
wire [11:0]        wr_addr      , prefetch_addr, rd_addr      ;
wire [DW_IN*4-1:0] sram1_rd_data, sram2_rd_data, sram3_rd_data, sram4_rd_data;

wire                     sram_flow_rd_req        ;
reg                      sram_flow_rd_req_d1     ;
wire                     sram_prefetch_rd_req    ;
reg                      sram_prefetch_rd_req_d1 ; //delay 1clk
reg  [COL_CNT_WIDTH-1:0] sram_imcinww_addr       ;
reg                      sram_imcinww_cen        ;
reg                      sram_imcinww_wen        ;
wire [DW_IN*4-1      :0] sram_imcinww_rd_data    ;
reg  [DW_IN*4-1      :0] sram_imcinww_rd_data_reg;

//first 6 and last 6 logic
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        imosum_valid_d1 <= 1'b0;
        imosum_valid_d2 <= 1'b0;
        imosum_valid_d3 <= 1'b0;
        imosum_valid_d4 <= 1'b0;
    end
    else begin
        imosum_valid_d1 <= imosum_valid   ;
        imosum_valid_d2 <= imosum_valid_d1;
        imosum_valid_d3 <= imosum_valid_d2;
        imosum_valid_d4 <= imosum_valid_d3;
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo5_valid_delay <= 6'd0;
else
    imo5_valid_delay <= {imo5_valid_delay[4:0], imo5_valid};
end

assign last_6_cnt_en  = imo5_valid_delay && (~imo5_valid);

assign first_6_cnt_en = imosum_valid_d4  && (~imo5_valid);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    first_6_cnt <= 3'd0;
else if(first_6_cnt_en)
    first_6_cnt <= first_6_cnt + 3'd1;
else
    first_6_cnt <= 3'd0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    last_6_cnt <= 3'd0;
else if(last_6_cnt_en)
    last_6_cnt <= last_6_cnt + 3'd1;
else
    last_6_cnt <= 3'd0;
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        col0_buf  <= {DW_IN*4{1'b0}}; col1_buf  <= {DW_IN*4{1'b0}}; col2_buf  <= {DW_IN*4{1'b0}};
        col3_buf  <= {DW_IN*4{1'b0}}; col4_buf  <= {DW_IN*4{1'b0}}; col5_buf  <= {DW_IN*4{1'b0}};
        col_1_buf <= {DW_IN*4{1'b0}}; col_2_buf <= {DW_IN*4{1'b0}}; col_3_buf <= {DW_IN*4{1'b0}};
        col_4_buf <= {DW_IN*4{1'b0}}; col_5_buf <= {DW_IN*4{1'b0}}; col_6_buf <= {DW_IN*4{1'b0}};
    end
    else begin
    case(col_cnt)
        5'd0   : col0_buf <= data_in4;      
        5'd1   : col1_buf <= data_in4;
        5'd2   : col2_buf <= data_in4;
        5'd3   : col3_buf <= data_in4;
        5'd4   : col4_buf <= data_in4;
        5'd5   : col5_buf <= data_in4;
        WIN_W-6: col_6_buf <= data_in4;
        WIN_W-5: col_5_buf <= data_in4;
        WIN_W-4: col_4_buf <= data_in4;
        WIN_W-3: col_3_buf <= data_in4;
        WIN_W-2: col_2_buf <= data_in4;
        WIN_W-1: col_1_buf <= data_in4;
    endcase
    end
end

//counter logic and hsync posedge 
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    hsync_d1 <= 1'b0;
else
    hsync_d1 <= hsync_in;
end

assign hsync_pos        = hsync_in && (~hsync_d1);
assign array_load_start = hsync_in && (col_cnt=={COL_CNT_WIDTH{1'b0}});

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    col_cnt <= {COL_CNT_WIDTH{1'b0}};
else if(col_cnt == WIN_W-1)
    col_cnt <= {COL_CNT_WIDTH{1'b0}};
else if(hsync_in)
    col_cnt <= col_cnt + 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    row_cnt <= {ROW_CNT_WIDTH{1'b1}};
else if((row_cnt==WIN_H-1) && (col_cnt==WIN_W-1))
    row_cnt <= {ROW_CNT_WIDTH{1'b0}};
else if(hsync_pos)
    row_cnt <= row_cnt + 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    hb_cnt_en <= 1'b0;
else if(hb_cnt == HB-1)
    hb_cnt_en <= 1'b0;
else if(col_cnt == WIN_W-1)
    hb_cnt_en <= 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    hb_cnt <= {HB_CNT_WIDTH{1'b0}};
else if(hb_cnt_en)
    hb_cnt <= hb_cnt + 1'b1;
else
    hb_cnt <= {HB_CNT_WIDTH{1'b0}};
end

assign row_cnt_comb = (hsync_pos)? (row_cnt+1'b1):row_cnt; 
assign filter_start = (col_cnt==IMCORW_DELAY+6);
assign filter_end   = (hb_cnt ==6'd1          );

//array_flow_en is sram_flow_rd_req delay 2clk
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sram_flow_rd_req_d1 <= 1'b0;
else
    sram_flow_rd_req_d1 <= sram_flow_rd_req;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_flow_en <= 1'b0;
else
    array_flow_en <= sram_flow_rd_req_d1;
end

assign wb_en = (col_cnt>=6 && col_cnt<WIN_W-6);

// 1clk generate data_out
wb_gain U_wb_gain4(
    .clk      (clk      ),
    .rst_n    (rst_n    ),
                         
    .CFA      (2'b01    ),
                         
    .wb_en    (wb_en    ),
    .vsync_in (vsync_in ),
    .hsync_in (hsync_in ),
    .data_in  (data_in4 ),
                         
    .R_gain   ({2'b01, 8'b11101010}),
    .G_gain   ({2'b01, 8'b00000000}),
    .B_gain   ({2'b10, 8'b00011001}),
                         
    .hsync_out(wb_gain_hsync_out4),
    .vsync_out(wb_gain_vsync_out4),
    .data_out (wb_gain_data_out4 ) 
);

//5 clks get the result
imcorw_mixrb_calc U_imcorw_mixrb_calc4(
    .clk         (clk                    ),
    .rst_n       (rst_n                  ),
                                          
    .CFA         (2'b01                  ),
                               
    .vsync       (wb_gain_vsync_out4     ),
    .hsync       (wb_gain_hsync_out4     ),
                               
    .data_in     (wb_gain_data_out4      ),
    .hsync_out   (imcorw_mixrb_hsync_out4),
    .imcorw_mixrb(imcorw_mixrb4          )
);

// 1clk generate data_out
wb_gain U_wb_gain3(
    .clk      (clk      ),
    .rst_n    (rst_n    ),
                         
    .CFA      (2'b01    ),
                         
    .wb_en    (wb_en    ),
    .vsync_in (vsync_in ),
    .hsync_in (hsync_in ),
    .data_in  (data_in3 ),
                         
    .R_gain   ({2'b01, 8'b11101010}),
    .G_gain   ({2'b01, 8'b00000000}),
    .B_gain   ({2'b10, 8'b00011001}),
                         
    .hsync_out(wb_gain_hsync_out3),
    .vsync_out(wb_gain_vsync_out3),
    .data_out (wb_gain_data_out3 ) 
);

//5 clks get the result
imcorw_mixrb_calc U_imcorw_mixrb_calc3(
    .clk         (clk                    ),
    .rst_n       (rst_n                  ),
                                          
    .CFA         (2'b01                  ),
                               
    .vsync       (wb_gain_vsync_out3     ),
    .hsync       (wb_gain_hsync_out3     ),
                               
    .data_in     (wb_gain_data_out3      ),
    .hsync_out   (imcorw_mixrb_hsync_out3),
    .imcorw_mixrb(imcorw_mixrb3          )
);

// 1clk generate data_out
wb_gain U_wb_gain5(
    .clk      (clk      ),
    .rst_n    (rst_n    ),
                         
    .CFA      (2'b01    ),
                         
    .wb_en    (wb_en    ),
    .vsync_in (vsync_in ),
    .hsync_in (hsync_in ),
    .data_in  (data_in5 ),
                         
    .R_gain   ({2'b01, 8'b11101010}),
    .G_gain   ({2'b01, 8'b00000000}),
    .B_gain   ({2'b10, 8'b00011001}),
                         
    .hsync_out(wb_gain_hsync_out5),
    .vsync_out(wb_gain_vsync_out5),
    .data_out (wb_gain_data_out5 ) 
);

//5 clks get the result
imcorw_mixrb_calc U_imcorw_mixrb_calc5(
    .clk         (clk                    ),
    .rst_n       (rst_n                  ),
                                          
    .CFA         (2'b01                  ),
                               
    .vsync       (wb_gain_vsync_out5     ),
    .hsync       (wb_gain_hsync_out5     ),
                               
    .data_in     (wb_gain_data_out5      ),
    .hsync_out   (imcorw_mixrb_hsync_out5),
    .imcorw_mixrb(imcorw_mixrb5          )
);

average3x3 U_average3x3_0(
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .in1          (imcorw_mixrb3),
    .in2          (imcorw_mixrb4),
    .in3          (imcorw_mixrb5),
    .filter_start (filter_start ),
    .filter_end   (filter_end   ),
    .average_out  (imcorww      ),
    .average_valid(imcorww_valid)
);

assign imcinww = {{{(DW_IN-1-DW_DEC){1'b0}}, imcorww}, {{(DW_IN-1-DW_DEC){1'b0}}, imcorww}, 
                  {{(DW_IN-1-DW_DEC){1'b0}}, imcorww}, {{(DW_IN-1-DW_DEC){1'b0}}, imcorww}};

array_load #(
    .DW_IN        (DW_IN        ),
    .ROW_CNT_WIDTH(ROW_CNT_WIDTH),
    .COL_CNT_WIDTH(COL_CNT_WIDTH)
) U_array_load0(
    .clk    (clk         ),
    .rst_n  (rst_n       ),

    .row_cnt(row_cnt_comb),
    .col_cnt(col_cnt     ),

    .array_load_start(array_load_start),

    .data_in1(data_in1),
    .data_in2(data_in2),
    .data_in3(data_in3),
    .data_in4(data_in4),
    .data_in5(data_in5),
    .data_in6(data_in6),
    .data_in7(data_in7),

    .imo_replace_line1_7 (imo_replace_line1_7 ), .imo_replace_line1_8 (imo_replace_line1_8 ), .imo_replace_line1_9 (imo_replace_line1_9 ), .imo_replace_line1_10(imo_replace_line1_10),
    .imo_replace_line1_11(imo_replace_line1_11), .imo_replace_line1_12(imo_replace_line1_12), .imo_replace_line1_13(imo_replace_line1_13),
                                                                                                                                        
    .imo_replace_line2_7 (imo_replace_line2_7 ), .imo_replace_line2_8 (imo_replace_line2_8 ), .imo_replace_line2_9 (imo_replace_line2_9 ), .imo_replace_line2_10(imo_replace_line2_10),
    .imo_replace_line2_11(imo_replace_line2_11), .imo_replace_line2_12(imo_replace_line2_12), .imo_replace_line2_13(imo_replace_line2_13),
                                                                                                                                        
    .imo_replace_line3_7 (imo_replace_line3_7 ), .imo_replace_line3_8 (imo_replace_line3_8 ), .imo_replace_line3_9 (imo_replace_line3_9 ), .imo_replace_line3_10(imo_replace_line3_10),
    .imo_replace_line3_11(imo_replace_line3_11), .imo_replace_line3_12(imo_replace_line3_12), .imo_replace_line3_13(imo_replace_line3_13),

    .array_load_done(array_load_done),

    .row1_buf1(row1_buf1), .row1_buf2(row1_buf2), .row1_buf3 (row1_buf3 ), .row1_buf4 (row1_buf4 ), .row1_buf5 (row1_buf5 ), .row1_buf6 (row1_buf6 ), .row1_buf7(row1_buf7),
    .row1_buf8(row1_buf8), .row1_buf9(row1_buf9), .row1_buf10(row1_buf10), .row1_buf11(row1_buf11), .row1_buf12(row1_buf12), .row1_buf13(row1_buf13),                     
                                                                                                                                                                          
    .row2_buf1(row2_buf1), .row2_buf2(row2_buf2), .row2_buf3 (row2_buf3 ), .row2_buf4 (row2_buf4 ), .row2_buf5 (row2_buf5 ), .row2_buf6 (row2_buf6 ), .row2_buf7(row2_buf7),
    .row2_buf8(row2_buf8), .row2_buf9(row2_buf9), .row2_buf10(row2_buf10), .row2_buf11(row2_buf11), .row2_buf12(row2_buf12), .row2_buf13(row2_buf13),                     
                                                                                                                                                                          
    .row3_buf1(row3_buf1), .row3_buf2(row3_buf2), .row3_buf3 (row3_buf3 ), .row3_buf4 (row3_buf4 ), .row3_buf5 (row3_buf5 ), .row3_buf6 (row3_buf6 ), .row3_buf7(row3_buf7),
    .row3_buf8(row3_buf8), .row3_buf9(row3_buf9), .row3_buf10(row3_buf10), .row3_buf11(row3_buf11), .row3_buf12(row3_buf12), .row3_buf13(row3_buf13),                     
                                                                                                                                                                          
    .row4_buf1(row4_buf1), .row4_buf2(row4_buf2), .row4_buf3 (row4_buf3 ), .row4_buf4 (row4_buf4 ), .row4_buf5 (row4_buf5 ), .row4_buf6 (row4_buf6 ), .row4_buf7(row4_buf7),
    .row4_buf8(row4_buf8), .row4_buf9(row4_buf9), .row4_buf10(row4_buf10), .row4_buf11(row4_buf11), .row4_buf12(row4_buf12), .row4_buf13(row4_buf13),                     
                                                                                                                                                                          
    .row5_buf1(row5_buf1), .row5_buf2(row5_buf2), .row5_buf3 (row5_buf3 ), .row5_buf4 (row5_buf4 ), .row5_buf5 (row5_buf5 ), .row5_buf6 (row5_buf6 ), .row5_buf7(row5_buf7),
    .row5_buf8(row5_buf8), .row5_buf9(row5_buf9), .row5_buf10(row5_buf10), .row5_buf11(row5_buf11), .row5_buf12(row5_buf12), .row5_buf13(row5_buf13),                     
                                                                                                                                                                          
    .row6_buf1(row6_buf1), .row6_buf2(row6_buf2), .row6_buf3 (row6_buf3 ), .row6_buf4 (row6_buf4 ), .row6_buf5 (row6_buf5 ), .row6_buf6 (row6_buf6 ), .row6_buf7(row6_buf7),
    .row6_buf8(row6_buf8), .row6_buf9(row6_buf9), .row6_buf10(row6_buf10), .row6_buf11(row6_buf11), .row6_buf12(row6_buf12), .row6_buf13(row6_buf13),                     
                                                                                                                                                                          
    .row7_buf1(row7_buf1), .row7_buf2(row7_buf2), .row7_buf3 (row7_buf3 ), .row7_buf4 (row7_buf4 ), .row7_buf5 (row7_buf5 ), .row7_buf6 (row7_buf6 ), .row7_buf7(row7_buf7),
    .row7_buf8(row7_buf8), .row7_buf9(row7_buf9), .row7_buf10(row7_buf10), .row7_buf11(row7_buf11), .row7_buf12(row7_buf12), .row7_buf13(row7_buf13)
);

array_flow #(
    .WIN_W        (WIN_W        ),
    .DW_IN        (DW_IN        ),
    .ROW_CNT_WIDTH(ROW_CNT_WIDTH),
    .COL_CNT_WIDTH(COL_CNT_WIDTH),
    .HB_CNT_WIDTH (HB_CNT_WIDTH )
)U_array_flow0(
    .clk  (clk  ),
    .rst_n(rst_n),

    .row_cnt  (row_cnt_comb),
    .col_cnt  (col_cnt     ),
    .hb_cnt   (hb_cnt      ),
    .hb_cnt_en(hb_cnt_en   ),

    .array_load_done(array_load_done),

    .array_flow_en(array_flow_en),

    .data_in1(data_in1),
    .data_in2(data_in2),
    .data_in3(data_in3),
    .data_in4(data_in4),
    .data_in5(data_in5),
    .data_in6(data_in6),
    .data_in7(data_in7),

    .imo_replace_line1_in(imo_replace_line1_in_reg),    
    .imo_replace_line2_in(imo_replace_line2_in_reg),
    .imo_replace_line3_in(imo_replace_line3_in_reg),

    .row1_buf1(row1_buf1), .row1_buf2(row1_buf2), .row1_buf3 (row1_buf3 ), .row1_buf4 (row1_buf4 ), .row1_buf5 (row1_buf5 ), .row1_buf6 (row1_buf6 ), .row1_buf7(row1_buf7),
    .row1_buf8(row1_buf8), .row1_buf9(row1_buf9), .row1_buf10(row1_buf10), .row1_buf11(row1_buf11), .row1_buf12(row1_buf12), .row1_buf13(row1_buf13),                     
                                                                                                                                                                          
    .row2_buf1(row2_buf1), .row2_buf2(row2_buf2), .row2_buf3 (row2_buf3 ), .row2_buf4 (row2_buf4 ), .row2_buf5 (row2_buf5 ), .row2_buf6 (row2_buf6 ), .row2_buf7(row2_buf7),
    .row2_buf8(row2_buf8), .row2_buf9(row2_buf9), .row2_buf10(row2_buf10), .row2_buf11(row2_buf11), .row2_buf12(row2_buf12), .row2_buf13(row2_buf13),                     
                                                                                                                                                                          
    .row3_buf1(row3_buf1), .row3_buf2(row3_buf2), .row3_buf3 (row3_buf3 ), .row3_buf4 (row3_buf4 ), .row3_buf5 (row3_buf5 ), .row3_buf6 (row3_buf6 ), .row3_buf7(row3_buf7),
    .row3_buf8(row3_buf8), .row3_buf9(row3_buf9), .row3_buf10(row3_buf10), .row3_buf11(row3_buf11), .row3_buf12(row3_buf12), .row3_buf13(row3_buf13),                     
                                                                                                                                                                          
    .row4_buf1(row4_buf1), .row4_buf2(row4_buf2), .row4_buf3 (row4_buf3 ), .row4_buf4 (row4_buf4 ), .row4_buf5 (row4_buf5 ), .row4_buf6 (row4_buf6 ), .row4_buf7(row4_buf7),
    .row4_buf8(row4_buf8), .row4_buf9(row4_buf9), .row4_buf10(row4_buf10), .row4_buf11(row4_buf11), .row4_buf12(row4_buf12), .row4_buf13(row4_buf13),                     
                                                                                                                                                                          
    .row5_buf1(row5_buf1), .row5_buf2(row5_buf2), .row5_buf3 (row5_buf3 ), .row5_buf4 (row5_buf4 ), .row5_buf5 (row5_buf5 ), .row5_buf6 (row5_buf6 ), .row5_buf7(row5_buf7),
    .row5_buf8(row5_buf8), .row5_buf9(row5_buf9), .row5_buf10(row5_buf10), .row5_buf11(row5_buf11), .row5_buf12(row5_buf12), .row5_buf13(row5_buf13),                     
                                                                                                                                                                          
    .row6_buf1(row6_buf1), .row6_buf2(row6_buf2), .row6_buf3 (row6_buf3 ), .row6_buf4 (row6_buf4 ), .row6_buf5 (row6_buf5 ), .row6_buf6 (row6_buf6 ), .row6_buf7(row6_buf7),
    .row6_buf8(row6_buf8), .row6_buf9(row6_buf9), .row6_buf10(row6_buf10), .row6_buf11(row6_buf11), .row6_buf12(row6_buf12), .row6_buf13(row6_buf13),                     
                                                                                                                                                                          
    .row7_buf1(row7_buf1), .row7_buf2(row7_buf2), .row7_buf3 (row7_buf3 ), .row7_buf4 (row7_buf4 ), .row7_buf5 (row7_buf5 ), .row7_buf6 (row7_buf6 ), .row7_buf7(row7_buf7),
    .row7_buf8(row7_buf8), .row7_buf9(row7_buf9), .row7_buf10(row7_buf10), .row7_buf11(row7_buf11), .row7_buf12(row7_buf12), .row7_buf13(row7_buf13),

    .imo4        (imo4        ),
    .imo4_valid  (imo4_valid  ),
    .imcin_d     (imcin_d1    ),
    .imosum_valid(imosum_valid),
    .imo1_valid  (imo1_valid  )
);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sram_imcinww_addr <= {COL_CNT_WIDTH{1'b0}};
else if(imcorww_valid || imo1_valid)
    sram_imcinww_addr <= sram_imcinww_addr + 1'b1;
else
    sram_imcinww_addr <= {COL_CNT_WIDTH{1'b0}};
end

always@(*) begin
if(imcorww_valid)
    sram_imcinww_cen = ~imcorww_valid;
else if(imo1_valid)
    sram_imcinww_cen = ~imo1_valid;
else
    sram_imcinww_cen = 1'b1;
end

always@(*) begin
if(imcorww_valid)
    sram_imcinww_wen = ~imcorww_valid;  
else if(imo1_valid)
    sram_imcinww_wen = 1'b1;
else    
    sram_imcinww_wen = 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
   sram_imcinww_rd_data_reg <= {(DW_IN*4){1'b0}};
else
   sram_imcinww_rd_data_reg <= sram_imcinww_rd_data;
end

SRAMSP_2336X40X1 U_SRAMSP_2336X40X1_IMCINWW(
    .CLK       (clk                                            ),
    .rst_n     (rst_n                                          ),
    .scan_mode (1'b0                                           ),
    .MBIST_en  (1'b0                                           ),
    .MBIST_DONE(                                               ),
    .MBIST_PASS(                                               ),
    .CEN       (sram_imcinww_cen                               ),
    .WEN       (sram_imcinww_wen                               ),
    .A         ({{(12-COL_CNT_WIDTH){1'b0}}, sram_imcinww_addr}),
    .D         (imcinww                                        ),
    .Q         (sram_imcinww_rd_data                           )
);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo5 <= {DW_IN*4{1'b0}};
else
    imo5 <= imo4;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo5_valid <= 1'b0;
else
    imo5_valid <= imo4_valid;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imcin_d2 <= {DW_IN*4{1'b0}};
else
    imcin_d2 <= imcin_d1;
end


assign imo6_1_tmp1 = imo5_valid? (imcin_d2[DW_IN*4-1:DW_IN*3]*sram_imcinww_rd_data_reg[DW_IN*4-2:DW_IN*3]):{(DW_IN+DW_DEC+1){1'b0}};
assign imo6_1_tmp2 = imo5_valid? (imo5[DW_IN*4-1:DW_IN*3]*(9'd256 - sram_imcinww_rd_data_reg[DW_IN*4-2:DW_IN*3])):{(DW_IN+DW_DEC+1){1'b0}};
assign imo6_1 = imo6_1_tmp1 + imo6_1_tmp2;

assign imo6_2_tmp1 = imo5_valid? (imcin_d2[DW_IN*3-1:DW_IN*2]*sram_imcinww_rd_data_reg[DW_IN*3-2:DW_IN*2]):{(DW_IN+DW_DEC+1){1'b0}};
assign imo6_2_tmp2 = imo5_valid? (imo5[DW_IN*3-1:DW_IN*2]*(9'd256 - sram_imcinww_rd_data_reg[DW_IN*3-2:DW_IN*2])):{(DW_IN+DW_DEC+1){1'b0}};
assign imo6_2 = imo6_2_tmp1 + imo6_2_tmp2;

assign imo6_3_tmp1 = imo5_valid? (imcin_d2[DW_IN*2-1:DW_IN]*sram_imcinww_rd_data_reg[DW_IN*2-2:DW_IN]):{(DW_IN+DW_DEC+1){1'b0}};
assign imo6_3_tmp2 = imo5_valid? (imo5[DW_IN*2-1:DW_IN]*(9'd256 - sram_imcinww_rd_data_reg[DW_IN*2-2:DW_IN])):{(DW_IN+DW_DEC+1){1'b0}};
assign imo6_3 = imo6_3_tmp1 + imo6_3_tmp2;

assign imo6_4_tmp1 = imo5_valid? (imcin_d2[DW_IN-1:0]*sram_imcinww_rd_data_reg[DW_IN-2:0]):{(DW_IN+DW_DEC+1){1'b0}};
assign imo6_4_tmp2 = imo5_valid? (imo5[DW_IN-1:0]*(9'd256 - sram_imcinww_rd_data_reg[DW_IN-2:0])):{(DW_IN+DW_DEC+1){1'b0}};
assign imo6_4 = imo6_4_tmp1 + imo6_4_tmp2;

assign imo6_1_clamp = ((&imo6_1[DW_DEC+9:DW_DEC]) || (imo6_1[DW_DEC-1]==1'b0))? 
                      (imo6_1[DW_DEC+9:DW_DEC]):(imo6_1[DW_DEC+9:DW_DEC]+1'b1);
assign imo6_2_clamp = ((&imo6_2[DW_DEC+9:DW_DEC]) || (imo6_2[DW_DEC-1]==1'b0))?
                      (imo6_2[DW_DEC+9:DW_DEC]):(imo6_2[DW_DEC+9:DW_DEC]+1'b1);
assign imo6_3_clamp = ((&imo6_3[DW_DEC+9:DW_DEC]) || (imo6_3[DW_DEC-1]==1'b0))? 
                      (imo6_3[DW_DEC+9:DW_DEC]):(imo6_3[DW_DEC+9:DW_DEC]+1'b1);  
assign imo6_4_clamp = ((&imo6_4[DW_DEC+9:DW_DEC]) || (imo6_4[DW_DEC-1]==1'b0))? 
                      (imo6_4[DW_DEC+9:DW_DEC]):(imo6_4[DW_DEC+9:DW_DEC]+1'b1);    

assign hsync_out_tmp = first_6_cnt_en || imo5_valid || last_6_cnt_en;                      

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo <= {DW_IN*4{1'b0}};
else if(first_6_cnt_en) begin
    case(first_6_cnt)
        3'd0: imo <= col0_buf;
        3'd1: imo <= col1_buf;
        3'd2: imo <= col2_buf;
        3'd3: imo <= col3_buf;
        3'd4: imo <= col4_buf;
        3'd5: imo <= col5_buf;
    endcase
    end
else if(imo5_valid)
    imo <= {imo6_1_clamp, imo6_2_clamp, imo6_3_clamp, imo6_4_clamp};
else if(last_6_cnt_en) begin
    case(last_6_cnt)
        3'd0: imo <= col_6_buf;
        3'd1: imo <= col_5_buf;
        3'd2: imo <= col_4_buf;
        3'd3: imo <= col_3_buf;
        3'd4: imo <= col_2_buf;
        3'd5: imo <= col_1_buf;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    hsync_out <= 1'b0;
else
    hsync_out <= hsync_out_tmp;
end

sram_ctrl U_sram_ctrl0(
    .clk                 (clk                 ),
    .rst_n               (rst_n               ),
    .row_cnt             (row_cnt_comb        ),
    .col_cnt             (col_cnt             ),
    .hb_cnt              (hb_cnt              ),
    .hsync_out           (hsync_out           ),
    .imo                 (imo                 ),
                                               
    .sram1_cen           (sram1_cen           ),
    .sram1_wen           (sram1_wen           ),
    .sram1_addr          (sram1_addr          ),
    .sram2_cen           (sram2_cen           ),
    .sram2_wen           (sram2_wen           ),
    .sram2_addr          (sram2_addr          ),
    .sram3_cen           (sram3_cen           ),
    .sram3_wen           (sram3_wen           ),
    .sram3_addr          (sram3_addr          ),
    .sram4_cen           (sram4_cen           ),
    .sram4_wen           (sram4_wen           ),
    .sram4_addr          (sram4_addr          ),
    .sram1_wr_data       (sram1_wr_data       ),
    .sram2_wr_data       (sram2_wr_data       ),
    .sram3_wr_data       (sram3_wr_data       ),
    .sram4_wr_data       (sram4_wr_data       ),
    .sram_prefetch_rd_req(sram_prefetch_rd_req),
    .sram_flow_rd_req    (sram_flow_rd_req    ),
    .wr_addr             (wr_addr             ),
    .prefetch_addr       (prefetch_addr       ),
    .rd_addr             (rd_addr             )
);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sram_prefetch_rd_req_d1 <= 1'b0;
else
    sram_prefetch_rd_req_d1 <= sram_prefetch_rd_req;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line1_7 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && row_cnt_comb!=4'd1 && prefetch_addr==12'd7) begin
    case(row_cnt_comb[1:0])
        2'b10: imo_replace_line1_7 <= sram1_rd_data;
        2'b11: imo_replace_line1_7 <= sram2_rd_data;
        2'b00: imo_replace_line1_7 <= sram3_rd_data;
        2'b01: imo_replace_line1_7 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line1_8 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && row_cnt_comb!=4'd1 && prefetch_addr==12'd8) begin
    case(row_cnt_comb[1:0])
        2'b10: imo_replace_line1_8 <= sram1_rd_data;
        2'b11: imo_replace_line1_8 <= sram2_rd_data;
        2'b00: imo_replace_line1_8 <= sram3_rd_data;
        2'b01: imo_replace_line1_8 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line1_9 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && row_cnt_comb!=4'd1 && prefetch_addr==12'd9) begin
    case(row_cnt_comb[1:0])
        2'b10: imo_replace_line1_9 <= sram1_rd_data;
        2'b11: imo_replace_line1_9 <= sram2_rd_data;
        2'b00: imo_replace_line1_9 <= sram3_rd_data;
        2'b01: imo_replace_line1_9 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line1_10 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && row_cnt_comb!=4'd1 && prefetch_addr==12'd10) begin
    case(row_cnt_comb[1:0])
        2'b10: imo_replace_line1_10 <= sram1_rd_data;
        2'b11: imo_replace_line1_10 <= sram2_rd_data;
        2'b00: imo_replace_line1_10 <= sram3_rd_data;
        2'b01: imo_replace_line1_10 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line1_11 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && row_cnt_comb!=4'd1 && prefetch_addr==12'd11) begin
    case(row_cnt_comb[1:0])
        2'b10: imo_replace_line1_11 <= sram1_rd_data;
        2'b11: imo_replace_line1_11 <= sram2_rd_data;
        2'b00: imo_replace_line1_11 <= sram3_rd_data;
        2'b01: imo_replace_line1_11 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line1_12 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && row_cnt_comb!=4'd1 && prefetch_addr==12'd12) begin
    case(row_cnt_comb[1:0])
        2'b10: imo_replace_line1_12 <= sram1_rd_data;
        2'b11: imo_replace_line1_12 <= sram2_rd_data;
        2'b00: imo_replace_line1_12 <= sram3_rd_data;
        2'b01: imo_replace_line1_12 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line1_13 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && row_cnt_comb!=4'd1 && prefetch_addr==12'd13) begin
    case(row_cnt_comb[1:0])
        2'b10: imo_replace_line1_13 <= sram1_rd_data;
        2'b11: imo_replace_line1_13 <= sram2_rd_data;
        2'b00: imo_replace_line1_13 <= sram3_rd_data;
        2'b01: imo_replace_line1_13 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line2_7 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && prefetch_addr==12'd7) begin
    case(row_cnt_comb[1:0])
        2'b01: imo_replace_line2_7 <= sram1_rd_data;
        2'b10: imo_replace_line2_7 <= sram2_rd_data;
        2'b11: imo_replace_line2_7 <= sram3_rd_data;
        2'b00: imo_replace_line2_7 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line2_8 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && prefetch_addr==12'd8) begin
    case(row_cnt_comb[1:0])
        2'b01: imo_replace_line2_8 <= sram1_rd_data;
        2'b10: imo_replace_line2_8 <= sram2_rd_data;
        2'b11: imo_replace_line2_8 <= sram3_rd_data;
        2'b00: imo_replace_line2_8 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line2_9 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && prefetch_addr==12'd9) begin
    case(row_cnt_comb[1:0])
        2'b01: imo_replace_line2_9 <= sram1_rd_data;
        2'b10: imo_replace_line2_9 <= sram2_rd_data;
        2'b11: imo_replace_line2_9 <= sram3_rd_data;
        2'b00: imo_replace_line2_9 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line2_10 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && prefetch_addr==12'd10) begin
    case(row_cnt_comb[1:0])
        2'b01: imo_replace_line2_10 <= sram1_rd_data;
        2'b10: imo_replace_line2_10 <= sram2_rd_data;
        2'b11: imo_replace_line2_10 <= sram3_rd_data;
        2'b00: imo_replace_line2_10 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line2_11 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && prefetch_addr==12'd11) begin
    case(row_cnt_comb[1:0])
        2'b01: imo_replace_line2_11 <= sram1_rd_data;
        2'b10: imo_replace_line2_11 <= sram2_rd_data;
        2'b11: imo_replace_line2_11 <= sram3_rd_data;
        2'b00: imo_replace_line2_11 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line2_12 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && prefetch_addr==12'd12) begin
    case(row_cnt_comb[1:0])
        2'b01: imo_replace_line2_12 <= sram1_rd_data;
        2'b10: imo_replace_line2_12 <= sram2_rd_data;
        2'b11: imo_replace_line2_12 <= sram3_rd_data;
        2'b00: imo_replace_line2_12 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line2_13 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && row_cnt_comb!=4'd0 && prefetch_addr==12'd13) begin
    case(row_cnt_comb[1:0])
        2'b01: imo_replace_line2_13 <= sram1_rd_data;
        2'b10: imo_replace_line2_13 <= sram2_rd_data;
        2'b11: imo_replace_line2_13 <= sram3_rd_data;
        2'b00: imo_replace_line2_13 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line3_7 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && prefetch_addr==12'd7) begin
    case(row_cnt_comb[1:0])
        2'b00: imo_replace_line3_7 <= sram1_rd_data;
        2'b01: imo_replace_line3_7 <= sram2_rd_data;
        2'b10: imo_replace_line3_7 <= sram3_rd_data;
        2'b11: imo_replace_line3_7 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line3_8 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && prefetch_addr==12'd8) begin
    case(row_cnt_comb[1:0])
        2'b00: imo_replace_line3_8 <= sram1_rd_data;
        2'b01: imo_replace_line3_8 <= sram2_rd_data;
        2'b10: imo_replace_line3_8 <= sram3_rd_data;
        2'b11: imo_replace_line3_8 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line3_9 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && prefetch_addr==12'd9) begin
    case(row_cnt_comb[1:0])
        2'b00: imo_replace_line3_9 <= sram1_rd_data;
        2'b01: imo_replace_line3_9 <= sram2_rd_data;
        2'b10: imo_replace_line3_9 <= sram3_rd_data;
        2'b11: imo_replace_line3_9 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line3_10 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && prefetch_addr==12'd10) begin
    case(row_cnt_comb[1:0])
        2'b00: imo_replace_line3_10 <= sram1_rd_data;
        2'b01: imo_replace_line3_10 <= sram2_rd_data;
        2'b10: imo_replace_line3_10 <= sram3_rd_data;
        2'b11: imo_replace_line3_10 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line3_11 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && prefetch_addr==12'd11) begin
    case(row_cnt_comb[1:0])
        2'b00: imo_replace_line3_11 <= sram1_rd_data;
        2'b01: imo_replace_line3_11 <= sram2_rd_data;
        2'b10: imo_replace_line3_11 <= sram3_rd_data;
        2'b11: imo_replace_line3_11 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line3_12 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && prefetch_addr==12'd12) begin
    case(row_cnt_comb[1:0])
        2'b00: imo_replace_line3_12 <= sram1_rd_data;
        2'b01: imo_replace_line3_12 <= sram2_rd_data;
        2'b10: imo_replace_line3_12 <= sram3_rd_data;
        2'b11: imo_replace_line3_12 <= sram4_rd_data;
    endcase
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_replace_line3_13 <= {DW_IN*4{1'b0}};
else if(sram_prefetch_rd_req_d1 && prefetch_addr==12'd13) begin
    case(row_cnt_comb[1:0])
        2'b00: imo_replace_line3_13 <= sram1_rd_data;
        2'b01: imo_replace_line3_13 <= sram2_rd_data;
        2'b10: imo_replace_line3_13 <= sram3_rd_data;
        2'b11: imo_replace_line3_13 <= sram4_rd_data;
    endcase
    end
end

always@(*) begin
    if(array_flow_en && row_cnt_comb!=4'd0 && row_cnt_comb!=4'd1 && row_cnt_comb!=4'd2) begin
    case(row_cnt_comb[1:0])
        2'b11: imo_replace_line1_in = sram1_rd_data;
        2'b00: imo_replace_line1_in = sram2_rd_data;
        2'b01: imo_replace_line1_in = sram3_rd_data;
        2'b10: imo_replace_line1_in = sram4_rd_data;
    endcase
    end
    else
        imo_replace_line1_in = {DW_IN*4{1'b0}};
end

always@(*) begin
    if(array_flow_en && row_cnt_comb!=4'd0 && row_cnt_comb!=4'd1) begin
    case(row_cnt_comb[1:0])
        2'b10: imo_replace_line2_in = sram1_rd_data;
        2'b11: imo_replace_line2_in = sram2_rd_data;
        2'b00: imo_replace_line2_in = sram3_rd_data;
        2'b01: imo_replace_line2_in = sram4_rd_data;
    endcase
    end
    else
        imo_replace_line2_in = {DW_IN*4{1'b0}};
end

always@(*) begin
    if(array_flow_en && row_cnt_comb!=4'd0) begin
    case(row_cnt_comb[1:0])
        2'b01: imo_replace_line3_in = sram1_rd_data;
        2'b10: imo_replace_line3_in = sram2_rd_data;
        2'b11: imo_replace_line3_in = sram3_rd_data;
        2'b00: imo_replace_line3_in = sram4_rd_data;
    endcase
    end
    else
        imo_replace_line3_in = {DW_IN*4{1'b0}};
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        imo_replace_line1_in_reg <= {DW_IN*4{1'b0}};
        imo_replace_line2_in_reg <= {DW_IN*4{1'b0}};
        imo_replace_line3_in_reg <= {DW_IN*4{1'b0}};
    end
    else begin
        imo_replace_line1_in_reg <= imo_replace_line1_in;
        imo_replace_line2_in_reg <= imo_replace_line2_in;
        imo_replace_line3_in_reg <= imo_replace_line3_in;
    end
end

SRAMSP_2336X40X1 U_SRAMSP_2336X40X1_1(
    .CLK       (clk          ),
    .rst_n     (rst_n        ),
    .scan_mode (1'b0         ),
    .MBIST_en  (1'b0         ),
    .MBIST_DONE(             ),
    .MBIST_PASS(             ),
    .CEN       (sram1_cen    ),
    .WEN       (sram1_wen    ),
    .A         (sram1_addr   ),
    .D         (sram1_wr_data),
    .Q         (sram1_rd_data)
);

SRAMSP_2336X40X1 U_SRAMSP_2336X40X1_2(
    .CLK       (clk          ),
    .rst_n     (rst_n        ),
    .scan_mode (1'b0         ),
    .MBIST_en  (1'b0         ),
    .MBIST_DONE(             ),
    .MBIST_PASS(             ),
    .CEN       (sram2_cen    ),
    .WEN       (sram2_wen    ),
    .A         (sram2_addr   ),
    .D         (sram2_wr_data),
    .Q         (sram2_rd_data)
);

SRAMSP_2336X40X1 U_SRAMSP_2336X40X1_3(
    .CLK       (clk          ),
    .rst_n     (rst_n        ),
    .scan_mode (1'b0         ),
    .MBIST_en  (1'b0         ),
    .MBIST_DONE(             ),
    .MBIST_PASS(             ),
    .CEN       (sram3_cen    ),
    .WEN       (sram3_wen    ),
    .A         (sram3_addr   ),
    .D         (sram3_wr_data),
    .Q         (sram3_rd_data)
);

SRAMSP_2336X40X1 U_SRAMSP_2336X40X1_4(
    .CLK       (clk          ),
    .rst_n     (rst_n        ),
    .scan_mode (1'b0         ),
    .MBIST_en  (1'b0         ),
    .MBIST_DONE(             ),
    .MBIST_PASS(             ),
    .CEN       (sram4_cen    ),
    .WEN       (sram4_wen    ),
    .A         (sram4_addr   ),
    .D         (sram4_wr_data),
    .Q         (sram4_rd_data)
);

endmodule
