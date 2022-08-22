module sum90 #(
    parameter DW_PART = 9
)(
    input               clk  ,
    input               rst_n,
    input [DW_PART-1:0] in1_1, in1_2, in1_3, in1_4, in1_5, in1_6, in1_7, in1_8, in1_9, in1_10, in1_11, in1_12, in1_13,
    input [DW_PART-1:0] in2_1, in2_2, in2_3, in2_4, in2_5, in2_6, in2_7, in2_8, in2_9, in2_10, in2_11, in2_12, in2_13,
    input [DW_PART-1:0] in3_1, in3_2, in3_3, in3_4, in3_5, in3_6, in3_7, in3_8, in3_9, in3_10, in3_11, in3_12, in3_13,
    input [DW_PART-1:0] in4_1, in4_2, in4_3, in4_4, in4_5, in4_6,        in4_8, in4_9, in4_10, in4_11, in4_12, in4_13,   
    input [DW_PART-1:0] in5_1, in5_2, in5_3, in5_4, in5_5, in5_6, in5_7, in5_8, in5_9, in5_10, in5_11, in5_12, in5_13, 
    input [DW_PART-1:0] in6_1, in6_2, in6_3, in6_4, in6_5, in6_6, in6_7, in6_8, in6_9, in6_10, in6_11, in6_12, in6_13, 
    input [DW_PART-1:0] in7_1, in7_2, in7_3, in7_4, in7_5, in7_6, in7_7, in7_8, in7_9, in7_10, in7_11, in7_12, in7_13,     
    input               sum90_en,
    output reg [DW_PART+6:0] sum90
);

wire [DW_PART+1:0] sum_row1_1 = in1_1  + in1_2  + in1_3          ;
wire [DW_PART+1:0] sum_row1_2 = in1_4  + in1_5  + in1_6          ;
wire [DW_PART+1:0] sum_row1_3 = in1_7  + in1_8  + in1_9          ;
wire [DW_PART+1:0] sum_row1_4 = in1_10 + in1_11 + in1_12 + in1_13;

wire [DW_PART+1:0] sum_row2_1 = in2_1  + in2_2  + in2_3          ;
wire [DW_PART+1:0] sum_row2_2 = in2_4  + in2_5  + in2_6          ;
wire [DW_PART+1:0] sum_row2_3 = in2_7  + in2_8  + in2_9          ;
wire [DW_PART+1:0] sum_row2_4 = in2_10 + in2_11 + in2_12 + in2_13;

wire [DW_PART+1:0] sum_row3_1 = in3_1  + in3_2  + in3_3          ;
wire [DW_PART+1:0] sum_row3_2 = in3_4  + in3_5  + in3_6          ;
wire [DW_PART+1:0] sum_row3_3 = in3_7  + in3_8  + in3_9          ;
wire [DW_PART+1:0] sum_row3_4 = in3_10 + in3_11 + in3_12 + in3_13;

wire [DW_PART+1:0] sum_row4_1 = in4_1  + in4_2  + in4_3 ;
wire [DW_PART+1:0] sum_row4_2 = in4_4  + in4_5  + in4_6 ;
wire [DW_PART+1:0] sum_row4_3 = in4_8  + in4_9  + in4_10;
wire [DW_PART+1:0] sum_row4_4 = in4_11 + in4_12 + in4_13;

wire [DW_PART+1:0] sum_row5_1 = in5_1  + in5_2  + in5_3          ;
wire [DW_PART+1:0] sum_row5_2 = in5_4  + in5_5  + in5_6          ;
wire [DW_PART+1:0] sum_row5_3 = in5_7  + in5_8  + in5_9          ;
wire [DW_PART+1:0] sum_row5_4 = in5_10 + in5_11 + in5_12 + in5_13;

wire [DW_PART+1:0] sum_row6_1 = in6_1  + in6_2  + in6_3          ;
wire [DW_PART+1:0] sum_row6_2 = in6_4  + in6_5  + in6_6          ;
wire [DW_PART+1:0] sum_row6_3 = in6_7  + in6_8  + in6_9          ;
wire [DW_PART+1:0] sum_row6_4 = in6_10 + in6_11 + in6_12 + in6_13;

wire [DW_PART+1:0] sum_row7_1 = in7_1  + in7_2  + in7_3          ;
wire [DW_PART+1:0] sum_row7_2 = in7_4  + in7_5  + in7_6          ;
wire [DW_PART+1:0] sum_row7_3 = in7_7  + in7_8  + in7_9          ;
wire [DW_PART+1:0] sum_row7_4 = in7_10 + in7_11 + in7_12 + in7_13;

reg [DW_PART+1:0] sum_row1_1_d1, sum_row1_2_d1, sum_row1_3_d1, sum_row1_4_d1;
reg [DW_PART+1:0] sum_row2_1_d1, sum_row2_2_d1, sum_row2_3_d1, sum_row2_4_d1;
reg [DW_PART+1:0] sum_row3_1_d1, sum_row3_2_d1, sum_row3_3_d1, sum_row3_4_d1;
reg [DW_PART+1:0] sum_row4_1_d1, sum_row4_2_d1, sum_row4_3_d1, sum_row4_4_d1;
reg [DW_PART+1:0] sum_row5_1_d1, sum_row5_2_d1, sum_row5_3_d1, sum_row5_4_d1;
reg [DW_PART+1:0] sum_row6_1_d1, sum_row6_2_d1, sum_row6_3_d1, sum_row6_4_d1;
reg [DW_PART+1:0] sum_row7_1_d1, sum_row7_2_d1, sum_row7_3_d1, sum_row7_4_d1;

reg  [DW_PART+3:0] sum_row1, sum_row2, sum_row3, sum_row4, sum_row5, sum_row6, sum_row7;
reg  [DW_PART+5:0] sum90_1, sum90_2;

// clk 1
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        sum_row1_1_d1 <= {(DW_PART+2){1'b0}}; sum_row1_2_d1 <= {(DW_PART+2){1'b0}}; sum_row1_3_d1 <= {(DW_PART+2){1'b0}}; sum_row1_4_d1 <= {(DW_PART+2){1'b0}};   
        sum_row2_1_d1 <= {(DW_PART+2){1'b0}}; sum_row2_2_d1 <= {(DW_PART+2){1'b0}}; sum_row2_3_d1 <= {(DW_PART+2){1'b0}}; sum_row2_4_d1 <= {(DW_PART+2){1'b0}};
        sum_row3_1_d1 <= {(DW_PART+2){1'b0}}; sum_row3_2_d1 <= {(DW_PART+2){1'b0}}; sum_row3_3_d1 <= {(DW_PART+2){1'b0}}; sum_row3_4_d1 <= {(DW_PART+2){1'b0}};
        sum_row4_1_d1 <= {(DW_PART+2){1'b0}}; sum_row4_2_d1 <= {(DW_PART+2){1'b0}}; sum_row4_3_d1 <= {(DW_PART+2){1'b0}}; sum_row4_4_d1 <= {(DW_PART+2){1'b0}};
        sum_row5_1_d1 <= {(DW_PART+2){1'b0}}; sum_row5_2_d1 <= {(DW_PART+2){1'b0}}; sum_row5_3_d1 <= {(DW_PART+2){1'b0}}; sum_row5_4_d1 <= {(DW_PART+2){1'b0}};
        sum_row6_1_d1 <= {(DW_PART+2){1'b0}}; sum_row6_2_d1 <= {(DW_PART+2){1'b0}}; sum_row6_3_d1 <= {(DW_PART+2){1'b0}}; sum_row6_4_d1 <= {(DW_PART+2){1'b0}};
        sum_row7_1_d1 <= {(DW_PART+2){1'b0}}; sum_row7_2_d1 <= {(DW_PART+2){1'b0}}; sum_row7_3_d1 <= {(DW_PART+2){1'b0}}; sum_row7_4_d1 <= {(DW_PART+2){1'b0}};
    end 
    else if(sum90_en) begin
        sum_row1_1_d1 <= sum_row1_1; sum_row1_2_d1 <= sum_row1_2; sum_row1_3_d1 <= sum_row1_3; sum_row1_4_d1 <= sum_row1_4;   
        sum_row2_1_d1 <= sum_row2_1; sum_row2_2_d1 <= sum_row2_2; sum_row2_3_d1 <= sum_row2_3; sum_row2_4_d1 <= sum_row2_4;
        sum_row3_1_d1 <= sum_row3_1; sum_row3_2_d1 <= sum_row3_2; sum_row3_3_d1 <= sum_row3_3; sum_row3_4_d1 <= sum_row3_4;
        sum_row4_1_d1 <= sum_row4_1; sum_row4_2_d1 <= sum_row4_2; sum_row4_3_d1 <= sum_row4_3; sum_row4_4_d1 <= sum_row4_4;
        sum_row5_1_d1 <= sum_row5_1; sum_row5_2_d1 <= sum_row5_2; sum_row5_3_d1 <= sum_row5_3; sum_row5_4_d1 <= sum_row5_4;
        sum_row6_1_d1 <= sum_row6_1; sum_row6_2_d1 <= sum_row6_2; sum_row6_3_d1 <= sum_row6_3; sum_row6_4_d1 <= sum_row6_4;
        sum_row7_1_d1 <= sum_row7_1; sum_row7_2_d1 <= sum_row7_2; sum_row7_3_d1 <= sum_row7_3; sum_row7_4_d1 <= sum_row7_4;
    end
end

// clk 2
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        sum_row1 <= {(DW_PART+4){1'b0}}; sum_row2 <= {(DW_PART+4){1'b0}}; sum_row3 <= {(DW_PART+4){1'b0}}; sum_row4 <= {(DW_PART+4){1'b0}};
        sum_row5 <= {(DW_PART+4){1'b0}}; sum_row6 <= {(DW_PART+4){1'b0}}; sum_row7 <= {(DW_PART+4){1'b0}};     
    end
    else begin
        sum_row1 <= sum_row1_1_d1 + sum_row1_2_d1 + sum_row1_3_d1 + sum_row1_4_d1;
        sum_row2 <= sum_row2_1_d1 + sum_row2_2_d1 + sum_row2_3_d1 + sum_row2_4_d1;
        sum_row3 <= sum_row3_1_d1 + sum_row3_2_d1 + sum_row3_3_d1 + sum_row3_4_d1;
        sum_row4 <= sum_row4_1_d1 + sum_row4_2_d1 + sum_row4_3_d1 + sum_row4_4_d1;
        sum_row5 <= sum_row5_1_d1 + sum_row5_2_d1 + sum_row5_3_d1 + sum_row5_4_d1;
        sum_row6 <= sum_row6_1_d1 + sum_row6_2_d1 + sum_row6_3_d1 + sum_row6_4_d1;
        sum_row7 <= sum_row7_1_d1 + sum_row7_2_d1 + sum_row7_3_d1 + sum_row7_4_d1;
    end
end

// clk 3
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        sum90_1 <= {(DW_PART+6){1'b0}};
        sum90_2 <= {(DW_PART+6){1'b0}};
    end
    else begin
        sum90_1 <= sum_row1 + sum_row2 + sum_row3 + sum_row4;
        sum90_2 <= sum_row5 + sum_row6 + sum_row7           ;
    end
end

// clk 4
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sum90 <= {(DW_PART+7){1'b0}};
else
    sum90 <= sum90_1 + sum90_2;
end

endmodule
