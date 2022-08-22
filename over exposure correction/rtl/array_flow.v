module array_flow #(
    parameter WIN_W         = 26,
    parameter DW_IN         = 10,
    parameter DW_DEC        = 8 ,
    parameter ROW_CNT_WIDTH = 4 ,
    parameter COL_CNT_WIDTH = 5 ,
    parameter HB_CNT_WIDTH  = 6 
)(
    input                     clk                 ,
    input                     rst_n               ,

    input [ROW_CNT_WIDTH-1:0] row_cnt             ,
    input [COL_CNT_WIDTH-1:0] col_cnt             ,
    input [HB_CNT_WIDTH-1 :0] hb_cnt              ,

    input                     hb_cnt_en           ,

    input                     array_load_done     ,

    input                     array_flow_en       ,

    input [DW_IN*4-1:0]       data_in1            ,
    input [DW_IN*4-1:0]       data_in2            ,
    input [DW_IN*4-1:0]       data_in3            ,
    input [DW_IN*4-1:0]       data_in4            ,
    input [DW_IN*4-1:0]       data_in5            ,
    input [DW_IN*4-1:0]       data_in6            ,
    input [DW_IN*4-1:0]       data_in7            ,

    input [DW_IN*4-1:0]       imo_replace_line1_in,
    input [DW_IN*4-1:0]       imo_replace_line2_in,
    input [DW_IN*4-1:0]       imo_replace_line3_in,

    // data from array_load
    input [DW_IN*4-1:0]  row1_buf1, row1_buf2, row1_buf3 , row1_buf4 , row1_buf5 , row1_buf6 , row1_buf7, 
    input [DW_IN*4-1:0]  row1_buf8, row1_buf9, row1_buf10, row1_buf11, row1_buf12, row1_buf13,

    input [DW_IN*4-1:0]  row2_buf1, row2_buf2, row2_buf3 , row2_buf4 , row2_buf5 , row2_buf6 , row2_buf7, 
    input [DW_IN*4-1:0]  row2_buf8, row2_buf9, row2_buf10, row2_buf11, row2_buf12, row2_buf13,

    input [DW_IN*4-1:0]  row3_buf1, row3_buf2, row3_buf3 , row3_buf4 , row3_buf5 , row3_buf6 , row3_buf7, 
    input [DW_IN*4-1:0]  row3_buf8, row3_buf9, row3_buf10, row3_buf11, row3_buf12, row3_buf13,

    input [DW_IN*4-1:0]  row4_buf1, row4_buf2, row4_buf3 , row4_buf4 , row4_buf5 , row4_buf6 , row4_buf7, 
    input [DW_IN*4-1:0]  row4_buf8, row4_buf9, row4_buf10, row4_buf11, row4_buf12, row4_buf13,

    input [DW_IN*4-1:0]  row5_buf1, row5_buf2, row5_buf3 , row5_buf4 , row5_buf5 , row5_buf6 , row5_buf7, 
    input [DW_IN*4-1:0]  row5_buf8, row5_buf9, row5_buf10, row5_buf11, row5_buf12, row5_buf13,

    input [DW_IN*4-1:0]  row6_buf1, row6_buf2, row6_buf3 , row6_buf4 , row6_buf5 , row6_buf6 , row6_buf7, 
    input [DW_IN*4-1:0]  row6_buf8, row6_buf9, row6_buf10, row6_buf11, row6_buf12, row6_buf13,

    input [DW_IN*4-1:0]  row7_buf1, row7_buf2, row7_buf3 , row7_buf4 , row7_buf5 , row7_buf6 , row7_buf7,
    input [DW_IN*4-1:0]  row7_buf8, row7_buf9, row7_buf10, row7_buf11, row7_buf12, row7_buf13,

    output [DW_IN*4-1:0] imo4        ,
    output               imo4_valid  ,
    output [DW_IN*4-1:0] imcin_d     ,
    output               imosum_valid,
    output               imo1_valid  
);

reg [DW_IN*4-1:0] data_in1_buf, data_in2_buf, data_in3_buf, data_in4_buf, data_in5_buf, data_in6_buf, data_in7_buf;

//the mask array
reg [DW_IN*4-1:0]  array1_1, array1_2,  array1_3,  array1_4,  array1_5,  array1_6, array1_7; 
reg [DW_IN*4-1:0]  array1_8, array1_9, array1_10, array1_11, array1_12, array1_13;
                      
reg [DW_IN*4-1:0]  array2_1, array2_2,  array2_3,  array2_4,  array2_5,  array2_6, array2_7; 
reg [DW_IN*4-1:0]  array2_8, array2_9, array2_10, array2_11, array2_12, array2_13;
                          
reg [DW_IN*4-1:0]  array3_1, array3_2,  array3_3,  array3_4,  array3_5,  array3_6, array3_7; 
reg [DW_IN*4-1:0]  array3_8, array3_9, array3_10, array3_11, array3_12, array3_13;
                          
reg [DW_IN*4-1:0]  array4_1, array4_2,  array4_3,  array4_4,  array4_5,  array4_6, array4_7; 
reg [DW_IN*4-1:0]  array4_8, array4_9, array4_10, array4_11, array4_12, array4_13;
                        
reg [DW_IN*4-1:0]  array5_1, array5_2,  array5_3,  array5_4,  array5_5,  array5_6, array5_7; 
reg [DW_IN*4-1:0]  array5_8, array5_9, array5_10, array5_11, array5_12, array5_13;
                       
reg [DW_IN*4-1:0]  array6_1, array6_2,  array6_3,  array6_4,  array6_5,  array6_6, array6_7; 
reg [DW_IN*4-1:0]  array6_8, array6_9, array6_10, array6_11, array6_12, array6_13;
                       
reg [DW_IN*4-1:0]  array7_1, array7_2,  array7_3,  array7_4,  array7_5,  array7_6, array7_7;
reg [DW_IN*4-1:0]  array7_8, array7_9, array7_10, array7_11, array7_12, array7_13;

wire               array_calc_en;
wire [DW_IN*4-1:0] imo3         ;
wire               imo3_valid   ;
wire [DW_DEC   :0] m_d          ;

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        data_in1_buf <= {DW_IN*4{1'b0}};
        data_in2_buf <= {DW_IN*4{1'b0}};
        data_in3_buf <= {DW_IN*4{1'b0}};
        data_in4_buf <= {DW_IN*4{1'b0}};
        data_in5_buf <= {DW_IN*4{1'b0}};
        data_in6_buf <= {DW_IN*4{1'b0}};
        data_in7_buf <= {DW_IN*4{1'b0}};
    end
    else if(array_load_done || (col_cnt>=5'd14 && col_cnt<=WIN_W-1)) begin
        data_in1_buf <= data_in1;
        data_in2_buf <= data_in2;
        data_in3_buf <= data_in3;
        data_in4_buf <= data_in4;
        data_in5_buf <= data_in5;
        data_in6_buf <= data_in6;
        data_in7_buf <= data_in7;        
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        array4_1 <= {DW_IN*4{1'b0}}; array4_2  <= {DW_IN*4{1'b0}}; array4_3  <= {DW_IN*4{1'b0}}; array4_4  <= {DW_IN*4{1'b0}};
        array4_5 <= {DW_IN*4{1'b0}}; array4_6  <= {DW_IN*4{1'b0}}; array4_7  <= {DW_IN*4{1'b0}}; array4_8  <= {DW_IN*4{1'b0}};
        array4_9 <= {DW_IN*4{1'b0}}; array4_10 <= {DW_IN*4{1'b0}}; array4_11 <= {DW_IN*4{1'b0}}; array4_12 <= {DW_IN*4{1'b0}}; array4_13 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_done) begin
        array4_1 <= row4_buf1; array4_2  <= row4_buf2 ; array4_3  <= row4_buf3 ; array4_4  <= row4_buf4 ;
        array4_5 <= row4_buf5; array4_6  <= row4_buf6 ; array4_7  <= row4_buf7 ; array4_8  <= row4_buf8 ;
        array4_9 <= row4_buf9; array4_10 <= row4_buf10; array4_11 <= row4_buf11; array4_12 <= row4_buf12; array4_13 <= row4_buf13;        
    end
    else if(array_flow_en) begin
        array4_1  <= array4_2; array4_2 <= array4_3; array4_3 <= array4_4 ; array4_4  <= array4_5 ; array4_5  <= array4_6 ; array4_6  <= array4_7 ;
        array4_7  <= array4_8; array4_8 <= array4_9; array4_9 <= array4_10; array4_10 <= array4_11; array4_11 <= array4_12; array4_12 <= array4_13;
        array4_13 <= data_in4_buf;
    end        
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        array5_1 <= {DW_IN*4{1'b0}}; array5_2  <= {DW_IN*4{1'b0}}; array5_3  <= {DW_IN*4{1'b0}}; array5_4  <= {DW_IN*4{1'b0}};
        array5_5 <= {DW_IN*4{1'b0}}; array5_6  <= {DW_IN*4{1'b0}}; array5_7  <= {DW_IN*4{1'b0}}; array5_8  <= {DW_IN*4{1'b0}};
        array5_9 <= {DW_IN*4{1'b0}}; array5_10 <= {DW_IN*4{1'b0}}; array5_11 <= {DW_IN*4{1'b0}}; array5_12 <= {DW_IN*4{1'b0}}; array5_13 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_done) begin
        array5_1 <= row5_buf1; array5_2  <= row5_buf2 ; array5_3  <= row5_buf3 ; array5_4  <= row5_buf4 ;
        array5_5 <= row5_buf5; array5_6  <= row5_buf6 ; array5_7  <= row5_buf7 ; array5_8  <= row5_buf8 ;
        array5_9 <= row5_buf9; array5_10 <= row5_buf10; array5_11 <= row5_buf11; array5_12 <= row5_buf12; array5_13 <= row5_buf13;        
    end
    else if(array_flow_en)begin
        array5_1  <= array5_2; array5_2 <= array5_3; array5_3 <= array5_4 ; array5_4  <= array5_5 ; array5_5  <= array5_6 ; array5_6  <= array5_7 ;
        array5_7  <= array5_8; array5_8 <= array5_9; array5_9 <= array5_10; array5_10 <= array5_11; array5_11 <= array5_12; array5_12 <= array5_13;
        array5_13 <= data_in5_buf;
    end        
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        array6_1 <= {DW_IN*4{1'b0}}; array6_2  <= {DW_IN*4{1'b0}}; array6_3  <= {DW_IN*4{1'b0}}; array6_4  <= {DW_IN*4{1'b0}};
        array6_5 <= {DW_IN*4{1'b0}}; array6_6  <= {DW_IN*4{1'b0}}; array6_7  <= {DW_IN*4{1'b0}}; array6_8  <= {DW_IN*4{1'b0}};
        array6_9 <= {DW_IN*4{1'b0}}; array6_10 <= {DW_IN*4{1'b0}}; array6_11 <= {DW_IN*4{1'b0}}; array6_12 <= {DW_IN*4{1'b0}}; array6_13 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_done) begin
        array6_1 <= row6_buf1; array6_2  <= row6_buf2 ; array6_3  <= row6_buf3 ; array6_4  <= row6_buf4 ;
        array6_5 <= row6_buf5; array6_6  <= row6_buf6 ; array6_7  <= row6_buf7 ; array6_8  <= row6_buf8 ;
        array6_9 <= row6_buf9; array6_10 <= row6_buf10; array6_11 <= row6_buf11; array6_12 <= row6_buf12; array6_13 <= row6_buf13;        
    end
    else if(array_flow_en) begin
        array6_1  <= array6_2; array6_2 <= array6_3; array6_3 <= array6_4 ; array6_4  <= array6_5 ; array6_5  <= array6_6 ; array6_6  <= array6_7 ;
        array6_7  <= array6_8; array6_8 <= array6_9; array6_9 <= array6_10; array6_10 <= array6_11; array6_11 <= array6_12; array6_12 <= array6_13;
        array6_13 <= data_in6_buf;
    end        
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        array7_1 <= {DW_IN*4{1'b0}}; array7_2  <= {DW_IN*4{1'b0}}; array7_3  <= {DW_IN*4{1'b0}}; array7_4  <= {DW_IN*4{1'b0}};
        array7_5 <= {DW_IN*4{1'b0}}; array7_6  <= {DW_IN*4{1'b0}}; array7_7  <= {DW_IN*4{1'b0}}; array7_8  <= {DW_IN*4{1'b0}};
        array7_9 <= {DW_IN*4{1'b0}}; array7_10 <= {DW_IN*4{1'b0}}; array7_11 <= {DW_IN*4{1'b0}}; array7_12 <= {DW_IN*4{1'b0}}; array7_13 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_done) begin
        array7_1 <= row7_buf1; array7_2  <= row7_buf2 ; array7_3  <= row7_buf3 ; array7_4  <= row7_buf4 ;
        array7_5 <= row7_buf5; array7_6  <= row7_buf6 ; array7_7  <= row7_buf7 ; array7_8  <= row7_buf8 ;
        array7_9 <= row7_buf9; array7_10 <= row7_buf10; array7_11 <= row7_buf11; array7_12 <= row7_buf12; array7_13 <= row7_buf13;        
    end
    else if(array_flow_en) begin
        array7_1  <= array7_2; array7_2 <= array7_3; array7_3 <= array7_4 ; array7_4  <= array7_5 ; array7_5  <= array7_6 ; array7_6  <= array7_7 ;
        array7_7  <= array7_8; array7_8 <= array7_9; array7_9 <= array7_10; array7_10 <= array7_11; array7_11 <= array7_12; array7_12 <= array7_13;
        array7_13 <= data_in7_buf;
    end        
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        array1_1 <= {DW_IN*4{1'b0}}; array1_2  <= {DW_IN*4{1'b0}}; array1_3  <= {DW_IN*4{1'b0}}; array1_4  <= {DW_IN*4{1'b0}};
        array1_5 <= {DW_IN*4{1'b0}}; array1_6  <= {DW_IN*4{1'b0}}; array1_7  <= {DW_IN*4{1'b0}}; array1_8  <= {DW_IN*4{1'b0}};
        array1_9 <= {DW_IN*4{1'b0}}; array1_10 <= {DW_IN*4{1'b0}}; array1_11 <= {DW_IN*4{1'b0}}; array1_12 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_done) begin
        array1_1 <= row1_buf1; array1_2  <= row1_buf2 ; array1_3  <= row1_buf3 ; array1_4  <= row1_buf4 ;
        array1_5 <= row1_buf5; array1_6  <= row1_buf6 ; array1_7  <= row1_buf7 ; array1_8  <= row1_buf8 ;
        array1_9 <= row1_buf9; array1_10 <= row1_buf10; array1_11 <= row1_buf11; array1_12 <= row1_buf12;        
    end
    else if(array_flow_en) begin
        array1_1  <= array1_2; array1_2 <= array1_3; array1_3 <= array1_4 ; array1_4  <= array1_5 ; array1_5  <= array1_6 ; array1_6  <= array1_7 ;
        array1_7  <= array1_8; array1_8 <= array1_9; array1_9 <= array1_10; array1_10 <= array1_11; array1_11 <= array1_12; array1_12 <= array1_13;
    end        
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array1_13 <= {DW_IN*4{1'b0}};
else if(array_load_done)
    array1_13 <= row1_buf13;
else if(array_flow_en) begin
    if(row_cnt >= 4'd3)
        array1_13 <= imo_replace_line1_in;
    else
        array1_13 <= data_in1_buf;
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        array2_1 <= {DW_IN*4{1'b0}}; array2_2  <= {DW_IN*4{1'b0}}; array2_3  <= {DW_IN*4{1'b0}}; array2_4  <= {DW_IN*4{1'b0}};
        array2_5 <= {DW_IN*4{1'b0}}; array2_6  <= {DW_IN*4{1'b0}}; array2_7  <= {DW_IN*4{1'b0}}; array2_8  <= {DW_IN*4{1'b0}};
        array2_9 <= {DW_IN*4{1'b0}}; array2_10 <= {DW_IN*4{1'b0}}; array2_11 <= {DW_IN*4{1'b0}}; array2_12 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_done) begin
        array2_1 <= row2_buf1; array2_2  <= row2_buf2 ; array2_3  <= row2_buf3 ; array2_4  <= row2_buf4 ;
        array2_5 <= row2_buf5; array2_6  <= row2_buf6 ; array2_7  <= row2_buf7 ; array2_8  <= row2_buf8 ;
        array2_9 <= row2_buf9; array2_10 <= row2_buf10; array2_11 <= row2_buf11; array2_12 <= row2_buf12;        
    end
    else if(array_flow_en) begin
        array2_1  <= array2_2; array2_2 <= array2_3; array2_3 <= array2_4 ; array2_4  <= array2_5 ; array2_5  <= array2_6 ; array2_6  <= array2_7 ;
        array2_7  <= array2_8; array2_8 <= array2_9; array2_9 <= array2_10; array2_10 <= array2_11; array2_11 <= array2_12; array2_12 <= array2_13;
    end        
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array2_13 <= {DW_IN*4{1'b0}};
else if(array_load_done)
    array2_13 <= row2_buf13;
else if(array_flow_en) begin
    if(row_cnt >= 4'd2)
        array2_13 <= imo_replace_line2_in;
    else
        array2_13 <= data_in2_buf;
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        array3_1 <= {DW_IN*4{1'b0}}; array3_2  <= {DW_IN*4{1'b0}}; array3_3  <= {DW_IN*4{1'b0}}; array3_4  <= {DW_IN*4{1'b0}};
        array3_5 <= {DW_IN*4{1'b0}}; array3_6  <= {DW_IN*4{1'b0}}; array3_7  <= {DW_IN*4{1'b0}}; array3_8  <= {DW_IN*4{1'b0}};
        array3_9 <= {DW_IN*4{1'b0}}; array3_10 <= {DW_IN*4{1'b0}}; array3_11 <= {DW_IN*4{1'b0}}; array3_12 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_done) begin
        array3_1 <= row3_buf1; array3_2  <= row3_buf2 ; array3_3  <= row3_buf3 ; array3_4  <= row3_buf4 ;
        array3_5 <= row3_buf5; array3_6  <= row3_buf6 ; array3_7  <= row3_buf7 ; array3_8  <= row3_buf8 ;
        array3_9 <= row3_buf9; array3_10 <= row3_buf10; array3_11 <= row3_buf11; array3_12 <= row3_buf12;        
    end
    else if(array_flow_en) begin
        array3_1  <= array3_2; array3_2 <= array3_3; array3_3 <= array3_4 ; array3_4  <= array3_5 ; array3_5  <= array3_6 ; array3_6  <= array3_7 ;
        array3_7  <= array3_8; array3_8 <= array3_9; array3_9 <= array3_10; array3_10 <= array3_11; array3_11 <= array3_12; array3_12 <= array3_13;
    end        
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array3_13 <= {DW_IN*4{1'b0}};
else if(array_load_done)
    array3_13 <= row3_buf13;
else if(array_flow_en) begin
    if(row_cnt >= 4'd1)
        array3_13 <= imo_replace_line3_in;
    else
        array3_13 <= data_in3_buf;
    end
end

assign array_calc_en = (col_cnt>=5'd14) || (hb_cnt_en && hb_cnt<=6'd1);

array_calc U_array_calc0(
    .clk(clk),
    .rst_n(rst_n),

    .row_cnt(row_cnt),
    .col_cnt(col_cnt),

    .array_calc_en(array_calc_en),

    .array1_1(array1_1), .array1_2(array1_2), .array1_3 (array1_3 ), .array1_4 (array1_4 ), .array1_5 (array1_5 ), .array1_6 (array1_6 ), .array1_7(array1_7),
    .array1_8(array1_8), .array1_9(array1_9), .array1_10(array1_10), .array1_11(array1_11), .array1_12(array1_12), .array1_13(array1_13),                   
                                                                                                                                                            
    .array2_1(array2_1), .array2_2(array2_2), .array2_3 (array2_3 ), .array2_4 (array2_4 ), .array2_5 (array2_5 ), .array2_6 (array2_6 ), .array2_7(array2_7),
    .array2_8(array2_8), .array2_9(array2_9), .array2_10(array2_10), .array2_11(array2_11), .array2_12(array2_12), .array2_13(array2_13),                   
                                                                                                                                                            
    .array3_1(array3_1), .array3_2(array3_2), .array3_3 (array3_3 ), .array3_4 (array3_4 ), .array3_5 (array3_5 ), .array3_6 (array3_6 ), .array3_7(array3_7),
    .array3_8(array3_8), .array3_9(array3_9), .array3_10(array3_10), .array3_11(array3_11), .array3_12(array3_12), .array3_13(array3_13),                   
                                                                                                                                                            
    .array4_1(array4_1), .array4_2(array4_2), .array4_3 (array4_3 ), .array4_4 (array4_4 ), .array4_5 (array4_5 ), .array4_6 (array4_6 ), .array4_7(array4_7),
    .array4_8(array4_8), .array4_9(array4_9), .array4_10(array4_10), .array4_11(array4_11), .array4_12(array4_12), .array4_13(array4_13),                   
                                                                                                                                                            
    .array5_1(array5_1), .array5_2(array5_2), .array5_3 (array5_3 ), .array5_4 (array5_4 ), .array5_5 (array5_5 ), .array5_6 (array5_6 ), .array5_7(array5_7),
    .array5_8(array5_8), .array5_9(array5_9), .array5_10(array5_10), .array5_11(array5_11), .array5_12(array5_12), .array5_13(array5_13),                   
                                                                                                                                                            
    .array6_1(array6_1), .array6_2(array6_2), .array6_3 (array6_3 ), .array6_4 (array6_4 ), .array6_5 (array6_5 ), .array6_6 (array6_6 ), .array6_7(array6_7),
    .array6_8(array6_8), .array6_9(array6_9), .array6_10(array6_10), .array6_11(array6_11), .array6_12(array6_12), .array6_13(array6_13),                   
                                                                                                                                                            
    .array7_1(array7_1), .array7_2(array7_2), .array7_3 (array7_3 ), .array7_4 (array7_4 ), .array7_5 (array7_5 ), .array7_6 (array7_6 ), .array7_7(array7_7),
    .array7_8(array7_8), .array7_9(array7_9), .array7_10(array7_10), .array7_11(array7_11), .array7_12(array7_12), .array7_13(array7_13),
    .imo3        (imo3        ),
    .imo3_valid  (imo3_valid  ),
    .m_d         (m_d         ),
    .imcin_d     (imcin_d     ),
    .imosum_valid(imosum_valid),
    .imo1_valid  (imo1_valid  )
);

assign imo4 = (m_d > 9'd102)? imo3:imcin_d;
assign imo4_valid = imo3_valid;


endmodule
