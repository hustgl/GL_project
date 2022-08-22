// input -1023 ~ 1023, input width 11bits, the MSB is the sign bit
// MSB 1 negative y1, MSB 0 postive y2
// output interger 1bit, decimal 8bits
// y1 monotonical decrease, y2 monotonical decrease
// output result after 2 clks
module expcurve #(
    parameter DW_Y = 9 ,
    parameter DW_X = 11
)(
    input                    clk                                            ,
    input                    rst_n                                          ,
    input      [DW_Y-1:0]    y1_0 ,y1_1 ,y1_2 ,y1_3 ,y1_4 ,y1_5 ,y1_6 ,y1_7 ,
    input      [DW_Y-1:0]    y1_8 ,y1_9 ,y1_10,y1_11,y1_12,y1_13,y1_14,y1_15,
    input      [DW_Y-1:0]    y1_16,y1_17,y1_18,y1_19,y1_20,y1_21,y1_22,y1_23,
    input      [DW_Y-1:0]    y1_24,y1_25,y1_26,y1_27,y1_28,y1_29,y1_30,y1_31,
    input      [DW_Y-1:0]    y1_32,y1_33,y1_34,y1_35,y1_36,y1_37,y1_38,y1_39,
    input      [DW_Y-1:0]    y1_40,y1_41,y1_42,y1_43,y1_44,y1_45,y1_46,y1_47,   //47 sectors, 48 sector labels

    input      [DW_Y-1:0]    y2_0,y2_1,y2_2,y2_3,y2_4,y2_5,y2_6,y2_7,y2_8   ,      //9 sector labels
    input      [DW_X-1:0]    in                                             ,    
    output reg [DW_Y-1:0]    out_d2 
);

wire [5:0] in_clamp = in[DW_X-2:DW_X-7];  //judge the sector, 64 sectors, 47 nonzero sectors
reg  [DW_Y-1:0] OL_tmp, OL, OH_tmp, OH;

//clk 1
reg  [DW_X-2:0] in_d1;
reg  [DW_X-2:0] IL   ;

always@(*) begin
    if(in[10]) begin
        case(in_clamp)
        6'd0 : {OL_tmp, OH_tmp} = {y1_0 , y1_1 };  6'd1 : {OL_tmp, OH_tmp} = {y1_1 , y1_2 };
        6'd2 : {OL_tmp, OH_tmp} = {y1_2 , y1_3 };  6'd3 : {OL_tmp, OH_tmp} = {y1_3 , y1_4 };
        6'd4 : {OL_tmp, OH_tmp} = {y1_4 , y1_5 };  6'd5 : {OL_tmp, OH_tmp} = {y1_5 , y1_6 };
        6'd6 : {OL_tmp, OH_tmp} = {y1_6 , y1_7 };  6'd7 : {OL_tmp, OH_tmp} = {y1_7 , y1_8 };
        6'd8 : {OL_tmp, OH_tmp} = {y1_8 , y1_9 };  6'd9 : {OL_tmp, OH_tmp} = {y1_9 , y1_10};
        6'd10: {OL_tmp, OH_tmp} = {y1_10, y1_11};  6'd11: {OL_tmp, OH_tmp} = {y1_11, y1_12};
        6'd12: {OL_tmp, OH_tmp} = {y1_12, y1_13};  6'd13: {OL_tmp, OH_tmp} = {y1_13, y1_14};
        6'd14: {OL_tmp, OH_tmp} = {y1_14, y1_15};  6'd15: {OL_tmp, OH_tmp} = {y1_15, y1_16};
        6'd16: {OL_tmp, OH_tmp} = {y1_16, y1_17};  6'd17: {OL_tmp, OH_tmp} = {y1_17, y1_18};
        6'd18: {OL_tmp, OH_tmp} = {y1_18, y1_19};  6'd19: {OL_tmp, OH_tmp} = {y1_19, y1_20};
        6'd20: {OL_tmp, OH_tmp} = {y1_20, y1_21};  6'd21: {OL_tmp, OH_tmp} = {y1_21, y1_22};
        6'd22: {OL_tmp, OH_tmp} = {y1_22, y1_23};  6'd23: {OL_tmp, OH_tmp} = {y1_23, y1_24};
        6'd24: {OL_tmp, OH_tmp} = {y1_24, y1_25};  6'd25: {OL_tmp, OH_tmp} = {y1_25, y1_26};
        6'd26: {OL_tmp, OH_tmp} = {y1_26, y1_27};  6'd27: {OL_tmp, OH_tmp} = {y1_27, y1_28};
        6'd28: {OL_tmp, OH_tmp} = {y1_28, y1_29};  6'd29: {OL_tmp, OH_tmp} = {y1_29, y1_30};
        6'd30: {OL_tmp, OH_tmp} = {y1_30, y1_31};  6'd31: {OL_tmp, OH_tmp} = {y1_31, y1_32};
        6'd32: {OL_tmp, OH_tmp} = {y1_32, y1_33};  6'd33: {OL_tmp, OH_tmp} = {y1_33, y1_34};
        6'd34: {OL_tmp, OH_tmp} = {y1_34, y1_35};  6'd35: {OL_tmp, OH_tmp} = {y1_35, y1_36};
        6'd36: {OL_tmp, OH_tmp} = {y1_36, y1_37};  6'd37: {OL_tmp, OH_tmp} = {y1_37, y1_38};
        6'd38: {OL_tmp, OH_tmp} = {y1_38, y1_39};  6'd39: {OL_tmp, OH_tmp} = {y1_39, y1_40};
        6'd40: {OL_tmp, OH_tmp} = {y1_40, y1_41};  6'd41: {OL_tmp, OH_tmp} = {y1_41, y1_42};
        6'd42: {OL_tmp, OH_tmp} = {y1_42, y1_43};  6'd43: {OL_tmp, OH_tmp} = {y1_43, y1_44};
        6'd44: {OL_tmp, OH_tmp} = {y1_44, y1_45};  6'd45: {OL_tmp, OH_tmp} = {y1_45, y1_46};
        6'd46: {OL_tmp, OH_tmp} = {y1_46, y1_47};
        default: {OL_tmp, OH_tmp} = {9'd0, 9'd0};
        endcase
    end
    else begin
        case(in_clamp)
        6'd0 : {OL_tmp, OH_tmp} = {y2_0 , y2_1 };  6'd1 : {OL_tmp, OH_tmp} = {y2_1 , y2_2 };
        6'd2 : {OL_tmp, OH_tmp} = {y2_2 , y2_3 };  6'd3 : {OL_tmp, OH_tmp} = {y2_3 , y2_4 };
        6'd4 : {OL_tmp, OH_tmp} = {y2_4 , y2_5 };  6'd5 : {OL_tmp, OH_tmp} = {y2_5 , y2_6 };
        6'd6 : {OL_tmp, OH_tmp} = {y2_6 , y2_7 };  6'd7 : {OL_tmp, OH_tmp} = {y2_7 , y2_8 };
        default: {OL_tmp, OH_tmp} = {9'd0, 9'd0};
        endcase
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        in_d1 <= {(DW_X-1){1'b0}};
        IL    <= {(DW_X-1){1'b0}};  // the lower boundary
        OL    <= {DW_Y{1'b0}}    ;
        OH    <= {DW_Y{1'b0}}    ;
    end
    else begin
        in_d1 <= in[DW_X-2:0]   ;
        IL    <= (in_clamp << 4);  // the lower boundary
        OL    <= OL_tmp         ;
        OH    <= OH_tmp         ;    
    end
end

wire [3:0]      in_offset = in_d1[3:0]            ; //safe, offset <= 15
wire [12:0]     mult_tmp  = (in_offset*(OL-OH)>>4); //4bit*9bit = 13bit 
wire [DW_Y-1:0] out_d1    = OL - mult_tmp[8:0]    ;

//clk2
always@(posedge clk) begin
if(!rst_n)
    out_d2 <= {DW_Y{1'b0}};
else    
    out_d2 <= out_d1;
end    

endmodule
