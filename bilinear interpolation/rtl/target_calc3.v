module target_calc3 #(
    parameter DW            = 8 ,
    parameter ROW_CNT_WIDTH = 12,    
    parameter COL_CNT_WIDTH = 12
)(
    input               clk     ,
    input               rst_n   ,
    input               calc_en ,
    input      [DW-1:0] buf00   ,
    input      [DW-1:0] buf10   ,
    input      [DW-1:0] buf01   ,
    input      [DW-1:0] buf11   ,
    output reg [DW-1:0] target00,
    output reg [DW-1:0] target10,
    output reg          valid_o  
);

localparam DW_DEC      = 8     ; // 8 bit decimal
localparam para_1_3_8B = 8'd85 ;
localparam para_2_3_8B = 8'd171;
localparam para_1_9_8B = 8'd28 ;
localparam para_2_9_8B = 8'd57 ;
localparam para_4_9_8B = 8'd114;

reg          calc_en_d1, calc_en_d2;

reg [DW+DW_DEC-1:0] mult_2_3_P00, mult_1_3_P01;
reg [DW+DW_DEC-1:0] mult_2_9_P00, mult_4_9_P10, mult_1_9_P01, mult_2_9_P11;

wire [DW-1:0] mult_2_3_P00_clamp, mult_1_3_P01_clamp;
wire [DW-1:0] mult_2_9_P00_clamp, mult_4_9_P10_clamp, mult_1_9_P01_clamp, mult_2_9_P11_clamp;

reg [DW-1:0] target00_tmp, target10_half1, target10_half2;  

// clk 1
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    calc_en_d1 <= 1'b0;
else    
    calc_en_d1 <= calc_en;  
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    mult_2_3_P00 <= {(DW+DW_DEC){1'b0}};
else if(calc_en)
    mult_2_3_P00 <= buf00 * para_2_3_8B;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    mult_1_3_P01 <= {(DW+DW_DEC){1'b0}};
else if(calc_en)
    mult_1_3_P01 <= buf01 * para_1_3_8B;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    mult_2_9_P00 <= {(DW+DW_DEC){1'b0}};
else if(calc_en)
    mult_2_9_P00 <= buf00 * para_2_9_8B;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    mult_4_9_P10 <= {(DW+DW_DEC){1'b0}};
else if(calc_en)
    mult_4_9_P10 <= buf10 * para_4_9_8B;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    mult_1_9_P01 <= {(DW+DW_DEC){1'b0}};
else if(calc_en)
    mult_1_9_P01 <= buf01 * para_1_9_8B;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    mult_2_9_P11 <= {(DW+DW_DEC){1'b0}};
else if(calc_en)
    mult_2_9_P11 <= buf11 * para_2_9_8B;
end

assign mult_2_3_P00_clamp = mult_2_3_P00[DW_DEC-1]? (mult_2_3_P00[DW+DW_DEC-1:DW_DEC]+1'b1): mult_2_3_P00[DW+DW_DEC-1:DW_DEC]; //safe
assign mult_1_3_P01_clamp = mult_1_3_P01[DW_DEC-1]? (mult_1_3_P01[DW+DW_DEC-1:DW_DEC]+1'b1): mult_1_3_P01[DW+DW_DEC-1:DW_DEC]; 
assign mult_2_9_P00_clamp = mult_2_9_P00[DW_DEC-1]? (mult_2_9_P00[DW+DW_DEC-1:DW_DEC]+1'b1): mult_2_9_P00[DW+DW_DEC-1:DW_DEC];
assign mult_4_9_P10_clamp = mult_4_9_P10[DW_DEC-1]? (mult_4_9_P10[DW+DW_DEC-1:DW_DEC]+1'b1): mult_4_9_P10[DW+DW_DEC-1:DW_DEC];
assign mult_1_9_P01_clamp = mult_1_9_P01[DW_DEC-1]? (mult_1_9_P01[DW+DW_DEC-1:DW_DEC]+1'b1): mult_1_9_P01[DW+DW_DEC-1:DW_DEC];
assign mult_2_9_P11_clamp = mult_2_9_P11[DW_DEC-1]? (mult_2_9_P11[DW+DW_DEC-1:DW_DEC]+1'b1): mult_2_9_P11[DW+DW_DEC-1:DW_DEC];

// clk2
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    calc_en_d2 <= 1'b0;
else    
    calc_en_d2 <= calc_en_d1;  
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    target00_tmp <= {DW{1'b0}};
else if(calc_en_d1)    
    target00_tmp <= mult_2_3_P00_clamp + mult_1_3_P01_clamp;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    target10_half1 <= {DW{1'b0}};
else if(calc_en_d1)    
    target10_half1 <= mult_2_9_P00_clamp + mult_4_9_P10_clamp;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    target10_half2 <= {DW{1'b0}};
else if(calc_en_d1)    
    target10_half2 <= mult_1_9_P01_clamp + mult_2_9_P11_clamp;
end

// clk3
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    target00 <= {DW{1'b0}};
else if(calc_en_d2)    
    target00 <= target00_tmp;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    target10 <= {DW{1'b0}};
else if(calc_en_d2)    
    target10 <= target10_half1 + target10_half2;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    valid_o <= 1'b0;
else 
    valid_o <= calc_en_d2;    
end

endmodule