module traverse_mask #(
    parameter DW_IN  = 10,
    parameter DW_DEC = 8
)(
    input                    clk            ,
    input                    rst_n          ,
    input                    imowsum_calc_en,
    input      [DW_IN*4-1:0] imo_ii_jj      ,
    input      [DW_IN*4-1:0] imo_i_j        ,
    input      [DW_IN-1  :0] imoy_i_j       ,
    input      [2        :0] ii_diff        , //max 6
    input      [3        :0] jj_diff        , //max 12
    output reg [DW_DEC   :0] wtmp           ,
    output reg [DW_IN*4-1:0] imosum_part 
);

localparam WCOR_DELAY      = 3 ;
localparam WDIS_DELAY      = 4 ;
localparam IMO_II_JJ_DELAY = 10;

integer i;

wire [DW_IN-1  :0] imoy_ii_jj  ;

wire [DW_DEC :0] mtmp                                                      ;
wire [DW_IN  :0] expcurve_in1 , expcurve_in2 , expcurve_in3 , expcurve_in4 ;
wire [DW_DEC :0] expcurve_out1, expcurve_out2, expcurve_out3, expcurve_out4;
reg  [(DW_DEC+1)*2-1:0] wcor_mult_tmp1, wcor_mult_tmp2;
reg  [(DW_DEC+1)*4-1:0] wcor_mult_tmp                 ;
reg  [DW_DEC        :0] wcor                          ;
reg  [7     :0] exp_in1, exp_in2;   
//ii_diff max 6  jj_diff max 12
//exp_in1 max 36 exp_in2 max 144
reg  [7     :0] exp_in;  //max 180
wire [DW_DEC:0] wdis  ;
wire [DW_DEC:0] wcor_d;
wire [DW_DEC:0] wdis_d;

wire [DW_IN*4-1:0] imo_ii_jj_d;

reg [DW_DEC:0] wcor_delay [WCOR_DELAY-1:0];
reg [DW_DEC:0] wdis_delay [WDIS_DELAY-1:0];

reg [DW_IN*4-1:0] imo_ii_jj_delay [IMO_II_JJ_DELAY-1:0];

//2clk
imoy_calc U_imoy_calc_ii_jj(
    .clk         (clk            ),
    .rst_n       (rst_n          ),
    .imoy_calc_en(imowsum_calc_en),
    .imcin       (imo_ii_jj      ),
    .imoy        (imoy_ii_jj     )
);

mtmp_calc U_mtmp_calc_ii_jj(
    .clk       (clk       ),
    .rst_n     (rst_n     ),
    .imoy_ii_jj(imoy_ii_jj),
    .imoy_i_j  (imoy_i_j  ),
    .mtmp      (mtmp      )
);

assign expcurve_in1 = (imo_ii_jj[DW_IN*4-1:DW_IN*3] >= imo_i_j[DW_IN*4-1:DW_IN*3])?
                      {1'b0, imo_ii_jj[DW_IN*4-1:DW_IN*3] - imo_i_j[DW_IN*4-1:DW_IN*3]}:
                      {1'b1, imo_i_j[DW_IN*4-1:DW_IN*3] - imo_ii_jj[DW_IN*4-1:DW_IN*3]};

assign expcurve_in2 = (imo_ii_jj[DW_IN*3-1:DW_IN*2] >= imo_i_j[DW_IN*3-1:DW_IN*2])?
                      {1'b0, imo_ii_jj[DW_IN*3-1:DW_IN*2] - imo_i_j[DW_IN*3-1:DW_IN*2]}:
                      {1'b1, imo_i_j[DW_IN*3-1:DW_IN*2] - imo_ii_jj[DW_IN*3-1:DW_IN*2]}; 

assign expcurve_in3 = (imo_ii_jj[DW_IN*2-1:DW_IN] >= imo_i_j[DW_IN*2-1:DW_IN])?
                      {1'b0, imo_ii_jj[DW_IN*2-1:DW_IN] - imo_i_j[DW_IN*2-1:DW_IN]}:
                      {1'b1, imo_i_j[DW_IN*2-1:DW_IN] - imo_ii_jj[DW_IN*2-1:DW_IN]};    

assign expcurve_in4 = (imo_ii_jj[DW_IN-1:0] >= imo_i_j[DW_IN-1:0])?
                      {1'b0, imo_ii_jj[DW_IN-1:0] - imo_i_j[DW_IN-1:0]}:
                      {1'b1, imo_i_j[DW_IN-1:0] - imo_ii_jj[DW_IN-1:0]};

expcurve U_expcurve1(
    .clk  (clk   ),
    .rst_n(rst_n ),
    .y1_0 (9'd256),.y1_1 (9'd255),.y1_2 (9'd253),.y1_3 (9'd250),.y1_4 (9'd245),.y1_5 (9'd238),.y1_6 (9'd231),.y1_7 (9'd223),
    .y1_8 (9'd213),.y1_9 (9'd203),.y1_10(9'd193),.y1_11(9'd181),.y1_12(9'd170),.y1_13(9'd158),.y1_14(9'd147),.y1_15(9'd135),
    .y1_16(9'd124),.y1_17(9'd113),.y1_18(9'd102),.y1_19(9'd92 ),.y1_20(9'd82 ),.y1_21(9'd73 ),.y1_22(9'd65 ),.y1_23(9'd57 ),
    .y1_24(9'd50 ),.y1_25(9'd43 ),.y1_26(9'd37 ),.y1_27(9'd32 ),.y1_28(9'd28 ),.y1_29(9'd23 ),.y1_30(9'd20 ),.y1_31(9'd17 ),
    .y1_32(9'd14 ),.y1_33(9'd12 ),.y1_34(9'd10 ),.y1_35(9'd8  ),.y1_36(9'd6  ),.y1_37(9'd5  ),.y1_38(9'd4  ),.y1_39(9'd3  ),
    .y1_40(9'd3  ),.y1_41(9'd2  ),.y1_42(9'd2  ),.y1_43(9'd1  ),.y1_44(9'd1  ),.y1_45(9'd1  ),.y1_46(9'd1  ),.y1_47(9'd0  ),

    .y2_0(9'd256),  .y2_1(9'd231), .y2_2(9'd170) ,.y2_3(9'd102), .y2_4(9'd50), .y2_5(9'd20), .y2_6(9'd6), .y2_7(9'd2), .y2_8(9'd0),

    .in(expcurve_in1),
    .out_d2(expcurve_out1)
);

expcurve U_expcurve2(
    .clk  (clk   ),
    .rst_n(rst_n ),
    .y1_0 (9'd256),.y1_1 (9'd255),.y1_2 (9'd253),.y1_3 (9'd250),.y1_4 (9'd245),.y1_5 (9'd238),.y1_6 (9'd231),.y1_7 (9'd223),
    .y1_8 (9'd213),.y1_9 (9'd203),.y1_10(9'd193),.y1_11(9'd181),.y1_12(9'd170),.y1_13(9'd158),.y1_14(9'd147),.y1_15(9'd135),
    .y1_16(9'd124),.y1_17(9'd113),.y1_18(9'd102),.y1_19(9'd92 ),.y1_20(9'd82 ),.y1_21(9'd73 ),.y1_22(9'd65 ),.y1_23(9'd57 ),
    .y1_24(9'd50 ),.y1_25(9'd43 ),.y1_26(9'd37 ),.y1_27(9'd32 ),.y1_28(9'd28 ),.y1_29(9'd23 ),.y1_30(9'd20 ),.y1_31(9'd17 ),
    .y1_32(9'd14 ),.y1_33(9'd12 ),.y1_34(9'd10 ),.y1_35(9'd8  ),.y1_36(9'd6  ),.y1_37(9'd5  ),.y1_38(9'd4  ),.y1_39(9'd3  ),
    .y1_40(9'd3  ),.y1_41(9'd2  ),.y1_42(9'd2  ),.y1_43(9'd1  ),.y1_44(9'd1  ),.y1_45(9'd1  ),.y1_46(9'd1  ),.y1_47(9'd0  ),

    .y2_0(9'd256),  .y2_1(9'd231), .y2_2(9'd170) ,.y2_3(9'd102), .y2_4(9'd50), .y2_5(9'd20), .y2_6(9'd6), .y2_7(9'd2), .y2_8(9'd0),

    .in(expcurve_in2),
    .out_d2(expcurve_out2)
);

expcurve U_expcurve3(
    .clk  (clk   ),
    .rst_n(rst_n ),
    .y1_0 (9'd256),.y1_1 (9'd255),.y1_2 (9'd253),.y1_3 (9'd250),.y1_4 (9'd245),.y1_5 (9'd238),.y1_6 (9'd231),.y1_7 (9'd223),
    .y1_8 (9'd213),.y1_9 (9'd203),.y1_10(9'd193),.y1_11(9'd181),.y1_12(9'd170),.y1_13(9'd158),.y1_14(9'd147),.y1_15(9'd135),
    .y1_16(9'd124),.y1_17(9'd113),.y1_18(9'd102),.y1_19(9'd92 ),.y1_20(9'd82 ),.y1_21(9'd73 ),.y1_22(9'd65 ),.y1_23(9'd57 ),
    .y1_24(9'd50 ),.y1_25(9'd43 ),.y1_26(9'd37 ),.y1_27(9'd32 ),.y1_28(9'd28 ),.y1_29(9'd23 ),.y1_30(9'd20 ),.y1_31(9'd17 ),
    .y1_32(9'd14 ),.y1_33(9'd12 ),.y1_34(9'd10 ),.y1_35(9'd8  ),.y1_36(9'd6  ),.y1_37(9'd5  ),.y1_38(9'd4  ),.y1_39(9'd3  ),
    .y1_40(9'd3  ),.y1_41(9'd2  ),.y1_42(9'd2  ),.y1_43(9'd1  ),.y1_44(9'd1  ),.y1_45(9'd1  ),.y1_46(9'd1  ),.y1_47(9'd0  ),

    .y2_0(9'd256),  .y2_1(9'd231), .y2_2(9'd170) ,.y2_3(9'd102), .y2_4(9'd50), .y2_5(9'd20), .y2_6(9'd6), .y2_7(9'd2), .y2_8(9'd0),

    .in(expcurve_in3),
    .out_d2(expcurve_out3)
);

expcurve U_expcurve4(
    .clk  (clk   ),
    .rst_n(rst_n ),
    .y1_0 (9'd256),.y1_1 (9'd255),.y1_2 (9'd253),.y1_3 (9'd250),.y1_4 (9'd245),.y1_5 (9'd238),.y1_6 (9'd231),.y1_7 (9'd223),
    .y1_8 (9'd213),.y1_9 (9'd203),.y1_10(9'd193),.y1_11(9'd181),.y1_12(9'd170),.y1_13(9'd158),.y1_14(9'd147),.y1_15(9'd135),
    .y1_16(9'd124),.y1_17(9'd113),.y1_18(9'd102),.y1_19(9'd92 ),.y1_20(9'd82 ),.y1_21(9'd73 ),.y1_22(9'd65 ),.y1_23(9'd57 ),
    .y1_24(9'd50 ),.y1_25(9'd43 ),.y1_26(9'd37 ),.y1_27(9'd32 ),.y1_28(9'd28 ),.y1_29(9'd23 ),.y1_30(9'd20 ),.y1_31(9'd17 ),
    .y1_32(9'd14 ),.y1_33(9'd12 ),.y1_34(9'd10 ),.y1_35(9'd8  ),.y1_36(9'd6  ),.y1_37(9'd5  ),.y1_38(9'd4  ),.y1_39(9'd3  ),
    .y1_40(9'd3  ),.y1_41(9'd2  ),.y1_42(9'd2  ),.y1_43(9'd1  ),.y1_44(9'd1  ),.y1_45(9'd1  ),.y1_46(9'd1  ),.y1_47(9'd0  ),

    .y2_0(9'd256),  .y2_1(9'd231), .y2_2(9'd170) ,.y2_3(9'd102), .y2_4(9'd50), .y2_5(9'd20), .y2_6(9'd6), .y2_7(9'd2), .y2_8(9'd0),

    .in(expcurve_in4),
    .out_d2(expcurve_out4)
);

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        wcor_mult_tmp1 <= {((DW_DEC+1)*2){1'b0}};
        wcor_mult_tmp2 <= {((DW_DEC+1)*2){1'b0}};
    end
    else begin
        wcor_mult_tmp1 <= expcurve_out1 * expcurve_out2;
        wcor_mult_tmp2 <= expcurve_out3 * expcurve_out4;
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    wcor_mult_tmp <= {((DW_DEC+1)*4){1'b0}};
else    
    wcor_mult_tmp <= wcor_mult_tmp1 * wcor_mult_tmp2;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    wcor <= {(DW_DEC){1'b0}};
else begin    
    wcor[DW_DEC    ] <= &wcor_mult_tmp[((DW_DEC+1)*4-1):(DW_DEC*4)];
    wcor[DW_DEC-1:0] <= ((wcor_mult_tmp[(DW_DEC*4-1):(DW_DEC*3)]==8'hff) || (wcor_mult_tmp[23]==1'b0))? wcor_mult_tmp[(DW_DEC*4-1):(DW_DEC*3)]:
                        (wcor_mult_tmp[(DW_DEC*4-1):(DW_DEC*3)]+1'b1);
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        exp_in1 <= 8'd0;
        exp_in2 <= 8'd0;
    end
    else if(imowsum_calc_en) begin
        exp_in1 <= ii_diff * ii_diff;
        exp_in2 <= jj_diff * jj_diff;
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    exp_in <= 8'd0;
else  
    exp_in <=  exp_in1 + exp_in2;
end

exp U_exp0(
    .clk   (clk            ),
    .rst_n (rst_n          ),
    .y1_0 (9'd256),.y1_1 (9'd252),.y1_2 (9'd248),.y1_3 (9'd244),.y1_4 (9'd239),.y1_5 (9'd236),.y1_6 (9'd232),.y1_7 (9'd228),
    .y1_8 (9'd224),.y1_9 (9'd220),.y1_10(9'd217),.y1_11(9'd213),.y1_12(9'd210),.y1_13(9'd206),.y1_14(9'd203),.y1_15(9'd199),
    .y1_16(9'd196),.y1_17(9'd193),.y1_18(9'd190),.y1_19(9'd187),.y1_20(9'd183),.y1_21(9'd180),.y1_22(9'd177),.y1_23(9'd174),
    .y1_24(9'd172),.y1_25(9'd169),.y1_26(9'd166),.y1_27(9'd163),.y1_28(9'd161),.y1_29(9'd158),.y1_30(9'd155),.y1_31(9'd153),
    .y1_32(9'd150),.y1_33(9'd148),.y1_34(9'd145),.y1_35(9'd143),.y1_36(9'd140),.y1_37(9'd138),.y1_38(9'd136),.y1_39(9'd134),
    .y1_40(9'd131),.y1_41(9'd129),.y1_42(9'd127),.y1_43(9'd125),.y1_44(9'd123),.y1_45(9'd121),

    .in    (exp_in),
    .out_d2(wdis  )
);

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i <= WCOR_DELAY-1; i = i+1) begin
            wcor_delay[i] <= {(DW_DEC+1){1'b0}};
        end
    end    
    else begin
        for(i = WCOR_DELAY-1; i > 0; i = i-1) begin
            wcor_delay[i] <= wcor_delay[i-1];
        end
        wcor_delay[0] <= wcor;
    end    
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i <= WDIS_DELAY-1; i = i+1) begin
            wdis_delay[i] <= {(DW_DEC+1){1'b0}};
        end
    end    
    else begin
        for(i = WDIS_DELAY-1; i > 0; i = i-1) begin
            wdis_delay[i] <= wdis_delay[i-1];
        end
        wdis_delay[0] <= wdis;
    end    
end

assign wcor_d = wcor_delay[WCOR_DELAY-1];
assign wdis_d = wdis_delay[WDIS_DELAY-1];

reg [DW_DEC        :0] wtmp_temp2, wtmp_temp3;
reg [(DW_DEC+1)*3-1:0] wtmp_temp ;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    wtmp_temp <= {((DW_DEC+1)*3){1'b0}};
else
    wtmp_temp <= mtmp * wcor_d * wdis_d;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    wtmp_temp2 <= {(DW_DEC+1){1'b0}};
else begin
    wtmp_temp2[DW_DEC]     <= &wtmp_temp[((DW_DEC+1)*3-1):(DW_DEC*3)];
    wtmp_temp2[DW_DEC-1:0] <= ((&wtmp_temp[DW_DEC*3-1:DW_DEC*2]) || (wtmp_temp[DW_DEC*2-1]==1'b0))?(wtmp_temp[DW_DEC*3-1:DW_DEC*2])
                        :(wtmp_temp[DW_DEC*3-1:DW_DEC*2]+1'b1);
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        wtmp       <= {(DW_DEC+1){1'b0}};
        wtmp_temp3 <= {(DW_DEC+1){1'b0}};
    end
    else begin
        wtmp_temp3 <= wtmp_temp2;
        wtmp       <= wtmp_temp3;
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i <= IMO_II_JJ_DELAY-1; i = i+1) begin
            imo_ii_jj_delay[i] <= {(DW_IN*4){1'b0}};
        end
    end    
    else begin
        for(i = IMO_II_JJ_DELAY-1; i > 0; i = i-1) begin
            imo_ii_jj_delay[i] <= imo_ii_jj_delay[i-1];
        end
        imo_ii_jj_delay[0] <= imo_ii_jj;
    end    
end

assign imo_ii_jj_d = imo_ii_jj_delay[IMO_II_JJ_DELAY-1];

reg  [DW_IN+DW_DEC:0] imosum_part_temp1, imosum_part_temp2, imosum_part_temp3, imosum_part_temp4;
wire [DW_IN-1     :0] imosum_part_temp1_clamp, imosum_part_temp2_clamp;
wire [DW_IN-1     :0] imosum_part_temp3_clamp, imosum_part_temp4_clamp;

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        imosum_part_temp1 <= {(DW_IN+DW_DEC+1){1'b0}};
        imosum_part_temp2 <= {(DW_IN+DW_DEC+1){1'b0}};
        imosum_part_temp3 <= {(DW_IN+DW_DEC+1){1'b0}};
        imosum_part_temp4 <= {(DW_IN+DW_DEC+1){1'b0}};
    end
    else begin
        imosum_part_temp1 <= imo_ii_jj_d[DW_IN*4-1:DW_IN*3] * wtmp_temp2;
        imosum_part_temp2 <= imo_ii_jj_d[DW_IN*3-1:DW_IN*2] * wtmp_temp2;
        imosum_part_temp3 <= imo_ii_jj_d[DW_IN*2-1:DW_IN  ] * wtmp_temp2;
        imosum_part_temp4 <= imo_ii_jj_d[DW_IN-1  :0      ] * wtmp_temp2;
    end
end

assign imosum_part_temp1_clamp = ((&imosum_part_temp1[DW_IN+DW_DEC:DW_DEC+1]) || (imosum_part_temp1[DW_DEC]==1'b0))? 
                                 imosum_part_temp1[DW_IN+DW_DEC:DW_DEC+1]:(imosum_part_temp1[DW_IN+DW_DEC:DW_DEC+1]+1'b1);
assign imosum_part_temp2_clamp = ((&imosum_part_temp2[DW_IN+DW_DEC:DW_DEC+1]) || (imosum_part_temp2[DW_DEC]==1'b0))? 
                                 imosum_part_temp2[DW_IN+DW_DEC:DW_DEC+1]:(imosum_part_temp2[DW_IN+DW_DEC:DW_DEC+1]+1'b1);
assign imosum_part_temp3_clamp = ((&imosum_part_temp3[DW_IN+DW_DEC:DW_DEC+1]) || (imosum_part_temp3[DW_DEC]==1'b0))? 
                                 imosum_part_temp3[DW_IN+DW_DEC:DW_DEC+1]:(imosum_part_temp3[DW_IN+DW_DEC:DW_DEC+1]+1'b1);
assign imosum_part_temp4_clamp = ((&imosum_part_temp4[DW_IN+DW_DEC:DW_DEC+1]) || (imosum_part_temp4[DW_DEC]==1'b0))? 
                                 imosum_part_temp4[DW_IN+DW_DEC:DW_DEC+1]:(imosum_part_temp4[DW_IN+DW_DEC:DW_DEC+1]+1'b1);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imosum_part <= {(DW_IN*4){1'b0}};    
else
    imosum_part <= {imosum_part_temp1_clamp, imosum_part_temp2_clamp, imosum_part_temp3_clamp, imosum_part_temp4_clamp};
end

endmodule
