// input x:0~1023
// output y: 1bit.8bit,  max 1.00000000
// sector length = 16
module tanhcurve #(
    parameter DW_Y = 9 ,
    parameter DW_X = 10
)(
    input                 clk,
    input                 rst_n,
    input      [DW_Y-1:0] y1_0 ,y1_1 ,y1_2 ,y1_3 ,y1_4 ,y1_5 ,y1_6 ,y1_7 ,y1_8 ,y1_9 ,y1_10,y1_11,y1_12,
    input      [DW_Y-1:0] y1_13,y1_14,y1_15,y1_16,y1_17,y1_18,y1_19,y1_20,y1_21,y1_22,y1_23,y1_24,y1_25,
    input      [DW_Y-1:0] y1_26,y1_27,y1_28,y1_29,y1_30,y1_31,y1_32,y1_33,y1_34,y1_35,y1_36,y1_37,y1_38,
    input      [DW_Y-1:0] y1_39,y1_40,y1_41,y1_42,y1_43,y1_44,y1_45,y1_46,y1_47,y1_48,y1_49,y1_50,y1_51,
    input      [DW_Y-1:0] y1_52,y1_53,y1_54,y1_55,y1_56,y1_57,y1_58,y1_59,y1_60,y1_61,y1_62,y1_63,y1_64,
    input      [DW_X-1:0] in,
    output reg [DW_Y-1:0] out_d2
);

wire [DW_X-5:0] in_clamp = in[DW_X-1:4];
reg  [DW_Y-1:0] OL_tmp, OL, OH_tmp, OH ;

reg  [DW_X-1:0] in_d1;

always@(*) begin
case(in_clamp)
    0 : {OL_tmp, OH_tmp} = {y1_0 , y1_1 };  1 : {OL_tmp, OH_tmp} = {y1_1 , y1_2 };
    2 : {OL_tmp, OH_tmp} = {y1_2 , y1_3 };  3 : {OL_tmp, OH_tmp} = {y1_3 , y1_4 };
    4 : {OL_tmp, OH_tmp} = {y1_4 , y1_5 };  5 : {OL_tmp, OH_tmp} = {y1_5 , y1_6 };
    6 : {OL_tmp, OH_tmp} = {y1_6 , y1_7 };  7 : {OL_tmp, OH_tmp} = {y1_7 , y1_8 };
    8 : {OL_tmp, OH_tmp} = {y1_8 , y1_9 };  9 : {OL_tmp, OH_tmp} = {y1_9 , y1_10};
    10: {OL_tmp, OH_tmp} = {y1_10, y1_11};  11: {OL_tmp, OH_tmp} = {y1_11, y1_12};
    12: {OL_tmp, OH_tmp} = {y1_12, y1_13};  13: {OL_tmp, OH_tmp} = {y1_13, y1_14};
    14: {OL_tmp, OH_tmp} = {y1_14, y1_15};  15: {OL_tmp, OH_tmp} = {y1_15, y1_16};
    16: {OL_tmp, OH_tmp} = {y1_16, y1_17};  17: {OL_tmp, OH_tmp} = {y1_17, y1_18};
    18: {OL_tmp, OH_tmp} = {y1_18, y1_19};  19: {OL_tmp, OH_tmp} = {y1_19, y1_20};
    20: {OL_tmp, OH_tmp} = {y1_20, y1_21};  21: {OL_tmp, OH_tmp} = {y1_21, y1_22};
    22: {OL_tmp, OH_tmp} = {y1_22, y1_23};  23: {OL_tmp, OH_tmp} = {y1_23, y1_24};
    24: {OL_tmp, OH_tmp} = {y1_24, y1_25};  25: {OL_tmp, OH_tmp} = {y1_25, y1_26};
    26: {OL_tmp, OH_tmp} = {y1_26, y1_27};  27: {OL_tmp, OH_tmp} = {y1_27, y1_28};
    28: {OL_tmp, OH_tmp} = {y1_28, y1_29};  29: {OL_tmp, OH_tmp} = {y1_29, y1_30};
    30: {OL_tmp, OH_tmp} = {y1_30, y1_31};  31: {OL_tmp, OH_tmp} = {y1_31, y1_32};
    32: {OL_tmp, OH_tmp} = {y1_32, y1_33};  33: {OL_tmp, OH_tmp} = {y1_33, y1_34};
    34: {OL_tmp, OH_tmp} = {y1_34, y1_35};  35: {OL_tmp, OH_tmp} = {y1_35, y1_36};
    36: {OL_tmp, OH_tmp} = {y1_36, y1_37};  37: {OL_tmp, OH_tmp} = {y1_37, y1_38};
    38: {OL_tmp, OH_tmp} = {y1_38, y1_39};  39: {OL_tmp, OH_tmp} = {y1_39, y1_40};
    40: {OL_tmp, OH_tmp} = {y1_40, y1_41};  41: {OL_tmp, OH_tmp} = {y1_41, y1_42};
    42: {OL_tmp, OH_tmp} = {y1_42, y1_43};  43: {OL_tmp, OH_tmp} = {y1_43, y1_44};
    44: {OL_tmp, OH_tmp} = {y1_44, y1_45};  45: {OL_tmp, OH_tmp} = {y1_45, y1_46};
    46: {OL_tmp, OH_tmp} = {y1_46, y1_47};  47: {OL_tmp, OH_tmp} = {y1_47, y1_48};
    48: {OL_tmp, OH_tmp} = {y1_48, y1_49};  49: {OL_tmp, OH_tmp} = {y1_49, y1_50};
    50: {OL_tmp, OH_tmp} = {y1_50, y1_51};  51: {OL_tmp, OH_tmp} = {y1_51, y1_52};
    52: {OL_tmp, OH_tmp} = {y1_52, y1_53};  53: {OL_tmp, OH_tmp} = {y1_53, y1_54};
    54: {OL_tmp, OH_tmp} = {y1_54, y1_55};  55: {OL_tmp, OH_tmp} = {y1_55, y1_56};
    56: {OL_tmp, OH_tmp} = {y1_56, y1_57};  57: {OL_tmp, OH_tmp} = {y1_57, y1_58};
    58: {OL_tmp, OH_tmp} = {y1_58, y1_59};  59: {OL_tmp, OH_tmp} = {y1_59, y1_60};
    60: {OL_tmp, OH_tmp} = {y1_60, y1_61};  61: {OL_tmp, OH_tmp} = {y1_61, y1_62};
    62: {OL_tmp, OH_tmp} = {y1_62, y1_63};  63: {OL_tmp, OH_tmp} = {y1_63, y1_64};
    default: {OL_tmp, OH_tmp} = {{DW_Y{1'b0}} , {DW_Y{1'b0}}};
endcase
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        in_d1 <= {DW_X{1'b0}};
        OL    <= {DW_Y{1'b0}};
        OH    <= {DW_Y{1'b0}};
    end
    else begin
        in_d1 <= in;
        OL    <= OL_tmp;
        OH    <= OH_tmp;
    end
end

wire [3:0]      in_offset = in_d1[3:0]            ;
wire [DW_Y+3:0] mult_tmp  = (in_offset*(OH-OL)>>4); //4bit * 9bit >> 4
wire [DW_Y-1:0] out_d1    = OL+mult_tmp[DW_Y-1:0] ;  //safe

always@(posedge clk) begin
if(!rst_n)
    out_d2 <= {DW_Y{1'b0}};
else
    out_d2 <= out_d1;    
end

endmodule
