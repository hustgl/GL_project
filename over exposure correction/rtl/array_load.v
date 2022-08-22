module array_load #(
    parameter DW_IN         = 10,
    parameter ROW_CNT_WIDTH = 4 ,
    parameter COL_CNT_WIDTH = 5
)(
    input                     clk,
    input                     rst_n,

    input [ROW_CNT_WIDTH-1:0] row_cnt,
    input [COL_CNT_WIDTH-1:0] col_cnt,

    input                     array_load_start,

    input [DW_IN*4-1:0]       data_in1,
    input [DW_IN*4-1:0]       data_in2,
    input [DW_IN*4-1:0]       data_in3,
    input [DW_IN*4-1:0]       data_in4,
    input [DW_IN*4-1:0]       data_in5,
    input [DW_IN*4-1:0]       data_in6,
    input [DW_IN*4-1:0]       data_in7,
    
    input [DW_IN*4-1:0]       imo_replace_line1_7 , imo_replace_line1_8 , imo_replace_line1_9 , imo_replace_line1_10,
    input [DW_IN*4-1:0]       imo_replace_line1_11, imo_replace_line1_12, imo_replace_line1_13,

    input [DW_IN*4-1:0]       imo_replace_line2_7 , imo_replace_line2_8 , imo_replace_line2_9 , imo_replace_line2_10,
    input [DW_IN*4-1:0]       imo_replace_line2_11, imo_replace_line2_12, imo_replace_line2_13,

    input [DW_IN*4-1:0]       imo_replace_line3_7 , imo_replace_line3_8 , imo_replace_line3_9 , imo_replace_line3_10,
    input [DW_IN*4-1:0]       imo_replace_line3_11, imo_replace_line3_12, imo_replace_line3_13,

    output                    array_load_done,

    output reg [DW_IN*4-1:0]  row1_buf1, row1_buf2, row1_buf3 , row1_buf4 , row1_buf5 , row1_buf6 , row1_buf7, 
    output reg [DW_IN*4-1:0]  row1_buf8, row1_buf9, row1_buf10, row1_buf11, row1_buf12, row1_buf13,

    output reg [DW_IN*4-1:0]  row2_buf1, row2_buf2, row2_buf3 , row2_buf4 , row2_buf5 , row2_buf6 , row2_buf7, 
    output reg [DW_IN*4-1:0]  row2_buf8, row2_buf9, row2_buf10, row2_buf11, row2_buf12, row2_buf13,

    output reg [DW_IN*4-1:0]  row3_buf1, row3_buf2, row3_buf3 , row3_buf4 , row3_buf5 , row3_buf6 , row3_buf7, 
    output reg [DW_IN*4-1:0]  row3_buf8, row3_buf9, row3_buf10, row3_buf11, row3_buf12, row3_buf13,

    output reg [DW_IN*4-1:0]  row4_buf1, row4_buf2, row4_buf3 , row4_buf4 , row4_buf5 , row4_buf6 , row4_buf7, 
    output reg [DW_IN*4-1:0]  row4_buf8, row4_buf9, row4_buf10, row4_buf11, row4_buf12, row4_buf13,

    output reg [DW_IN*4-1:0]  row5_buf1, row5_buf2, row5_buf3 , row5_buf4 , row5_buf5 , row5_buf6 , row5_buf7, 
    output reg [DW_IN*4-1:0]  row5_buf8, row5_buf9, row5_buf10, row5_buf11, row5_buf12, row5_buf13,

    output reg [DW_IN*4-1:0]  row6_buf1, row6_buf2, row6_buf3 , row6_buf4 , row6_buf5 , row6_buf6 , row6_buf7, 
    output reg [DW_IN*4-1:0]  row6_buf8, row6_buf9, row6_buf10, row6_buf11, row6_buf12, row6_buf13,

    output reg [DW_IN*4-1:0]  row7_buf1, row7_buf2, row7_buf3 , row7_buf4 , row7_buf5 , row7_buf6 , row7_buf7, 
    output reg [DW_IN*4-1:0]  row7_buf8, row7_buf9, row7_buf10, row7_buf11, row7_buf12, row7_buf13
);

reg  [3:0] load_cnt     ;
wire [3:0] load_cnt_temp;

assign load_cnt_temp = (load_cnt==4'd12)? 4'd0:(load_cnt+4'd1);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    load_cnt <= 4'd0;
else if(array_load_start)
    load_cnt <= load_cnt_temp;
else if(load_cnt != 4'd0)
    load_cnt <= load_cnt_temp;
else
    load_cnt <= 4'd0;
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        row4_buf1 <= {DW_IN*4{1'b0}}; row4_buf2  <= {DW_IN*4{1'b0}}; row4_buf3  <= {DW_IN*4{1'b0}}; row4_buf4  <= {DW_IN*4{1'b0}};
        row4_buf5 <= {DW_IN*4{1'b0}}; row4_buf6  <= {DW_IN*4{1'b0}}; row4_buf7  <= {DW_IN*4{1'b0}}; row4_buf8  <= {DW_IN*4{1'b0}};
        row4_buf9 <= {DW_IN*4{1'b0}}; row4_buf10 <= {DW_IN*4{1'b0}}; row4_buf11 <= {DW_IN*4{1'b0}}; row4_buf12 <= {DW_IN*4{1'b0}}; row4_buf13 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_start || load_cnt!=4'd0)begin
        row4_buf1 <= row4_buf2; row4_buf2 <= row4_buf3 ; row4_buf3  <= row4_buf4 ; row4_buf4  <= row4_buf5 ; row4_buf5  <= row4_buf6 ; row4_buf6  <= row4_buf7; row4_buf7 <= row4_buf8; 
        row4_buf8 <= row4_buf9; row4_buf9 <= row4_buf10; row4_buf10 <= row4_buf11; row4_buf11 <= row4_buf12; row4_buf12 <= row4_buf13; row4_buf13 <= data_in4 ;
    end    
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        row5_buf1 <= {DW_IN*4{1'b0}}; row5_buf2  <= {DW_IN*4{1'b0}}; row5_buf3  <= {DW_IN*4{1'b0}}; row5_buf4  <= {DW_IN*4{1'b0}};
        row5_buf5 <= {DW_IN*4{1'b0}}; row5_buf6  <= {DW_IN*4{1'b0}}; row5_buf7  <= {DW_IN*4{1'b0}}; row5_buf8  <= {DW_IN*4{1'b0}};
        row5_buf9 <= {DW_IN*4{1'b0}}; row5_buf10 <= {DW_IN*4{1'b0}}; row5_buf11 <= {DW_IN*4{1'b0}}; row5_buf12 <= {DW_IN*4{1'b0}}; row5_buf13 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_start || load_cnt!=4'd0)begin
        row5_buf1 <= row5_buf2; row5_buf2 <= row5_buf3 ; row5_buf3  <= row5_buf4 ; row5_buf4  <= row5_buf5 ; row5_buf5  <= row5_buf6 ; row5_buf6  <= row5_buf7; row5_buf7 <= row5_buf8; 
        row5_buf8 <= row5_buf9; row5_buf9 <= row5_buf10; row5_buf10 <= row5_buf11; row5_buf11 <= row5_buf12; row5_buf12 <= row5_buf13; row5_buf13 <= data_in5 ;
    end    
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        row6_buf1 <= {DW_IN*4{1'b0}}; row6_buf2  <= {DW_IN*4{1'b0}}; row6_buf3  <= {DW_IN*4{1'b0}}; row6_buf4  <= {DW_IN*4{1'b0}};
        row6_buf5 <= {DW_IN*4{1'b0}}; row6_buf6  <= {DW_IN*4{1'b0}}; row6_buf7  <= {DW_IN*4{1'b0}}; row6_buf8  <= {DW_IN*4{1'b0}};
        row6_buf9 <= {DW_IN*4{1'b0}}; row6_buf10 <= {DW_IN*4{1'b0}}; row6_buf11 <= {DW_IN*4{1'b0}}; row6_buf12 <= {DW_IN*4{1'b0}}; row6_buf13 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_start || load_cnt!=4'd0)begin
        row6_buf1 <= row6_buf2; row6_buf2 <= row6_buf3 ; row6_buf3  <= row6_buf4 ; row6_buf4  <= row6_buf5 ; row6_buf5  <= row6_buf6 ; row6_buf6  <= row6_buf7; row6_buf7 <= row6_buf8; 
        row6_buf8 <= row6_buf9; row6_buf9 <= row6_buf10; row6_buf10 <= row6_buf11; row6_buf11 <= row6_buf12; row6_buf12 <= row6_buf13; row6_buf13 <= data_in6 ;
    end    
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        row7_buf1 <= {DW_IN*4{1'b0}}; row7_buf2  <= {DW_IN*4{1'b0}}; row7_buf3  <= {DW_IN*4{1'b0}}; row7_buf4  <= {DW_IN*4{1'b0}};
        row7_buf5 <= {DW_IN*4{1'b0}}; row7_buf6  <= {DW_IN*4{1'b0}}; row7_buf7  <= {DW_IN*4{1'b0}}; row7_buf8  <= {DW_IN*4{1'b0}};
        row7_buf9 <= {DW_IN*4{1'b0}}; row7_buf10 <= {DW_IN*4{1'b0}}; row7_buf11 <= {DW_IN*4{1'b0}}; row7_buf12 <= {DW_IN*4{1'b0}}; row7_buf13 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_start || load_cnt!=4'd0)begin
        row7_buf1 <= row7_buf2; row7_buf2 <= row7_buf3 ; row7_buf3  <= row7_buf4 ; row7_buf4  <= row7_buf5 ; row7_buf5  <= row7_buf6 ; row7_buf6  <= row7_buf7; row7_buf7 <= row7_buf8; 
        row7_buf8 <= row7_buf9; row7_buf9 <= row7_buf10; row7_buf10 <= row7_buf11; row7_buf11 <= row7_buf12; row7_buf12 <= row7_buf13; row7_buf13 <= data_in7 ; 
    end    
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        row1_buf1 <= {DW_IN*4{1'b0}}; row1_buf2  <= {DW_IN*4{1'b0}}; row1_buf3  <= {DW_IN*4{1'b0}}; row1_buf4  <= {DW_IN*4{1'b0}};
        row1_buf5 <= {DW_IN*4{1'b0}}; row1_buf6  <= {DW_IN*4{1'b0}}; row1_buf7  <= {DW_IN*4{1'b0}}; row1_buf8  <= {DW_IN*4{1'b0}};
        row1_buf9 <= {DW_IN*4{1'b0}}; row1_buf10 <= {DW_IN*4{1'b0}}; row1_buf11 <= {DW_IN*4{1'b0}}; row1_buf12 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_start || load_cnt!=4'd0)begin
        row1_buf1 <= row1_buf2; row1_buf2 <= row1_buf3; row1_buf3 <= row1_buf4 ; row1_buf4  <= row1_buf5 ; row1_buf5  <= row1_buf6 ; row1_buf6  <= row1_buf7 ; 
        row1_buf7 <= row1_buf8; row1_buf8 <= row1_buf9; row1_buf9 <= row1_buf10; row1_buf10 <= row1_buf11; row1_buf11 <= row1_buf12; row1_buf12 <= row1_buf13; 
    end    
end

//control the source of array
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    row1_buf13 <= {DW_IN*4{1'b0}};
else if(array_load_start || load_cnt!=4'd0) begin
    if(row_cnt >= 4'd3)
        case(col_cnt)
            5'd6 : row1_buf13 <= imo_replace_line1_7 ;
            5'd7 : row1_buf13 <= imo_replace_line1_8 ;
            5'd8 : row1_buf13 <= imo_replace_line1_9 ;
            5'd9 : row1_buf13 <= imo_replace_line1_10;
            5'd10: row1_buf13 <= imo_replace_line1_11;
            5'd11: row1_buf13 <= imo_replace_line1_12;
            5'd12: row1_buf13 <= imo_replace_line1_13;
            default: row1_buf13 <= data_in1;
        endcase
    else
        row1_buf13 <= data_in1; 
    end    
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        row2_buf1 <= {DW_IN*4{1'b0}}; row2_buf2  <= {DW_IN*4{1'b0}}; row2_buf3  <= {DW_IN*4{1'b0}}; row2_buf4  <= {DW_IN*4{1'b0}};
        row2_buf5 <= {DW_IN*4{1'b0}}; row2_buf6  <= {DW_IN*4{1'b0}}; row2_buf7  <= {DW_IN*4{1'b0}}; row2_buf8  <= {DW_IN*4{1'b0}};
        row2_buf9 <= {DW_IN*4{1'b0}}; row2_buf10 <= {DW_IN*4{1'b0}}; row2_buf11 <= {DW_IN*4{1'b0}}; row2_buf12 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_start || load_cnt!=4'd0)begin
        row2_buf1 <= row2_buf2; row2_buf2 <= row2_buf3; row2_buf3 <= row2_buf4 ; row2_buf4  <= row2_buf5 ; row2_buf5  <= row2_buf6 ; row2_buf6  <= row2_buf7 ; 
        row2_buf7 <= row2_buf8; row2_buf8 <= row2_buf9; row2_buf9 <= row2_buf10; row2_buf10 <= row2_buf11; row2_buf11 <= row2_buf12; row2_buf12 <= row2_buf13; 
    end    
end

//control the source of array
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    row2_buf13 <= {DW_IN*4{1'b0}};
else if(array_load_start || load_cnt!=4'd0) begin
    if(row_cnt >= 4'd2)
        case(col_cnt)
            5'd6 : row2_buf13 <= imo_replace_line2_7 ;
            5'd7 : row2_buf13 <= imo_replace_line2_8 ;
            5'd8 : row2_buf13 <= imo_replace_line2_9 ;
            5'd9 : row2_buf13 <= imo_replace_line2_10;
            5'd10: row2_buf13 <= imo_replace_line2_11;
            5'd11: row2_buf13 <= imo_replace_line2_12;
            5'd12: row2_buf13 <= imo_replace_line2_13;
            default: row2_buf13 <= data_in2;
        endcase
    else
        row2_buf13 <= data_in2;
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        row3_buf1 <= {DW_IN*4{1'b0}}; row3_buf2  <= {DW_IN*4{1'b0}}; row3_buf3  <= {DW_IN*4{1'b0}}; row3_buf4  <= {DW_IN*4{1'b0}};
        row3_buf5 <= {DW_IN*4{1'b0}}; row3_buf6  <= {DW_IN*4{1'b0}}; row3_buf7  <= {DW_IN*4{1'b0}}; row3_buf8  <= {DW_IN*4{1'b0}};
        row3_buf9 <= {DW_IN*4{1'b0}}; row3_buf10 <= {DW_IN*4{1'b0}}; row3_buf11 <= {DW_IN*4{1'b0}}; row3_buf12 <= {DW_IN*4{1'b0}};
    end
    else if(array_load_start || load_cnt!=4'd0)begin
        row3_buf1 <= row3_buf2; row3_buf2 <= row3_buf3; row3_buf3 <= row3_buf4 ; row3_buf4  <= row3_buf5 ; row3_buf5  <= row3_buf6 ; row3_buf6  <= row3_buf7 ; 
        row3_buf7 <= row3_buf8; row3_buf8 <= row3_buf9; row3_buf9 <= row3_buf10; row3_buf10 <= row3_buf11; row3_buf11 <= row3_buf12; row3_buf12 <= row3_buf13; 
    end    
end

//control the source of array
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    row3_buf13 <= {DW_IN*4{1'b0}};
else if(array_load_start || load_cnt!=4'd0) begin
    if(row_cnt >= 4'd1) begin
        case(col_cnt)
            5'd6 : row3_buf13 <= imo_replace_line3_7 ;
            5'd7 : row3_buf13 <= imo_replace_line3_8 ;
            5'd8 : row3_buf13 <= imo_replace_line3_9 ;
            5'd9 : row3_buf13 <= imo_replace_line3_10;
            5'd10: row3_buf13 <= imo_replace_line3_11;
            5'd11: row3_buf13 <= imo_replace_line3_12;
            5'd12: row3_buf13 <= imo_replace_line3_13;
            default: row3_buf13 <= data_in3;
        endcase
    end
    else
        row3_buf13 <= data_in3;
    end
end

assign array_load_done = (col_cnt==4'd13);

endmodule
