module array_calc #(
    parameter DW_IN         = 10,
    parameter DW_DEC        = 8 ,
    parameter ROW_CNT_WIDTH = 4 ,
    parameter COL_CNT_WIDTH = 5 
)(
    input                          clk          ,
    input                          rst_n        ,

    input      [ROW_CNT_WIDTH-1:0] row_cnt      ,
    input      [COL_CNT_WIDTH-1:0] col_cnt      ,

    input                          array_calc_en,

    input      [DW_IN*4-1      :0] array1_1, array1_2, array1_3 , array1_4 , array1_5 , array1_6 , array1_7, 
    input      [DW_IN*4-1      :0] array1_8, array1_9, array1_10, array1_11, array1_12, array1_13,
                            
    input      [DW_IN*4-1      :0] array2_1, array2_2, array2_3 , array2_4 , array2_5 , array2_6 , array2_7, 
    input      [DW_IN*4-1      :0] array2_8, array2_9, array2_10, array2_11, array2_12, array2_13,
                            
    input      [DW_IN*4-1      :0] array3_1, array3_2, array3_3 , array3_4 , array3_5 , array3_6 , array3_7, 
    input      [DW_IN*4-1      :0] array3_8, array3_9, array3_10, array3_11, array3_12, array3_13,
                                  
    input      [DW_IN*4-1      :0] array4_1, array4_2, array4_3 , array4_4 , array4_5 , array4_6 , array4_7, 
    input      [DW_IN*4-1      :0] array4_8, array4_9, array4_10, array4_11, array4_12, array4_13,
                                  
    input      [DW_IN*4-1      :0] array5_1, array5_2, array5_3 , array5_4 , array5_5 , array5_6 , array5_7,
    input      [DW_IN*4-1      :0] array5_8, array5_9, array5_10, array5_11, array5_12, array5_13,
                                  
    input      [DW_IN*4-1      :0] array6_1, array6_2, array6_3 , array6_4 , array6_5 , array6_6 , array6_7, 
    input      [DW_IN*4-1      :0] array6_8, array6_9, array6_10, array6_11, array6_12, array6_13,
                                  
    input      [DW_IN*4-1      :0] array7_1, array7_2, array7_3 , array7_4 , array7_5 , array7_6 , array7_7,
    input      [DW_IN*4-1      :0] array7_8, array7_9, array7_10, array7_11, array7_12, array7_13,     

    output reg [DW_IN*4-1      :0] imo3        ,
    output reg                     imo3_valid  ,
    output     [DW_DEC         :0] m_d         ,
    output     [DW_IN*4-1      :0] imcin_d     ,
    output                         imosum_valid,
    output                         imo1_valid   
);

localparam ARRAY_CALC_EN_DELAY = 12                 ;
localparam IMO1_CALC_EN_DELAY  = 4                  ;
localparam MCOR_DELAY          = ARRAY_CALC_EN_DELAY+IMO1_CALC_EN_DELAY+5-2;

integer i;

wire [DW_IN-1  :0] imoy_i_j;

wire [DW_DEC:0] wtmp1_1, wtmp1_2, wtmp1_3 , wtmp1_4 , wtmp1_5 , wtmp1_6 , wtmp1_7; 
wire [DW_DEC:0] wtmp1_8, wtmp1_9, wtmp1_10, wtmp1_11, wtmp1_12, wtmp1_13;
                   
wire [DW_DEC:0] wtmp2_1, wtmp2_2, wtmp2_3 , wtmp2_4 , wtmp2_5 , wtmp2_6 , wtmp2_7; 
wire [DW_DEC:0] wtmp2_8, wtmp2_9, wtmp2_10, wtmp2_11, wtmp2_12, wtmp2_13;
                   
wire [DW_DEC:0] wtmp3_1, wtmp3_2, wtmp3_3 , wtmp3_4 , wtmp3_5 , wtmp3_6 , wtmp3_7; 
wire [DW_DEC:0] wtmp3_8, wtmp3_9, wtmp3_10, wtmp3_11, wtmp3_12, wtmp3_13;
                   
wire [DW_DEC:0] wtmp4_1, wtmp4_2, wtmp4_3 , wtmp4_4 , wtmp4_5 , wtmp4_6 , wtmp4_7; 
wire [DW_DEC:0] wtmp4_8, wtmp4_9, wtmp4_10, wtmp4_11, wtmp4_12, wtmp4_13;
                   
wire [DW_DEC:0] wtmp5_1, wtmp5_2, wtmp5_3 , wtmp5_4 , wtmp5_5 , wtmp5_6 , wtmp5_7;
wire [DW_DEC:0] wtmp5_8, wtmp5_9, wtmp5_10, wtmp5_11, wtmp5_12, wtmp5_13;
                   
wire [DW_DEC:0] wtmp6_1, wtmp6_2, wtmp6_3 , wtmp6_4 , wtmp6_5 , wtmp6_6 , wtmp6_7;
wire [DW_DEC:0] wtmp6_8, wtmp6_9, wtmp6_10, wtmp6_11, wtmp6_12, wtmp6_13;
                   
wire [DW_DEC:0] wtmp7_1, wtmp7_2, wtmp7_3 , wtmp7_4 , wtmp7_5 , wtmp7_6 , wtmp7_7;
wire [DW_DEC:0] wtmp7_8, wtmp7_9, wtmp7_10, wtmp7_11, wtmp7_12, wtmp7_13;       

wire [DW_IN*4-1:0] imosum_part1_1, imosum_part1_2, imosum_part1_3 , imosum_part1_4 , imosum_part1_5 , imosum_part1_6 , imosum_part1_7; 
wire [DW_IN*4-1:0] imosum_part1_8, imosum_part1_9, imosum_part1_10, imosum_part1_11, imosum_part1_12, imosum_part1_13;
                   
wire [DW_IN*4-1:0] imosum_part2_1, imosum_part2_2, imosum_part2_3 , imosum_part2_4 , imosum_part2_5 , imosum_part2_6 , imosum_part2_7; 
wire [DW_IN*4-1:0] imosum_part2_8, imosum_part2_9, imosum_part2_10, imosum_part2_11, imosum_part2_12, imosum_part2_13;
                   
wire [DW_IN*4-1:0] imosum_part3_1, imosum_part3_2, imosum_part3_3 , imosum_part3_4 , imosum_part3_5 , imosum_part3_6 , imosum_part3_7; 
wire [DW_IN*4-1:0] imosum_part3_8, imosum_part3_9, imosum_part3_10, imosum_part3_11, imosum_part3_12, imosum_part3_13;
                   
wire [DW_IN*4-1:0] imosum_part4_1, imosum_part4_2, imosum_part4_3 , imosum_part4_4 , imosum_part4_5 , imosum_part4_6 , imosum_part4_7; 
wire [DW_IN*4-1:0] imosum_part4_8, imosum_part4_9, imosum_part4_10, imosum_part4_11, imosum_part4_12, imosum_part4_13;
                   
wire [DW_IN*4-1:0] imosum_part5_1, imosum_part5_2, imosum_part5_3 , imosum_part5_4 , imosum_part5_5 , imosum_part5_6 , imosum_part5_7;
wire [DW_IN*4-1:0] imosum_part5_8, imosum_part5_9, imosum_part5_10, imosum_part5_11, imosum_part5_12, imosum_part5_13;
                   
wire [DW_IN*4-1:0] imosum_part6_1, imosum_part6_2, imosum_part6_3 , imosum_part6_4 , imosum_part6_5 , imosum_part6_6 , imosum_part6_7;
wire [DW_IN*4-1:0] imosum_part6_8, imosum_part6_9, imosum_part6_10, imosum_part6_11, imosum_part6_12, imosum_part6_13;
                   
wire [DW_IN*4-1:0] imosum_part7_1, imosum_part7_2, imosum_part7_3 , imosum_part7_4 , imosum_part7_5 , imosum_part7_6 , imosum_part7_7;
wire [DW_IN*4-1:0] imosum_part7_8, imosum_part7_9, imosum_part7_10, imosum_part7_11, imosum_part7_12, imosum_part7_13;  

reg [ARRAY_CALC_EN_DELAY-1:0] array_calc_en_delay;
wire imosum_part_valid;
reg [IMO1_CALC_EN_DELAY-1:0] imosum_part_valid_delay;

wire [DW_DEC:0] mcor1, mcor2, mcor3, mcor4;

reg  [DW_DEC:0] mcor1_delay [MCOR_DELAY-1:0];
wire [DW_DEC:0] mcor1_d;

reg  [DW_DEC:0] mcor2_delay [MCOR_DELAY-1:0];
wire [DW_DEC:0] mcor2_d;

reg  [DW_DEC:0] mcor3_delay [MCOR_DELAY-1:0];
wire [DW_DEC:0] mcor3_d;

reg  [DW_DEC:0] mcor4_delay [MCOR_DELAY-1:0];
wire [DW_DEC:0] mcor4_d;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_calc_en_delay <= {ARRAY_CALC_EN_DELAY{1'b0}};
else
    array_calc_en_delay <= {array_calc_en_delay[ARRAY_CALC_EN_DELAY-2:0], array_calc_en};
end

assign imosum_part_valid = array_calc_en_delay[ARRAY_CALC_EN_DELAY-1];

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imosum_part_valid_delay <= {IMO1_CALC_EN_DELAY{1'b0}};
else
    imosum_part_valid_delay <= {imosum_part_valid_delay[IMO1_CALC_EN_DELAY-2:0], imosum_part_valid};
end

assign imosum_valid = imosum_part_valid_delay[IMO1_CALC_EN_DELAY-1];

//imoy_i_j 2clk
imoy_m_calc U_imoy_m_calc0(
    .clk           (clk          ),
    .rst_n         (rst_n        ),
    .imcin         (array4_7     ),
    .imoy_m_calc_en(array_calc_en),
    .imoy_i_j      (imoy_i_j     ),  //output after 2clk
    .m_d           (m_d          ),
    .imcin_d       (imcin_d      )
);

//mcor calc 2 clk
tanhcurve U_tanhcurve_array_calc1(
    .clk  (clk  ),
    .rst_n(rst_n),

    .y1_0 (9'd0  ),.y1_1 (9'd0  ),.y1_2 (9'd0  ),.y1_3 (9'd0  ),.y1_4 (9'd0  ),.y1_5 (9'd0  ),.y1_6 (9'd0  ),.y1_7 (9'd0  ),.y1_8 (9'd0  ),.y1_9 (9'd0  ),.y1_10(9'd0  ),.y1_11(9'd0  ),.y1_12(9'd0  ),
    .y1_13(9'd0  ),.y1_14(9'd0  ),.y1_15(9'd1  ),.y1_16(9'd1  ),.y1_17(9'd1  ),.y1_18(9'd1  ),.y1_19(9'd2  ),.y1_20(9'd2  ),.y1_21(9'd3  ),.y1_22(9'd4  ),.y1_23(9'd5  ),.y1_24(9'd7  ),.y1_25(9'd9  ),
    .y1_26(9'd11 ),.y1_27(9'd15 ),.y1_28(9'd19 ),.y1_29(9'd24 ),.y1_30(9'd31 ),.y1_31(9'd38 ),.y1_32(9'd48 ),.y1_33(9'd59 ),.y1_34(9'd72 ),.y1_35(9'd87 ),.y1_36(9'd103),.y1_37(9'd119),.y1_38(9'd137),
    .y1_39(9'd153),.y1_40(9'd169),.y1_41(9'd184),.y1_42(9'd197),.y1_43(9'd208),.y1_44(9'd218),.y1_45(9'd225),.y1_46(9'd232),.y1_47(9'd237),.y1_48(9'd241),.y1_49(9'd245),.y1_50(9'd247),.y1_51(9'd249),
    .y1_52(9'd251),.y1_53(9'd252),.y1_54(9'd253),.y1_55(9'd254),.y1_56(9'd254),.y1_57(9'd255),.y1_58(9'd255),.y1_59(9'd255),.y1_60(9'd255),.y1_61(9'd256),.y1_62(9'd256),.y1_63(9'd256),.y1_64(9'd256),

    .in    (array4_7[DW_IN*4-1:DW_IN*3]),
    .out_d2(mcor1                      )    
);

tanhcurve U_tanhcurve_array_calc2(
    .clk  (clk  ),
    .rst_n(rst_n),

    .y1_0 (9'd0  ),.y1_1 (9'd0  ),.y1_2 (9'd0  ),.y1_3 (9'd0  ),.y1_4 (9'd0  ),.y1_5 (9'd0  ),.y1_6 (9'd0  ),.y1_7 (9'd0  ),.y1_8 (9'd0  ),.y1_9 (9'd0  ),.y1_10(9'd0  ),.y1_11(9'd0  ),.y1_12(9'd0  ),
    .y1_13(9'd0  ),.y1_14(9'd0  ),.y1_15(9'd1  ),.y1_16(9'd1  ),.y1_17(9'd1  ),.y1_18(9'd1  ),.y1_19(9'd2  ),.y1_20(9'd2  ),.y1_21(9'd3  ),.y1_22(9'd4  ),.y1_23(9'd5  ),.y1_24(9'd7  ),.y1_25(9'd9  ),
    .y1_26(9'd11 ),.y1_27(9'd15 ),.y1_28(9'd19 ),.y1_29(9'd24 ),.y1_30(9'd31 ),.y1_31(9'd38 ),.y1_32(9'd48 ),.y1_33(9'd59 ),.y1_34(9'd72 ),.y1_35(9'd87 ),.y1_36(9'd103),.y1_37(9'd119),.y1_38(9'd137),
    .y1_39(9'd153),.y1_40(9'd169),.y1_41(9'd184),.y1_42(9'd197),.y1_43(9'd208),.y1_44(9'd218),.y1_45(9'd225),.y1_46(9'd232),.y1_47(9'd237),.y1_48(9'd241),.y1_49(9'd245),.y1_50(9'd247),.y1_51(9'd249),
    .y1_52(9'd251),.y1_53(9'd252),.y1_54(9'd253),.y1_55(9'd254),.y1_56(9'd254),.y1_57(9'd255),.y1_58(9'd255),.y1_59(9'd255),.y1_60(9'd255),.y1_61(9'd256),.y1_62(9'd256),.y1_63(9'd256),.y1_64(9'd256),

    .in    (array4_7[DW_IN*3-1:DW_IN*2]),
    .out_d2(mcor2                      )    
);

tanhcurve U_tanhcurve_array_calc3(
    .clk  (clk  ),
    .rst_n(rst_n),

    .y1_0 (9'd0  ),.y1_1 (9'd0  ),.y1_2 (9'd0  ),.y1_3 (9'd0  ),.y1_4 (9'd0  ),.y1_5 (9'd0  ),.y1_6 (9'd0  ),.y1_7 (9'd0  ),.y1_8 (9'd0  ),.y1_9 (9'd0  ),.y1_10(9'd0  ),.y1_11(9'd0  ),.y1_12(9'd0  ),
    .y1_13(9'd0  ),.y1_14(9'd0  ),.y1_15(9'd1  ),.y1_16(9'd1  ),.y1_17(9'd1  ),.y1_18(9'd1  ),.y1_19(9'd2  ),.y1_20(9'd2  ),.y1_21(9'd3  ),.y1_22(9'd4  ),.y1_23(9'd5  ),.y1_24(9'd7  ),.y1_25(9'd9  ),
    .y1_26(9'd11 ),.y1_27(9'd15 ),.y1_28(9'd19 ),.y1_29(9'd24 ),.y1_30(9'd31 ),.y1_31(9'd38 ),.y1_32(9'd48 ),.y1_33(9'd59 ),.y1_34(9'd72 ),.y1_35(9'd87 ),.y1_36(9'd103),.y1_37(9'd119),.y1_38(9'd137),
    .y1_39(9'd153),.y1_40(9'd169),.y1_41(9'd184),.y1_42(9'd197),.y1_43(9'd208),.y1_44(9'd218),.y1_45(9'd225),.y1_46(9'd232),.y1_47(9'd237),.y1_48(9'd241),.y1_49(9'd245),.y1_50(9'd247),.y1_51(9'd249),
    .y1_52(9'd251),.y1_53(9'd252),.y1_54(9'd253),.y1_55(9'd254),.y1_56(9'd254),.y1_57(9'd255),.y1_58(9'd255),.y1_59(9'd255),.y1_60(9'd255),.y1_61(9'd256),.y1_62(9'd256),.y1_63(9'd256),.y1_64(9'd256),

    .in    (array4_7[DW_IN*2-1:DW_IN]),
    .out_d2(mcor3                    )    
);

tanhcurve U_tanhcurve_array_calc4(
    .clk  (clk  ),
    .rst_n(rst_n),

    .y1_0 (9'd0  ),.y1_1 (9'd0  ),.y1_2 (9'd0  ),.y1_3 (9'd0  ),.y1_4 (9'd0  ),.y1_5 (9'd0  ),.y1_6 (9'd0  ),.y1_7 (9'd0  ),.y1_8 (9'd0  ),.y1_9 (9'd0  ),.y1_10(9'd0  ),.y1_11(9'd0  ),.y1_12(9'd0  ),
    .y1_13(9'd0  ),.y1_14(9'd0  ),.y1_15(9'd1  ),.y1_16(9'd1  ),.y1_17(9'd1  ),.y1_18(9'd1  ),.y1_19(9'd2  ),.y1_20(9'd2  ),.y1_21(9'd3  ),.y1_22(9'd4  ),.y1_23(9'd5  ),.y1_24(9'd7  ),.y1_25(9'd9  ),
    .y1_26(9'd11 ),.y1_27(9'd15 ),.y1_28(9'd19 ),.y1_29(9'd24 ),.y1_30(9'd31 ),.y1_31(9'd38 ),.y1_32(9'd48 ),.y1_33(9'd59 ),.y1_34(9'd72 ),.y1_35(9'd87 ),.y1_36(9'd103),.y1_37(9'd119),.y1_38(9'd137),
    .y1_39(9'd153),.y1_40(9'd169),.y1_41(9'd184),.y1_42(9'd197),.y1_43(9'd208),.y1_44(9'd218),.y1_45(9'd225),.y1_46(9'd232),.y1_47(9'd237),.y1_48(9'd241),.y1_49(9'd245),.y1_50(9'd247),.y1_51(9'd249),
    .y1_52(9'd251),.y1_53(9'd252),.y1_54(9'd253),.y1_55(9'd254),.y1_56(9'd254),.y1_57(9'd255),.y1_58(9'd255),.y1_59(9'd255),.y1_60(9'd255),.y1_61(9'd256),.y1_62(9'd256),.y1_63(9'd256),.y1_64(9'd256),

    .in    (array4_7[DW_IN-1:0]),
    .out_d2(mcor4              )    
);

//mcor delay
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i <= MCOR_DELAY-1; i = i+1) begin
            mcor1_delay[i] <= {(DW_DEC+1){1'b0}};
        end
    end
    else begin
        for(i = MCOR_DELAY-1; i > 0; i = i-1) begin
            mcor1_delay[i] <= mcor1_delay[i-1];
        end
        mcor1_delay[0] <= mcor1;
    end
end

assign mcor1_d = mcor1_delay[MCOR_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i <= MCOR_DELAY-1; i = i+1) begin
            mcor2_delay[i] <= {(DW_DEC+1){1'b0}};
        end
    end
    else begin
        for(i = MCOR_DELAY-1; i > 0; i = i-1) begin
            mcor2_delay[i] <= mcor2_delay[i-1];
        end
        mcor2_delay[0] <= mcor2;
    end
end

assign mcor2_d = mcor2_delay[MCOR_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i <= MCOR_DELAY-1; i = i+1) begin
            mcor3_delay[i] <= {(DW_DEC+1){1'b0}};
        end
    end
    else begin
        for(i = MCOR_DELAY-1; i > 0; i = i-1) begin
            mcor3_delay[i] <= mcor3_delay[i-1];
        end
        mcor3_delay[0] <= mcor3;
    end
end

assign mcor3_d = mcor3_delay[MCOR_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i <= MCOR_DELAY-1; i = i+1) begin
            mcor4_delay[i] <= {(DW_DEC+1){1'b0}};
        end
    end
    else begin
        for(i = MCOR_DELAY-1; i > 0; i = i-1) begin
            mcor4_delay[i] <= mcor4_delay[i-1];
        end
        mcor4_delay[0] <= mcor4;
    end
end

assign mcor4_d = mcor4_delay[MCOR_DELAY-1];

//imosum_part calc
traverse_mask U_traverse_mask1_1(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array1_1      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd12         ),
    .wtmp           (wtmp1_1       ),
    .imosum_part    (imosum_part1_1)
);

traverse_mask U_traverse_mask1_2(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array1_2      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd10         ),
    .wtmp           (wtmp1_2       ),
    .imosum_part    (imosum_part1_2)
);

traverse_mask U_traverse_mask1_3(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array1_3      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd8          ),
    .wtmp           (wtmp1_3       ),
    .imosum_part    (imosum_part1_3)
);

traverse_mask U_traverse_mask1_4(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array1_4      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd6          ),
    .wtmp           (wtmp1_4       ),
    .imosum_part    (imosum_part1_4)
);

traverse_mask U_traverse_mask1_5(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array1_5      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp1_5       ),
    .imosum_part    (imosum_part1_5)
);

traverse_mask U_traverse_mask1_6(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array1_6      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp1_6       ),
    .imosum_part    (imosum_part1_6)
);

traverse_mask U_traverse_mask1_7(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array1_7      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd0          ),
    .wtmp           (wtmp1_7       ),
    .imosum_part    (imosum_part1_7)
);

traverse_mask U_traverse_mask1_8(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array1_8      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp1_8       ),
    .imosum_part    (imosum_part1_8)
);

traverse_mask U_traverse_mask1_9(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array1_9      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp1_9       ),
    .imosum_part    (imosum_part1_9)
);

traverse_mask U_traverse_mask1_10(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array1_10      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd6           ),
    .jj_diff        (4'd6           ),
    .wtmp           (wtmp1_10       ),
    .imosum_part    (imosum_part1_10)
);

traverse_mask U_traverse_mask1_11(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array1_11      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd6           ),
    .jj_diff        (4'd8           ),
    .wtmp           (wtmp1_11       ),
    .imosum_part    (imosum_part1_11)
);

traverse_mask U_traverse_mask1_12(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array1_12      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd6           ),
    .jj_diff        (4'd10           ),
    .wtmp           (wtmp1_12       ),
    .imosum_part    (imosum_part1_12)
);

traverse_mask U_traverse_mask1_13(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array1_13      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd6           ),
    .jj_diff        (4'd12          ),
    .wtmp           (wtmp1_13       ),
    .imosum_part    (imosum_part1_13)
);

traverse_mask U_traverse_mask2_1(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array2_1      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd12         ),
    .wtmp           (wtmp2_1       ),
    .imosum_part    (imosum_part2_1)
);

traverse_mask U_traverse_mask2_2(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array2_2      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd10         ),
    .wtmp           (wtmp2_2       ),
    .imosum_part    (imosum_part2_2)
);

traverse_mask U_traverse_mask2_3(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array2_3      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd8          ),
    .wtmp           (wtmp2_3       ),
    .imosum_part    (imosum_part2_3)
);

traverse_mask U_traverse_mask2_4(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array2_4      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd6          ),
    .wtmp           (wtmp2_4       ),
    .imosum_part    (imosum_part2_4)
);

traverse_mask U_traverse_mask2_5(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array2_5      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp2_5       ),
    .imosum_part    (imosum_part2_5)
);

traverse_mask U_traverse_mask2_6(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array2_6      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp2_6       ),
    .imosum_part    (imosum_part2_6)
);

traverse_mask U_traverse_mask2_7(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array2_7      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd0          ),
    .wtmp           (wtmp2_7       ),
    .imosum_part    (imosum_part2_7)
);

traverse_mask U_traverse_mask2_8(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array2_8      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp2_8       ),
    .imosum_part    (imosum_part2_8)
);

traverse_mask U_traverse_mask2_9(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array2_9      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp2_9       ),
    .imosum_part    (imosum_part2_9)
);

traverse_mask U_traverse_mask2_10(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array2_10      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd4           ),
    .jj_diff        (4'd6           ),
    .wtmp           (wtmp2_10       ),
    .imosum_part    (imosum_part2_10)
);

traverse_mask U_traverse_mask2_11(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array2_11      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd4           ),
    .jj_diff        (4'd8           ),
    .wtmp           (wtmp2_11       ),
    .imosum_part    (imosum_part2_11)
);

traverse_mask U_traverse_mask2_12(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array2_12      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd4           ),
    .jj_diff        (4'd10          ),
    .wtmp           (wtmp2_12       ),
    .imosum_part    (imosum_part2_12)
);

traverse_mask U_traverse_mask2_13(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array2_13      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd4           ),
    .jj_diff        (4'd12          ),
    .wtmp           (wtmp2_13       ),
    .imosum_part    (imosum_part2_13)
);

traverse_mask U_traverse_mask3_1(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array3_1      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd12         ),
    .wtmp           (wtmp3_1       ),
    .imosum_part    (imosum_part3_1)
);

traverse_mask U_traverse_mask3_2(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array3_2      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd10         ),
    .wtmp           (wtmp3_2       ),
    .imosum_part    (imosum_part3_2)
);

traverse_mask U_traverse_mask3_3(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array3_3      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd8          ),
    .wtmp           (wtmp3_3       ),
    .imosum_part    (imosum_part3_3)
);

traverse_mask U_traverse_mask3_4(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array3_4      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd6          ),
    .wtmp           (wtmp3_4       ),
    .imosum_part    (imosum_part3_4)
);

traverse_mask U_traverse_mask3_5(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array3_5      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp3_5       ),
    .imosum_part    (imosum_part3_5)
);

traverse_mask U_traverse_mask3_6(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array3_6      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp3_6       ),
    .imosum_part    (imosum_part3_6)
);

traverse_mask U_traverse_mask3_7(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array3_7      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd0          ),
    .wtmp           (wtmp3_7       ),
    .imosum_part    (imosum_part3_7)
);

traverse_mask U_traverse_mask3_8(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array3_8      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp3_8       ),
    .imosum_part    (imosum_part3_8)
);

traverse_mask U_traverse_mask3_9(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array3_9      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp3_9       ),
    .imosum_part    (imosum_part3_9)
);

traverse_mask U_traverse_mask3_10(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array3_10      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd2           ),
    .jj_diff        (4'd6           ),
    .wtmp           (wtmp3_10       ),
    .imosum_part    (imosum_part3_10)
);

traverse_mask U_traverse_mask3_11(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array3_11      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd2           ),
    .jj_diff        (4'd8           ),
    .wtmp           (wtmp3_11       ),
    .imosum_part    (imosum_part3_11)
);

traverse_mask U_traverse_mask3_12(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array3_12      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd2           ),
    .jj_diff        (4'd10          ),
    .wtmp           (wtmp3_12       ),
    .imosum_part    (imosum_part3_12)
);

traverse_mask U_traverse_mask3_13(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array3_13      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd2           ),
    .jj_diff        (4'd12          ),
    .wtmp           (wtmp3_13       ),
    .imosum_part    (imosum_part3_13)
);

traverse_mask U_traverse_mask4_1(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array4_1      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd0          ),
    .jj_diff        (4'd12         ),
    .wtmp           (wtmp4_1       ),
    .imosum_part    (imosum_part4_1)
);

traverse_mask U_traverse_mask4_2(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array4_2      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd0          ),
    .jj_diff        (4'd10         ),
    .wtmp           (wtmp4_2       ),
    .imosum_part    (imosum_part4_2)
);

traverse_mask U_traverse_mask4_3(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array4_3      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd0          ),
    .jj_diff        (4'd8          ),
    .wtmp           (wtmp4_3       ),
    .imosum_part    (imosum_part4_3)
);

traverse_mask U_traverse_mask4_4(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array4_4      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd0          ),
    .jj_diff        (4'd6          ),
    .wtmp           (wtmp4_4       ),
    .imosum_part    (imosum_part4_4)
);

traverse_mask U_traverse_mask4_5(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array4_5      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd0          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp4_5       ),
    .imosum_part    (imosum_part4_5)
);

traverse_mask U_traverse_mask4_6(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array4_6      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd0          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp4_6       ),
    .imosum_part    (imosum_part4_6)
);

traverse_mask U_traverse_mask4_8(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array4_8      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd0          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp4_8       ),
    .imosum_part    (imosum_part4_8)
);

traverse_mask U_traverse_mask4_9(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array4_9      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd0          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp4_9       ),
    .imosum_part    (imosum_part4_9)
);

traverse_mask U_traverse_mask4_10(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array4_10      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd0           ),
    .jj_diff        (4'd6           ),
    .wtmp           (wtmp4_10       ),
    .imosum_part    (imosum_part4_10)
);

traverse_mask U_traverse_mask4_11(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array4_11      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd0           ),
    .jj_diff        (4'd8           ),
    .wtmp           (wtmp4_11       ),
    .imosum_part    (imosum_part4_11)
);

traverse_mask U_traverse_mask4_12(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array4_12      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd0           ),
    .jj_diff        (4'd10          ),
    .wtmp           (wtmp4_12       ),
    .imosum_part    (imosum_part4_12)
);

traverse_mask U_traverse_mask4_13(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array4_13      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd0           ),
    .jj_diff        (4'd12          ),
    .wtmp           (wtmp4_13       ),
    .imosum_part    (imosum_part4_13)
);

traverse_mask U_traverse_mask5_1(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array5_1      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd12         ),
    .wtmp           (wtmp5_1       ),
    .imosum_part    (imosum_part5_1)
);

traverse_mask U_traverse_mask5_2(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array5_2      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd10         ),
    .wtmp           (wtmp5_2       ),
    .imosum_part    (imosum_part5_2)
);

traverse_mask U_traverse_mask5_3(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array5_3      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd8          ),
    .wtmp           (wtmp5_3       ),
    .imosum_part    (imosum_part5_3)
);

traverse_mask U_traverse_mask5_4(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array5_4      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd6          ),
    .wtmp           (wtmp5_4       ),
    .imosum_part    (imosum_part5_4)
);

traverse_mask U_traverse_mask5_5(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array5_5      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp5_5       ),
    .imosum_part    (imosum_part5_5)
);

traverse_mask U_traverse_mask5_6(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array5_6      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp5_6       ),
    .imosum_part    (imosum_part5_6)
);

traverse_mask U_traverse_mask5_7(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array5_7      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd0          ),
    .wtmp           (wtmp5_7       ),
    .imosum_part    (imosum_part5_7)
);

traverse_mask U_traverse_mask5_8(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array5_8      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp5_8       ),
    .imosum_part    (imosum_part5_8)
);

traverse_mask U_traverse_mask5_9(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array5_9      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd2          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp5_9       ),
    .imosum_part    (imosum_part5_9)
);

traverse_mask U_traverse_mask5_10(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array5_10      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd2           ),
    .jj_diff        (4'd6           ),
    .wtmp           (wtmp5_10       ),
    .imosum_part    (imosum_part5_10)
);

traverse_mask U_traverse_mask5_11(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array5_11      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd2           ),
    .jj_diff        (4'd8           ),
    .wtmp           (wtmp5_11       ),
    .imosum_part    (imosum_part5_11)
);

traverse_mask U_traverse_mask5_12(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array5_12      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd2           ),
    .jj_diff        (4'd10          ),
    .wtmp           (wtmp5_12       ),
    .imosum_part    (imosum_part5_12)
);

traverse_mask U_traverse_mask5_13(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array5_13      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd2           ),
    .jj_diff        (4'd12          ),
    .wtmp           (wtmp5_13       ),
    .imosum_part    (imosum_part5_13)
);

traverse_mask U_traverse_mask6_1(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array6_1      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd12         ),
    .wtmp           (wtmp6_1       ),
    .imosum_part    (imosum_part6_1)
);

traverse_mask U_traverse_mask6_2(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array6_2      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd10         ),
    .wtmp           (wtmp6_2       ),
    .imosum_part    (imosum_part6_2)
);

traverse_mask U_traverse_mask6_3(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array6_3      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd8          ),
    .wtmp           (wtmp6_3       ),
    .imosum_part    (imosum_part6_3)
);

traverse_mask U_traverse_mask6_4(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array6_4      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd6          ),
    .wtmp           (wtmp6_4       ),
    .imosum_part    (imosum_part6_4)
);

traverse_mask U_traverse_mask6_5(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array6_5      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp6_5       ),
    .imosum_part    (imosum_part6_5)
);

traverse_mask U_traverse_mask6_6(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array6_6      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp6_6       ),
    .imosum_part    (imosum_part6_6)
);

traverse_mask U_traverse_mask6_7(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array6_7      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd0          ),
    .wtmp           (wtmp6_7       ),
    .imosum_part    (imosum_part6_7)
);

traverse_mask U_traverse_mask6_8(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array6_8      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp6_8       ),
    .imosum_part    (imosum_part6_8)
);

traverse_mask U_traverse_mask6_9(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array6_9      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd4          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp6_9       ),
    .imosum_part    (imosum_part6_9)
);

traverse_mask U_traverse_mask6_10(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array6_10      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd4           ),
    .jj_diff        (4'd6           ),
    .wtmp           (wtmp6_10       ),
    .imosum_part    (imosum_part6_10)
);

traverse_mask U_traverse_mask6_11(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array6_11      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd4           ),
    .jj_diff        (4'd8           ),
    .wtmp           (wtmp6_11       ),
    .imosum_part    (imosum_part6_11)
);

traverse_mask U_traverse_mask6_12(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array6_12      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd4           ),
    .jj_diff        (4'd10          ),
    .wtmp           (wtmp6_12       ),
    .imosum_part    (imosum_part6_12)
);

traverse_mask U_traverse_mask6_13(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array6_13      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd4           ),
    .jj_diff        (4'd12          ),
    .wtmp           (wtmp6_13       ),
    .imosum_part    (imosum_part6_13)
);

traverse_mask U_traverse_mask7_1(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array7_1      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd12         ),
    .wtmp           (wtmp7_1       ),
    .imosum_part    (imosum_part7_1)
);


traverse_mask U_traverse_mask7_2(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array7_2      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd10         ),
    .wtmp           (wtmp7_2       ),
    .imosum_part    (imosum_part7_2)
);

traverse_mask U_traverse_mask7_3(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array7_3      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd8          ),
    .wtmp           (wtmp7_3       ),
    .imosum_part    (imosum_part7_3)
);

traverse_mask U_traverse_mask7_4(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array7_4      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd6          ),
    .wtmp           (wtmp7_4       ),
    .imosum_part    (imosum_part7_4)
);

traverse_mask U_traverse_mask7_5(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array7_5      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp7_5       ),
    .imosum_part    (imosum_part7_5)
);

traverse_mask U_traverse_mask7_6(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array7_6      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp7_6       ),
    .imosum_part    (imosum_part7_6)
);

traverse_mask U_traverse_mask7_7(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array7_7      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd0          ),
    .wtmp           (wtmp7_7       ),
    .imosum_part    (imosum_part7_7)
);

traverse_mask U_traverse_mask7_8(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array7_8      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd2          ),
    .wtmp           (wtmp7_8       ),
    .imosum_part    (imosum_part7_8)
);

traverse_mask U_traverse_mask7_9(
    .clk            (clk           ),
    .rst_n          (rst_n         ),
    .imowsum_calc_en(array_calc_en ),
    .imo_ii_jj      (array7_9      ),
    .imo_i_j        (array4_7      ),
    .imoy_i_j       (imoy_i_j      ),
    .ii_diff        (3'd6          ),
    .jj_diff        (4'd4          ),
    .wtmp           (wtmp7_9       ),
    .imosum_part    (imosum_part7_9)
);

traverse_mask U_traverse_mask7_10(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array7_10      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd6           ),
    .jj_diff        (4'd6           ),
    .wtmp           (wtmp7_10       ),
    .imosum_part    (imosum_part7_10)
);

traverse_mask U_traverse_mask7_11(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array7_11      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd6           ),
    .jj_diff        (4'd8           ),
    .wtmp           (wtmp7_11       ),
    .imosum_part    (imosum_part7_11)
);

traverse_mask U_traverse_mask7_12(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array7_12      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd6           ),
    .jj_diff        (4'd10          ),
    .wtmp           (wtmp7_12       ),
    .imosum_part    (imosum_part7_12)
);

traverse_mask U_traverse_mask7_13(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .imowsum_calc_en(array_calc_en  ),
    .imo_ii_jj      (array7_13      ),
    .imo_i_j        (array4_7       ),
    .imoy_i_j       (imoy_i_j       ),
    .ii_diff        (3'd6           ),
    .jj_diff        (4'd12          ),
    .wtmp           (wtmp7_13       ),
    .imosum_part    (imosum_part7_13)
);

wire [DW_DEC+7:0] imowsum;
wire [DW_IN+6 :0] imosum1, imosum2, imosum3, imosum4;

sum90 U_sum90_imowsum(
    .clk  (clk  ),
    .rst_n(rst_n),
    .in1_1(wtmp1_1), .in1_2(wtmp1_2), .in1_3(wtmp1_3), .in1_4(wtmp1_4), .in1_5(wtmp1_5), .in1_6(wtmp1_6), 
    .in1_7(wtmp1_7), .in1_8(wtmp1_8), .in1_9(wtmp1_9), .in1_10(wtmp1_10), .in1_11(wtmp1_11), .in1_12(wtmp1_12), .in1_13(wtmp1_13),
    .in2_1(wtmp2_1), .in2_2(wtmp2_2), .in2_3(wtmp2_3), .in2_4(wtmp2_4), .in2_5(wtmp2_5), .in2_6(wtmp2_6), 
    .in2_7(wtmp2_7), .in2_8(wtmp2_8), .in2_9(wtmp2_9), .in2_10(wtmp2_10), .in2_11(wtmp2_11), .in2_12(wtmp2_12), .in2_13(wtmp2_13),
    .in3_1(wtmp3_1), .in3_2(wtmp3_2), .in3_3(wtmp3_3), .in3_4(wtmp3_4), .in3_5(wtmp3_5), .in3_6(wtmp3_6), 
    .in3_7(wtmp3_7), .in3_8(wtmp3_8), .in3_9(wtmp3_9), .in3_10(wtmp3_10), .in3_11(wtmp3_11), .in3_12(wtmp3_12), .in3_13(wtmp3_13),
    .in4_1(wtmp4_1), .in4_2(wtmp4_2), .in4_3(wtmp4_3), .in4_4(wtmp4_4), .in4_5(wtmp4_5), .in4_6(wtmp4_6),                  
    .in4_8(wtmp4_8), .in4_9(wtmp4_9), .in4_10(wtmp4_10), .in4_11(wtmp4_11), .in4_12(wtmp4_12), .in4_13(wtmp4_13),
    .in5_1(wtmp5_1), .in5_2(wtmp5_2), .in5_3(wtmp5_3), .in5_4(wtmp5_4), .in5_5(wtmp5_5), .in5_6(wtmp5_6), 
    .in5_7(wtmp5_7), .in5_8(wtmp5_8), .in5_9(wtmp5_9), .in5_10(wtmp5_10), .in5_11(wtmp5_11), .in5_12(wtmp5_12), .in5_13(wtmp5_13),
    .in6_1(wtmp6_1), .in6_2(wtmp6_2), .in6_3(wtmp6_3), .in6_4(wtmp6_4), .in6_5(wtmp6_5), .in6_6(wtmp6_6), 
    .in6_7(wtmp6_7), .in6_8(wtmp6_8), .in6_9(wtmp6_9), .in6_10(wtmp6_10), .in6_11(wtmp6_11), .in6_12(wtmp6_12), .in6_13(wtmp6_13),
    .in7_1(wtmp7_1), .in7_2(wtmp7_2), .in7_3(wtmp7_3), .in7_4(wtmp7_4), .in7_5(wtmp7_5), .in7_6(wtmp7_6), 
    .in7_7(wtmp7_7), .in7_8(wtmp7_8), .in7_9(wtmp7_9), .in7_10(wtmp7_10), .in7_11(wtmp7_11), .in7_12(wtmp7_12), .in7_13(wtmp7_13),
    .sum90_en(imosum_part_valid),
    .sum90   (imowsum          ) //output imowsum
);

sum90 #(
    .DW_PART(10)
)U_sum90_imosum1(
    .clk  (clk  ),
    .rst_n(rst_n),
    .in1_1(imosum_part1_1[DW_IN*4-1:DW_IN*3]), .in1_2(imosum_part1_2[DW_IN*4-1:DW_IN*3]), .in1_3(imosum_part1_3[DW_IN*4-1:DW_IN*3]), 
    .in1_4(imosum_part1_4[DW_IN*4-1:DW_IN*3]), .in1_5(imosum_part1_5[DW_IN*4-1:DW_IN*3]), .in1_6(imosum_part1_6[DW_IN*4-1:DW_IN*3]), 
    .in1_7(imosum_part1_7[DW_IN*4-1:DW_IN*3]), .in1_8(imosum_part1_8[DW_IN*4-1:DW_IN*3]), .in1_9(imosum_part1_9[DW_IN*4-1:DW_IN*3]), 
    .in1_10(imosum_part1_10[DW_IN*4-1:DW_IN*3]), .in1_11(imosum_part1_11[DW_IN*4-1:DW_IN*3]), .in1_12(imosum_part1_12[DW_IN*4-1:DW_IN*3]), .in1_13(imosum_part1_13[DW_IN*4-1:DW_IN*3]),
    .in2_1(imosum_part2_1[DW_IN*4-1:DW_IN*3]), .in2_2(imosum_part2_2[DW_IN*4-1:DW_IN*3]), .in2_3(imosum_part2_3[DW_IN*4-1:DW_IN*3]), 
    .in2_4(imosum_part2_4[DW_IN*4-1:DW_IN*3]), .in2_5(imosum_part2_5[DW_IN*4-1:DW_IN*3]), .in2_6(imosum_part2_6[DW_IN*4-1:DW_IN*3]), 
    .in2_7(imosum_part2_7[DW_IN*4-1:DW_IN*3]), .in2_8(imosum_part2_8[DW_IN*4-1:DW_IN*3]), .in2_9(imosum_part2_9[DW_IN*4-1:DW_IN*3]), 
    .in2_10(imosum_part2_10[DW_IN*4-1:DW_IN*3]), .in2_11(imosum_part2_11[DW_IN*4-1:DW_IN*3]), .in2_12(imosum_part2_12[DW_IN*4-1:DW_IN*3]), .in2_13(imosum_part2_13[DW_IN*4-1:DW_IN*3]),
    .in3_1(imosum_part3_1[DW_IN*4-1:DW_IN*3]), .in3_2(imosum_part3_2[DW_IN*4-1:DW_IN*3]), .in3_3(imosum_part3_3[DW_IN*4-1:DW_IN*3]), 
    .in3_4(imosum_part3_4[DW_IN*4-1:DW_IN*3]), .in3_5(imosum_part3_5[DW_IN*4-1:DW_IN*3]), .in3_6(imosum_part3_6[DW_IN*4-1:DW_IN*3]), 
    .in3_7(imosum_part3_7[DW_IN*4-1:DW_IN*3]), .in3_8(imosum_part3_8[DW_IN*4-1:DW_IN*3]), .in3_9(imosum_part3_9[DW_IN*4-1:DW_IN*3]), 
    .in3_10(imosum_part3_10[DW_IN*4-1:DW_IN*3]), .in3_11(imosum_part3_11[DW_IN*4-1:DW_IN*3]), .in3_12(imosum_part3_12[DW_IN*4-1:DW_IN*3]), .in3_13(imosum_part3_13[DW_IN*4-1:DW_IN*3]),
    .in4_1(imosum_part4_1[DW_IN*4-1:DW_IN*3]), .in4_2(imosum_part4_2[DW_IN*4-1:DW_IN*3]), .in4_3(imosum_part4_3[DW_IN*4-1:DW_IN*3]), 
    .in4_4(imosum_part4_4[DW_IN*4-1:DW_IN*3]), .in4_5(imosum_part4_5[DW_IN*4-1:DW_IN*3]), .in4_6(imosum_part4_6[DW_IN*4-1:DW_IN*3]),                  
    .in4_8(imosum_part4_8[DW_IN*4-1:DW_IN*3]), .in4_9(imosum_part4_9[DW_IN*4-1:DW_IN*3]), .in4_10(imosum_part4_10[DW_IN*4-1:DW_IN*3]), 
    .in4_11(imosum_part4_11[DW_IN*4-1:DW_IN*3]), .in4_12(imosum_part4_12[DW_IN*4-1:DW_IN*3]), .in4_13(imosum_part4_13[DW_IN*4-1:DW_IN*3]),
    .in5_1(imosum_part5_1[DW_IN*4-1:DW_IN*3]), .in5_2(imosum_part5_2[DW_IN*4-1:DW_IN*3]), .in5_3(imosum_part5_3[DW_IN*4-1:DW_IN*3]), 
    .in5_4(imosum_part5_4[DW_IN*4-1:DW_IN*3]), .in5_5(imosum_part5_5[DW_IN*4-1:DW_IN*3]), .in5_6(imosum_part5_6[DW_IN*4-1:DW_IN*3]), 
    .in5_7(imosum_part5_7[DW_IN*4-1:DW_IN*3]), .in5_8(imosum_part5_8[DW_IN*4-1:DW_IN*3]), .in5_9(imosum_part5_9[DW_IN*4-1:DW_IN*3]), 
    .in5_10(imosum_part5_10[DW_IN*4-1:DW_IN*3]), .in5_11(imosum_part5_11[DW_IN*4-1:DW_IN*3]), .in5_12(imosum_part5_12[DW_IN*4-1:DW_IN*3]), .in5_13(imosum_part5_13[DW_IN*4-1:DW_IN*3]),
    .in6_1(imosum_part6_1[DW_IN*4-1:DW_IN*3]), .in6_2(imosum_part6_2[DW_IN*4-1:DW_IN*3]), .in6_3(imosum_part6_3[DW_IN*4-1:DW_IN*3]), 
    .in6_4(imosum_part6_4[DW_IN*4-1:DW_IN*3]), .in6_5(imosum_part6_5[DW_IN*4-1:DW_IN*3]), .in6_6(imosum_part6_6[DW_IN*4-1:DW_IN*3]), 
    .in6_7(imosum_part6_7[DW_IN*4-1:DW_IN*3]), .in6_8(imosum_part6_8[DW_IN*4-1:DW_IN*3]), .in6_9(imosum_part6_9[DW_IN*4-1:DW_IN*3]), 
    .in6_10(imosum_part6_10[DW_IN*4-1:DW_IN*3]), .in6_11(imosum_part6_11[DW_IN*4-1:DW_IN*3]), .in6_12(imosum_part6_12[DW_IN*4-1:DW_IN*3]), .in6_13(imosum_part6_13[DW_IN*4-1:DW_IN*3]),
    .in7_1(imosum_part7_1[DW_IN*4-1:DW_IN*3]), .in7_2(imosum_part7_2[DW_IN*4-1:DW_IN*3]), .in7_3(imosum_part7_3[DW_IN*4-1:DW_IN*3]), 
    .in7_4(imosum_part7_4[DW_IN*4-1:DW_IN*3]), .in7_5(imosum_part7_5[DW_IN*4-1:DW_IN*3]), .in7_6(imosum_part7_6[DW_IN*4-1:DW_IN*3]), 
    .in7_7(imosum_part7_7[DW_IN*4-1:DW_IN*3]), .in7_8(imosum_part7_8[DW_IN*4-1:DW_IN*3]), .in7_9(imosum_part7_9[DW_IN*4-1:DW_IN*3]), 
    .in7_10(imosum_part7_10[DW_IN*4-1:DW_IN*3]), .in7_11(imosum_part7_11[DW_IN*4-1:DW_IN*3]), .in7_12(imosum_part7_12[DW_IN*4-1:DW_IN*3]), .in7_13(imosum_part7_13[DW_IN*4-1:DW_IN*3]),
    .sum90_en(imosum_part_valid),
    .sum90   (imosum1         )
);

sum90 #(
    .DW_PART(10)
)U_sum90_imosum2(
    .clk  (clk  ),
    .rst_n(rst_n),
    .in1_1(imosum_part1_1[DW_IN*3-1:DW_IN*2]), .in1_2(imosum_part1_2[DW_IN*3-1:DW_IN*2]), .in1_3(imosum_part1_3[DW_IN*3-1:DW_IN*2]),
    .in1_4(imosum_part1_4[DW_IN*3-1:DW_IN*2]), .in1_5(imosum_part1_5[DW_IN*3-1:DW_IN*2]), .in1_6(imosum_part1_6[DW_IN*3-1:DW_IN*2]),
    .in1_7(imosum_part1_7[DW_IN*3-1:DW_IN*2]), .in1_8(imosum_part1_8[DW_IN*3-1:DW_IN*2]), .in1_9(imosum_part1_9[DW_IN*3-1:DW_IN*2]),
    .in1_10(imosum_part1_10[DW_IN*3-1:DW_IN*2]), .in1_11(imosum_part1_11[DW_IN*3-1:DW_IN*2]), .in1_12(imosum_part1_12[DW_IN*3-1:DW_IN*2]), .in1_13(imosum_part1_13[DW_IN*3-1:DW_IN*2]),
    .in2_1(imosum_part2_1[DW_IN*3-1:DW_IN*2]), .in2_2(imosum_part2_2[DW_IN*3-1:DW_IN*2]), .in2_3(imosum_part2_3[DW_IN*3-1:DW_IN*2]),
    .in2_4(imosum_part2_4[DW_IN*3-1:DW_IN*2]), .in2_5(imosum_part2_5[DW_IN*3-1:DW_IN*2]), .in2_6(imosum_part2_6[DW_IN*3-1:DW_IN*2]),
    .in2_7(imosum_part2_7[DW_IN*3-1:DW_IN*2]), .in2_8(imosum_part2_8[DW_IN*3-1:DW_IN*2]), .in2_9(imosum_part2_9[DW_IN*3-1:DW_IN*2]),
    .in2_10(imosum_part2_10[DW_IN*3-1:DW_IN*2]), .in2_11(imosum_part2_11[DW_IN*3-1:DW_IN*2]), .in2_12(imosum_part2_12[DW_IN*3-1:DW_IN*2]), .in2_13(imosum_part2_13[DW_IN*3-1:DW_IN*2]),
    .in3_1(imosum_part3_1[DW_IN*3-1:DW_IN*2]), .in3_2(imosum_part3_2[DW_IN*3-1:DW_IN*2]), .in3_3(imosum_part3_3[DW_IN*3-1:DW_IN*2]), 
    .in3_4(imosum_part3_4[DW_IN*3-1:DW_IN*2]), .in3_5(imosum_part3_5[DW_IN*3-1:DW_IN*2]), .in3_6(imosum_part3_6[DW_IN*3-1:DW_IN*2]), 
    .in3_7(imosum_part3_7[DW_IN*3-1:DW_IN*2]), .in3_8(imosum_part3_8[DW_IN*3-1:DW_IN*2]), .in3_9(imosum_part3_9[DW_IN*3-1:DW_IN*2]), 
    .in3_10(imosum_part3_10[DW_IN*3-1:DW_IN*2]), .in3_11(imosum_part3_11[DW_IN*3-1:DW_IN*2]), .in3_12(imosum_part3_12[DW_IN*3-1:DW_IN*2]), .in3_13(imosum_part3_13[DW_IN*3-1:DW_IN*2]),
    .in4_1(imosum_part4_1[DW_IN*3-1:DW_IN*2]), .in4_2(imosum_part4_2[DW_IN*3-1:DW_IN*2]), .in4_3(imosum_part4_3[DW_IN*3-1:DW_IN*2]),
    .in4_4(imosum_part4_4[DW_IN*3-1:DW_IN*2]), .in4_5(imosum_part4_5[DW_IN*3-1:DW_IN*2]), .in4_6(imosum_part4_6[DW_IN*3-1:DW_IN*2]),                  
    .in4_8(imosum_part4_8[DW_IN*3-1:DW_IN*2]), .in4_9(imosum_part4_9[DW_IN*3-1:DW_IN*2]), .in4_10(imosum_part4_10[DW_IN*3-1:DW_IN*2]), 
    .in4_11(imosum_part4_11[DW_IN*3-1:DW_IN*2]), .in4_12(imosum_part4_12[DW_IN*3-1:DW_IN*2]), .in4_13(imosum_part4_13[DW_IN*3-1:DW_IN*2]),
    .in5_1(imosum_part5_1[DW_IN*3-1:DW_IN*2]), .in5_2(imosum_part5_2[DW_IN*3-1:DW_IN*2]), .in5_3(imosum_part5_3[DW_IN*3-1:DW_IN*2]), 
    .in5_4(imosum_part5_4[DW_IN*3-1:DW_IN*2]), .in5_5(imosum_part5_5[DW_IN*3-1:DW_IN*2]), .in5_6(imosum_part5_6[DW_IN*3-1:DW_IN*2]), 
    .in5_7(imosum_part5_7[DW_IN*3-1:DW_IN*2]), .in5_8(imosum_part5_8[DW_IN*3-1:DW_IN*2]), .in5_9(imosum_part5_9[DW_IN*3-1:DW_IN*2]), 
    .in5_10(imosum_part5_10[DW_IN*3-1:DW_IN*2]), .in5_11(imosum_part5_11[DW_IN*3-1:DW_IN*2]), .in5_12(imosum_part5_12[DW_IN*3-1:DW_IN*2]), .in5_13(imosum_part5_13[DW_IN*3-1:DW_IN*2]),
    .in6_1(imosum_part6_1[DW_IN*3-1:DW_IN*2]), .in6_2(imosum_part6_2[DW_IN*3-1:DW_IN*2]), .in6_3(imosum_part6_3[DW_IN*3-1:DW_IN*2]), 
    .in6_4(imosum_part6_4[DW_IN*3-1:DW_IN*2]), .in6_5(imosum_part6_5[DW_IN*3-1:DW_IN*2]), .in6_6(imosum_part6_6[DW_IN*3-1:DW_IN*2]), 
    .in6_7(imosum_part6_7[DW_IN*3-1:DW_IN*2]), .in6_8(imosum_part6_8[DW_IN*3-1:DW_IN*2]), .in6_9(imosum_part6_9[DW_IN*3-1:DW_IN*2]),
    .in6_10(imosum_part6_10[DW_IN*3-1:DW_IN*2]), .in6_11(imosum_part6_11[DW_IN*3-1:DW_IN*2]), .in6_12(imosum_part6_12[DW_IN*3-1:DW_IN*2]), .in6_13(imosum_part6_13[DW_IN*3-1:DW_IN*2]),
    .in7_1(imosum_part7_1[DW_IN*3-1:DW_IN*2]), .in7_2(imosum_part7_2[DW_IN*3-1:DW_IN*2]), .in7_3(imosum_part7_3[DW_IN*3-1:DW_IN*2]), 
    .in7_4(imosum_part7_4[DW_IN*3-1:DW_IN*2]), .in7_5(imosum_part7_5[DW_IN*3-1:DW_IN*2]), .in7_6(imosum_part7_6[DW_IN*3-1:DW_IN*2]), 
    .in7_7(imosum_part7_7[DW_IN*3-1:DW_IN*2]), .in7_8(imosum_part7_8[DW_IN*3-1:DW_IN*2]), .in7_9(imosum_part7_9[DW_IN*3-1:DW_IN*2]), 
    .in7_10(imosum_part7_10[DW_IN*3-1:DW_IN*2]), .in7_11(imosum_part7_11[DW_IN*3-1:DW_IN*2]), .in7_12(imosum_part7_12[DW_IN*3-1:DW_IN*2]), .in7_13(imosum_part7_13[DW_IN*3-1:DW_IN*2]),
    .sum90_en(imosum_part_valid),
    .sum90   (imosum2          )
);

sum90 #(
    .DW_PART(10)
)U_sum90_imosum3(
    .clk  (clk  ),
    .rst_n(rst_n),
    .in1_1(imosum_part1_1[DW_IN*2-1:DW_IN]), .in1_2(imosum_part1_2[DW_IN*2-1:DW_IN]), .in1_3(imosum_part1_3[DW_IN*2-1:DW_IN]),
    .in1_4(imosum_part1_4[DW_IN*2-1:DW_IN]), .in1_5(imosum_part1_5[DW_IN*2-1:DW_IN]), .in1_6(imosum_part1_6[DW_IN*2-1:DW_IN]),
    .in1_7(imosum_part1_7[DW_IN*2-1:DW_IN]), .in1_8(imosum_part1_8[DW_IN*2-1:DW_IN]), .in1_9(imosum_part1_9[DW_IN*2-1:DW_IN]), 
    .in1_10(imosum_part1_10[DW_IN*2-1:DW_IN]), .in1_11(imosum_part1_11[DW_IN*2-1:DW_IN]), .in1_12(imosum_part1_12[DW_IN*2-1:DW_IN]), .in1_13(imosum_part1_13[DW_IN*2-1:DW_IN]),
    .in2_1(imosum_part2_1[DW_IN*2-1:DW_IN]), .in2_2(imosum_part2_2[DW_IN*2-1:DW_IN]), .in2_3(imosum_part2_3[DW_IN*2-1:DW_IN]), 
    .in2_4(imosum_part2_4[DW_IN*2-1:DW_IN]), .in2_5(imosum_part2_5[DW_IN*2-1:DW_IN]), .in2_6(imosum_part2_6[DW_IN*2-1:DW_IN]), 
    .in2_7(imosum_part2_7[DW_IN*2-1:DW_IN]), .in2_8(imosum_part2_8[DW_IN*2-1:DW_IN]), .in2_9(imosum_part2_9[DW_IN*2-1:DW_IN]), 
    .in2_10(imosum_part2_10[DW_IN*2-1:DW_IN]), .in2_11(imosum_part2_11[DW_IN*2-1:DW_IN]), .in2_12(imosum_part2_12[DW_IN*2-1:DW_IN]), .in2_13(imosum_part2_13[DW_IN*2-1:DW_IN]),
    .in3_1(imosum_part3_1[DW_IN*2-1:DW_IN]), .in3_2(imosum_part3_2[DW_IN*2-1:DW_IN]), .in3_3(imosum_part3_3[DW_IN*2-1:DW_IN]),
    .in3_4(imosum_part3_4[DW_IN*2-1:DW_IN]), .in3_5(imosum_part3_5[DW_IN*2-1:DW_IN]), .in3_6(imosum_part3_6[DW_IN*2-1:DW_IN]), 
    .in3_7(imosum_part3_7[DW_IN*2-1:DW_IN]), .in3_8(imosum_part3_8[DW_IN*2-1:DW_IN]), .in3_9(imosum_part3_9[DW_IN*2-1:DW_IN]), 
    .in3_10(imosum_part3_10[DW_IN*2-1:DW_IN]), .in3_11(imosum_part3_11[DW_IN*2-1:DW_IN]), .in3_12(imosum_part3_12[DW_IN*2-1:DW_IN]), .in3_13(imosum_part3_13[DW_IN*2-1:DW_IN]),
    .in4_1(imosum_part4_1[DW_IN*2-1:DW_IN]), .in4_2(imosum_part4_2[DW_IN*2-1:DW_IN]), .in4_3(imosum_part4_3[DW_IN*2-1:DW_IN]), 
    .in4_4(imosum_part4_4[DW_IN*2-1:DW_IN]), .in4_5(imosum_part4_5[DW_IN*2-1:DW_IN]), .in4_6(imosum_part4_6[DW_IN*2-1:DW_IN]),                  
    .in4_8(imosum_part4_8[DW_IN*2-1:DW_IN]), .in4_9(imosum_part4_9[DW_IN*2-1:DW_IN]), .in4_10(imosum_part4_10[DW_IN*2-1:DW_IN]), 
    .in4_11(imosum_part4_11[DW_IN*2-1:DW_IN]), .in4_12(imosum_part4_12[DW_IN*2-1:DW_IN]), .in4_13(imosum_part4_13[DW_IN*2-1:DW_IN]),
    .in5_1(imosum_part5_1[DW_IN*2-1:DW_IN]), .in5_2(imosum_part5_2[DW_IN*2-1:DW_IN]), .in5_3(imosum_part5_3[DW_IN*2-1:DW_IN]), 
    .in5_4(imosum_part5_4[DW_IN*2-1:DW_IN]), .in5_5(imosum_part5_5[DW_IN*2-1:DW_IN]), .in5_6(imosum_part5_6[DW_IN*2-1:DW_IN]), 
    .in5_7(imosum_part5_7[DW_IN*2-1:DW_IN]), .in5_8(imosum_part5_8[DW_IN*2-1:DW_IN]), .in5_9(imosum_part5_9[DW_IN*2-1:DW_IN]), 
    .in5_10(imosum_part5_10[DW_IN*2-1:DW_IN]), .in5_11(imosum_part5_11[DW_IN*2-1:DW_IN]), .in5_12(imosum_part5_12[DW_IN*2-1:DW_IN]), .in5_13(imosum_part5_13[DW_IN*2-1:DW_IN]),
    .in6_1(imosum_part6_1[DW_IN*2-1:DW_IN]), .in6_2(imosum_part6_2[DW_IN*2-1:DW_IN]), .in6_3(imosum_part6_3[DW_IN*2-1:DW_IN]),
    .in6_4(imosum_part6_4[DW_IN*2-1:DW_IN]), .in6_5(imosum_part6_5[DW_IN*2-1:DW_IN]), .in6_6(imosum_part6_6[DW_IN*2-1:DW_IN]), 
    .in6_7(imosum_part6_7[DW_IN*2-1:DW_IN]), .in6_8(imosum_part6_8[DW_IN*2-1:DW_IN]), .in6_9(imosum_part6_9[DW_IN*2-1:DW_IN]), 
    .in6_10(imosum_part6_10[DW_IN*2-1:DW_IN]), .in6_11(imosum_part6_11[DW_IN*2-1:DW_IN]), .in6_12(imosum_part6_12[DW_IN*2-1:DW_IN]), .in6_13(imosum_part6_13[DW_IN*2-1:DW_IN]),
    .in7_1(imosum_part7_1[DW_IN*2-1:DW_IN]), .in7_2(imosum_part7_2[DW_IN*2-1:DW_IN]), .in7_3(imosum_part7_3[DW_IN*2-1:DW_IN]), 
    .in7_4(imosum_part7_4[DW_IN*2-1:DW_IN]), .in7_5(imosum_part7_5[DW_IN*2-1:DW_IN]), .in7_6(imosum_part7_6[DW_IN*2-1:DW_IN]), 
    .in7_7(imosum_part7_7[DW_IN*2-1:DW_IN]), .in7_8(imosum_part7_8[DW_IN*2-1:DW_IN]), .in7_9(imosum_part7_9[DW_IN*2-1:DW_IN]), 
    .in7_10(imosum_part7_10[DW_IN*2-1:DW_IN]), .in7_11(imosum_part7_11[DW_IN*2-1:DW_IN]), .in7_12(imosum_part7_12[DW_IN*2-1:DW_IN]), .in7_13(imosum_part7_13[DW_IN*2-1:DW_IN]),
    .sum90_en(imosum_part_valid),
    .sum90   (imosum3         )
);

sum90 #(
    .DW_PART(10)
)U_sum90_imosum4(
    .clk  (clk  ),
    .rst_n(rst_n),
    .in1_1(imosum_part1_1[DW_IN-1:0]), .in1_2(imosum_part1_2[DW_IN-1:0]), .in1_3(imosum_part1_3[DW_IN-1:0]),
    .in1_4(imosum_part1_4[DW_IN-1:0]), .in1_5(imosum_part1_5[DW_IN-1:0]), .in1_6(imosum_part1_6[DW_IN-1:0]), 
    .in1_7(imosum_part1_7[DW_IN-1:0]), .in1_8(imosum_part1_8[DW_IN-1:0]), .in1_9(imosum_part1_9[DW_IN-1:0]), 
    .in1_10(imosum_part1_10[DW_IN-1:0]), .in1_11(imosum_part1_11[DW_IN-1:0]), .in1_12(imosum_part1_12[DW_IN-1:0]), .in1_13(imosum_part1_13[DW_IN-1:0]),
    .in2_1(imosum_part2_1[DW_IN-1:0]), .in2_2(imosum_part2_2[DW_IN-1:0]), .in2_3(imosum_part2_3[DW_IN-1:0]), 
    .in2_4(imosum_part2_4[DW_IN-1:0]), .in2_5(imosum_part2_5[DW_IN-1:0]), .in2_6(imosum_part2_6[DW_IN-1:0]), 
    .in2_7(imosum_part2_7[DW_IN-1:0]), .in2_8(imosum_part2_8[DW_IN-1:0]), .in2_9(imosum_part2_9[DW_IN-1:0]), 
    .in2_10(imosum_part2_10[DW_IN-1:0]), .in2_11(imosum_part2_11[DW_IN-1:0]), .in2_12(imosum_part2_12[DW_IN-1:0]), .in2_13(imosum_part2_13[DW_IN-1:0]),
    .in3_1(imosum_part3_1[DW_IN-1:0]), .in3_2(imosum_part3_2[DW_IN-1:0]), .in3_3(imosum_part3_3[DW_IN-1:0]), 
    .in3_4(imosum_part3_4[DW_IN-1:0]), .in3_5(imosum_part3_5[DW_IN-1:0]), .in3_6(imosum_part3_6[DW_IN-1:0]), 
    .in3_7(imosum_part3_7[DW_IN-1:0]), .in3_8(imosum_part3_8[DW_IN-1:0]), .in3_9(imosum_part3_9[DW_IN-1:0]), 
    .in3_10(imosum_part3_10[DW_IN-1:0]), .in3_11(imosum_part3_11[DW_IN-1:0]), .in3_12(imosum_part3_12[DW_IN-1:0]), .in3_13(imosum_part3_13[DW_IN-1:0]),
    .in4_1(imosum_part4_1[DW_IN-1:0]), .in4_2(imosum_part4_2[DW_IN-1:0]), .in4_3(imosum_part4_3[DW_IN-1:0]), 
    .in4_4(imosum_part4_4[DW_IN-1:0]), .in4_5(imosum_part4_5[DW_IN-1:0]), .in4_6(imosum_part4_6[DW_IN-1:0]),                  
    .in4_8(imosum_part4_8[DW_IN-1:0]), .in4_9(imosum_part4_9[DW_IN-1:0]), .in4_10(imosum_part4_10[DW_IN-1:0]), 
    .in4_11(imosum_part4_11[DW_IN-1:0]), .in4_12(imosum_part4_12[DW_IN-1:0]), .in4_13(imosum_part4_13[DW_IN-1:0]),
    .in5_1(imosum_part5_1[DW_IN-1:0]), .in5_2(imosum_part5_2[DW_IN-1:0]), .in5_3(imosum_part5_3[DW_IN-1:0]), 
    .in5_4(imosum_part5_4[DW_IN-1:0]), .in5_5(imosum_part5_5[DW_IN-1:0]), .in5_6(imosum_part5_6[DW_IN-1:0]), 
    .in5_7(imosum_part5_7[DW_IN-1:0]), .in5_8(imosum_part5_8[DW_IN-1:0]), .in5_9(imosum_part5_9[DW_IN-1:0]), 
    .in5_10(imosum_part5_10[DW_IN-1:0]), .in5_11(imosum_part5_11[DW_IN-1:0]), .in5_12(imosum_part5_12[DW_IN-1:0]), .in5_13(imosum_part5_13[DW_IN-1:0]),
    .in6_1(imosum_part6_1[DW_IN-1:0]), .in6_2(imosum_part6_2[DW_IN-1:0]), .in6_3(imosum_part6_3[DW_IN-1:0]), 
    .in6_4(imosum_part6_4[DW_IN-1:0]), .in6_5(imosum_part6_5[DW_IN-1:0]), .in6_6(imosum_part6_6[DW_IN-1:0]), 
    .in6_7(imosum_part6_7[DW_IN-1:0]), .in6_8(imosum_part6_8[DW_IN-1:0]), .in6_9(imosum_part6_9[DW_IN-1:0]), 
    .in6_10(imosum_part6_10[DW_IN-1:0]), .in6_11(imosum_part6_11[DW_IN-1:0]), .in6_12(imosum_part6_12[DW_IN-1:0]), .in6_13(imosum_part6_13[DW_IN-1:0]),
    .in7_1(imosum_part7_1[DW_IN-1:0]), .in7_2(imosum_part7_2[DW_IN-1:0]), .in7_3(imosum_part7_3[DW_IN-1:0]), 
    .in7_4(imosum_part7_4[DW_IN-1:0]), .in7_5(imosum_part7_5[DW_IN-1:0]), .in7_6(imosum_part7_6[DW_IN-1:0]), 
    .in7_7(imosum_part7_7[DW_IN-1:0]), .in7_8(imosum_part7_8[DW_IN-1:0]), .in7_9(imosum_part7_9[DW_IN-1:0]), 
    .in7_10(imosum_part7_10[DW_IN-1:0]), .in7_11(imosum_part7_11[DW_IN-1:0]), .in7_12(imosum_part7_12[DW_IN-1:0]), .in7_13(imosum_part7_13[DW_IN-1:0]),
    .sum90_en(imosum_part_valid),
    .sum90   (imosum4          )
);

wire [DW_IN*4-1:0] imo1;
wire [DW_IN*4-1:0] imo_i_j_d_sel;
wire [DW_DEC+7 :0] imowsum_d;

imo1_calc U_imo1_calc0(
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .imosum1      (imosum1      ),
    .imosum2      (imosum2      ),
    .imosum3      (imosum3      ),
    .imosum4      (imosum4      ),
    .imowsum      (imowsum      ),
    .imosum_valid (imosum_valid ),
    .mcor1        (mcor1_d      ),
    .mcor2        (mcor2_d      ),
    .mcor3        (mcor3_d      ),
    .mcor4        (mcor4_d      ),
    .imo_i_j      (array4_7     ),
    .imo1         (imo1         ),
    .imo1_valid   (imo1_valid   ),
    .imo_i_j_d_sel(imo_i_j_d_sel),
    .imowsum_d    (imowsum_d    )
);

wire [DW_IN*4-1:0] imo2;
assign imo2 = (imowsum_d > 16'd0)? imo1:imo_i_j_d_sel; 
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo3 <= {DW_IN*4{1'b0}};
else begin
    imo3[DW_IN*4-1:DW_IN*3] <= imo2[DW_IN*4-1:DW_IN*3];
    imo3[DW_IN*3-1:DW_IN*2] <= (imo2[DW_IN*3-1:DW_IN*2] + imo2[DW_IN*2-1:DW_IN])>>1;
    imo3[DW_IN*2-1:DW_IN  ] <= imo2[DW_IN*3-1:DW_IN*2];
    imo3[DW_IN-1  :0      ] <= imo2[DW_IN-1  :0      ];
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo3_valid <= 1'b0;
else
    imo3_valid <= imo1_valid;
end


endmodule
