module imo1_calc #(
    parameter DW_IN  = 10,
    parameter DW_DEC = 8
)(
    input                    clk    ,
    input                    rst_n  ,
    input      [DW_IN+6  :0] imosum1, imosum2, imosum3, imosum4,
    input      [DW_DEC+7 :0] imowsum,
    input                    imosum_valid,
    input      [DW_DEC   :0] mcor1, mcor2, mcor3, mcor4,
    input      [DW_IN*4-1:0] imo_i_j,
    output reg [DW_IN*4-1:0] imo1,
    output                   imo1_valid,
    output     [DW_DEC+7 :0] imowsum_d,
    output reg [DW_IN*4-1:0] imo_i_j_d_sel
);

localparam IMOTMP_DELAY       = 4                  ;
localparam IMO_I_J_DELAY      = 12+IMOTMP_DELAY+3+4; //12 imosum_part_valid  4 imosum_valid  3div
localparam IMOSUM_VALID_DELAY = 8                  ;
localparam IMOWSUM_DELAY      = IMOSUM_VALID_DELAY ;

integer i;

wire imo1_calc_en;
assign imo1_calc_en = imosum_valid && (imowsum > {(DW_DEC+8){1'b0}});

wire [DW_IN+14:0] imosum1_ext8, imosum2_ext8, imosum3_ext8, imosum4_ext8;
wire [DW_IN+14:0] imotmp1, imotmp2, imotmp3, imotmp4;
wire [DW_IN-1 :0] imotmp1_clamp, imotmp2_clamp, imotmp3_clamp, imotmp4_clamp;
wire [DW_DEC  :0] mcortmp1, mcortmp2, mcortmp3, mcortmp4;

assign imosum1_ext8 = imo1_calc_en ? (imosum1 >> 8):{(DW_IN+15){1'b0}};
assign imosum2_ext8 = imo1_calc_en ? (imosum2 >> 8):{(DW_IN+15){1'b0}};
assign imosum3_ext8 = imo1_calc_en ? (imosum3 >> 8):{(DW_IN+15){1'b0}};
assign imosum4_ext8 = imo1_calc_en ? (imosum4 >> 8):{(DW_IN+15){1'b0}};

//clk 1~3
DW_div_pipe #(.a_width(DW_IN+15),.b_width(DW_DEC+8), .tc_mode(0), .rem_mode(1), .num_stages(4))
U_DW_div_pipe1(.clk(clk), .rst_n(rst_n), .en(imo1_calc_en), .a(imosum1_ext8), .b(imowsum), .quotient(imotmp1), .remainder(),.divide_by_0());

DW_div_pipe #(.a_width(DW_IN+15),.b_width(DW_DEC+8), .tc_mode(0), .rem_mode(1), .num_stages(4))
U_DW_div_pipe2(.clk(clk), .rst_n(rst_n), .en(imo1_calc_en), .a(imosum2_ext8), .b(imowsum), .quotient(imotmp2), .remainder(),.divide_by_0());

DW_div_pipe #(.a_width(DW_IN+15),.b_width(DW_DEC+8), .tc_mode(0), .rem_mode(1), .num_stages(4))
U_DW_div_pipe3(.clk(clk), .rst_n(rst_n), .en(imo1_calc_en), .a(imosum3_ext8), .b(imowsum), .quotient(imotmp3), .remainder(),.divide_by_0());

DW_div_pipe #(.a_width(DW_IN+15),.b_width(DW_DEC+8), .tc_mode(0), .rem_mode(1), .num_stages(4))
U_DW_div_pipe4(.clk(clk), .rst_n(rst_n), .en(imo1_calc_en), .a(imosum4_ext8), .b(imowsum), .quotient(imotmp4), .remainder(),.divide_by_0());

assign imotmp1_clamp = ((&imotmp1[DW_DEC+9:DW_DEC]) || (imotmp1[DW_DEC-1]==1'b0))?
                        imotmp1[DW_DEC+9:DW_DEC]:(imotmp1[DW_DEC+9:DW_DEC]+1'b1);
assign imotmp2_clamp = ((&imotmp2[DW_DEC+9:DW_DEC]) || (imotmp2[DW_DEC-1]==1'b0))?
                        imotmp2[DW_DEC+9:DW_DEC]:(imotmp2[DW_DEC+9:DW_DEC]+1'b1);
assign imotmp3_clamp = ((&imotmp3[DW_DEC+9:DW_DEC]) || (imotmp3[DW_DEC-1]==1'b0))?
                        imotmp3[DW_DEC+9:DW_DEC]:(imotmp3[DW_DEC+9:DW_DEC]+1'b1);
assign imotmp4_clamp = ((&imotmp4[DW_DEC+9:DW_DEC]) || (imotmp4[DW_DEC-1]==1'b0))?
                        imotmp4[DW_DEC+9:DW_DEC]:(imotmp4[DW_DEC+9:DW_DEC]+1'b1);
//clk 4 5
tanhcurve U_tanhcurve1(
    .clk  (clk  ),
    .rst_n(rst_n),

    .y1_0 (9'd0  ),.y1_1 (9'd0  ),.y1_2 (9'd0  ),.y1_3 (9'd0  ),.y1_4 (9'd0  ),.y1_5 (9'd0  ),.y1_6 (9'd0  ),.y1_7 (9'd0  ),.y1_8 (9'd0  ),.y1_9 (9'd0  ),.y1_10(9'd0  ),.y1_11(9'd0  ),.y1_12(9'd0  ),
    .y1_13(9'd0  ),.y1_14(9'd0  ),.y1_15(9'd1  ),.y1_16(9'd1  ),.y1_17(9'd1  ),.y1_18(9'd1  ),.y1_19(9'd2  ),.y1_20(9'd2  ),.y1_21(9'd3  ),.y1_22(9'd4  ),.y1_23(9'd5  ),.y1_24(9'd7  ),.y1_25(9'd9  ),
    .y1_26(9'd11 ),.y1_27(9'd15 ),.y1_28(9'd19 ),.y1_29(9'd24 ),.y1_30(9'd31 ),.y1_31(9'd38 ),.y1_32(9'd48 ),.y1_33(9'd59 ),.y1_34(9'd72 ),.y1_35(9'd87 ),.y1_36(9'd103),.y1_37(9'd119),.y1_38(9'd137),
    .y1_39(9'd153),.y1_40(9'd169),.y1_41(9'd184),.y1_42(9'd197),.y1_43(9'd208),.y1_44(9'd218),.y1_45(9'd225),.y1_46(9'd232),.y1_47(9'd237),.y1_48(9'd241),.y1_49(9'd245),.y1_50(9'd247),.y1_51(9'd249),
    .y1_52(9'd251),.y1_53(9'd252),.y1_54(9'd253),.y1_55(9'd254),.y1_56(9'd254),.y1_57(9'd255),.y1_58(9'd255),.y1_59(9'd255),.y1_60(9'd255),.y1_61(9'd256),.y1_62(9'd256),.y1_63(9'd256),.y1_64(9'd256),

    .in    (imotmp1_clamp),
    .out_d2(mcortmp1     )    
);

tanhcurve U_tanhcurve2(
    .clk  (clk  ),
    .rst_n(rst_n),

    .y1_0 (9'd0  ),.y1_1 (9'd0  ),.y1_2 (9'd0  ),.y1_3 (9'd0  ),.y1_4 (9'd0  ),.y1_5 (9'd0  ),.y1_6 (9'd0  ),.y1_7 (9'd0  ),.y1_8 (9'd0  ),.y1_9 (9'd0  ),.y1_10(9'd0  ),.y1_11(9'd0  ),.y1_12(9'd0  ),
    .y1_13(9'd0  ),.y1_14(9'd0  ),.y1_15(9'd1  ),.y1_16(9'd1  ),.y1_17(9'd1  ),.y1_18(9'd1  ),.y1_19(9'd2  ),.y1_20(9'd2  ),.y1_21(9'd3  ),.y1_22(9'd4  ),.y1_23(9'd5  ),.y1_24(9'd7  ),.y1_25(9'd9  ),
    .y1_26(9'd11 ),.y1_27(9'd15 ),.y1_28(9'd19 ),.y1_29(9'd24 ),.y1_30(9'd31 ),.y1_31(9'd38 ),.y1_32(9'd48 ),.y1_33(9'd59 ),.y1_34(9'd72 ),.y1_35(9'd87 ),.y1_36(9'd103),.y1_37(9'd119),.y1_38(9'd137),
    .y1_39(9'd153),.y1_40(9'd169),.y1_41(9'd184),.y1_42(9'd197),.y1_43(9'd208),.y1_44(9'd218),.y1_45(9'd225),.y1_46(9'd232),.y1_47(9'd237),.y1_48(9'd241),.y1_49(9'd245),.y1_50(9'd247),.y1_51(9'd249),
    .y1_52(9'd251),.y1_53(9'd252),.y1_54(9'd253),.y1_55(9'd254),.y1_56(9'd254),.y1_57(9'd255),.y1_58(9'd255),.y1_59(9'd255),.y1_60(9'd255),.y1_61(9'd256),.y1_62(9'd256),.y1_63(9'd256),.y1_64(9'd256),

    .in    (imotmp2_clamp),
    .out_d2(mcortmp2     )    
);

tanhcurve U_tanhcurve3(
    .clk  (clk  ),
    .rst_n(rst_n),

    .y1_0 (9'd0  ),.y1_1 (9'd0  ),.y1_2 (9'd0  ),.y1_3 (9'd0  ),.y1_4 (9'd0  ),.y1_5 (9'd0  ),.y1_6 (9'd0  ),.y1_7 (9'd0  ),.y1_8 (9'd0  ),.y1_9 (9'd0  ),.y1_10(9'd0  ),.y1_11(9'd0  ),.y1_12(9'd0  ),
    .y1_13(9'd0  ),.y1_14(9'd0  ),.y1_15(9'd1  ),.y1_16(9'd1  ),.y1_17(9'd1  ),.y1_18(9'd1  ),.y1_19(9'd2  ),.y1_20(9'd2  ),.y1_21(9'd3  ),.y1_22(9'd4  ),.y1_23(9'd5  ),.y1_24(9'd7  ),.y1_25(9'd9  ),
    .y1_26(9'd11 ),.y1_27(9'd15 ),.y1_28(9'd19 ),.y1_29(9'd24 ),.y1_30(9'd31 ),.y1_31(9'd38 ),.y1_32(9'd48 ),.y1_33(9'd59 ),.y1_34(9'd72 ),.y1_35(9'd87 ),.y1_36(9'd103),.y1_37(9'd119),.y1_38(9'd137),
    .y1_39(9'd153),.y1_40(9'd169),.y1_41(9'd184),.y1_42(9'd197),.y1_43(9'd208),.y1_44(9'd218),.y1_45(9'd225),.y1_46(9'd232),.y1_47(9'd237),.y1_48(9'd241),.y1_49(9'd245),.y1_50(9'd247),.y1_51(9'd249),
    .y1_52(9'd251),.y1_53(9'd252),.y1_54(9'd253),.y1_55(9'd254),.y1_56(9'd254),.y1_57(9'd255),.y1_58(9'd255),.y1_59(9'd255),.y1_60(9'd255),.y1_61(9'd256),.y1_62(9'd256),.y1_63(9'd256),.y1_64(9'd256),

    .in    (imotmp3_clamp),
    .out_d2(mcortmp3     )    
);

tanhcurve U_tanhcurve4(
    .clk  (clk  ),
    .rst_n(rst_n),

    .y1_0 (9'd0  ),.y1_1 (9'd0  ),.y1_2 (9'd0  ),.y1_3 (9'd0  ),.y1_4 (9'd0  ),.y1_5 (9'd0  ),.y1_6 (9'd0  ),.y1_7 (9'd0  ),.y1_8 (9'd0  ),.y1_9 (9'd0  ),.y1_10(9'd0  ),.y1_11(9'd0  ),.y1_12(9'd0  ),
    .y1_13(9'd0  ),.y1_14(9'd0  ),.y1_15(9'd1  ),.y1_16(9'd1  ),.y1_17(9'd1  ),.y1_18(9'd1  ),.y1_19(9'd2  ),.y1_20(9'd2  ),.y1_21(9'd3  ),.y1_22(9'd4  ),.y1_23(9'd5  ),.y1_24(9'd7  ),.y1_25(9'd9  ),
    .y1_26(9'd11 ),.y1_27(9'd15 ),.y1_28(9'd19 ),.y1_29(9'd24 ),.y1_30(9'd31 ),.y1_31(9'd38 ),.y1_32(9'd48 ),.y1_33(9'd59 ),.y1_34(9'd72 ),.y1_35(9'd87 ),.y1_36(9'd103),.y1_37(9'd119),.y1_38(9'd137),
    .y1_39(9'd153),.y1_40(9'd169),.y1_41(9'd184),.y1_42(9'd197),.y1_43(9'd208),.y1_44(9'd218),.y1_45(9'd225),.y1_46(9'd232),.y1_47(9'd237),.y1_48(9'd241),.y1_49(9'd245),.y1_50(9'd247),.y1_51(9'd249),
    .y1_52(9'd251),.y1_53(9'd252),.y1_54(9'd253),.y1_55(9'd254),.y1_56(9'd254),.y1_57(9'd255),.y1_58(9'd255),.y1_59(9'd255),.y1_60(9'd255),.y1_61(9'd256),.y1_62(9'd256),.y1_63(9'd256),.y1_64(9'd256),

    .in    (imotmp4_clamp),
    .out_d2(mcortmp4     )    
);

wire [DW_DEC:0] mcordiff1, mcordiff2, mcordiff3, mcordiff4;

assign mcordiff1 = (mcortmp1>mcor1)? (mcortmp1-mcor1):(mcor1-mcortmp1);
assign mcordiff2 = (mcortmp2>mcor2)? (mcortmp2-mcor2):(mcor2-mcortmp2);
assign mcordiff3 = (mcortmp3>mcor3)? (mcortmp3-mcor3):(mcor3-mcortmp3);
assign mcordiff4 = (mcortmp4>mcor4)? (mcortmp4-mcor4):(mcor4-mcortmp4);

wire [DW_DEC:0] max_diff, max_diff1, max_diff2;
reg  [DW_DEC:0] max_diff_buf;

assign max_diff1 = (mcordiff1 > mcordiff2)? mcordiff1:mcordiff2;
assign max_diff2 = (mcordiff3 > mcordiff4)? mcordiff3:mcordiff4;
assign max_diff  = (max_diff1 > max_diff2)? max_diff1:max_diff2;

//clk6
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    max_diff_buf <= {(DW_DEC+1){1'b0}};
else
    max_diff_buf <= max_diff;
end

reg  [DW_DEC-1:0] blurweight_tmp ;
wire [DW_DEC  :0] blurweight_tmp2;
reg  [DW_DEC  :0] blurweight     ;

always@(*) begin
if(max_diff < 9'd51)
    blurweight_tmp = {DW_DEC{1'b0}};
else    
    blurweight_tmp = (max_diff - 9'd51)>>1;
end

assign blurweight_tmp2 = blurweight_tmp + (blurweight_tmp<<2);

// clk7
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    blurweight <= {(DW_DEC+1){1'b0}};
else if(blurweight[DW_DEC] && (|blurweight[DW_DEC-1:0]))
    blurweight <= 9'd256;
else    
    blurweight <= blurweight_tmp2;
end

reg  [DW_IN-1:0] imo_i_j1_delay [IMO_I_J_DELAY-1:0];
reg  [DW_IN-1:0] imo_i_j2_delay [IMO_I_J_DELAY-1:0];
reg  [DW_IN-1:0] imo_i_j3_delay [IMO_I_J_DELAY-1:0];
reg  [DW_IN-1:0] imo_i_j4_delay [IMO_I_J_DELAY-1:0];

reg  [DW_IN-1:0] imotmp1_delay  [IMOTMP_DELAY-1:0];
reg  [DW_IN-1:0] imotmp2_delay  [IMOTMP_DELAY-1:0];
reg  [DW_IN-1:0] imotmp3_delay  [IMOTMP_DELAY-1:0];
reg  [DW_IN-1:0] imotmp4_delay  [IMOTMP_DELAY-1:0];

wire [DW_IN-1:0] imo_i_j1_d, imo_i_j2_d, imo_i_j3_d, imo_i_j4_d;
wire [DW_IN-1:0] imotmp1_d, imotmp2_d, imotmp3_d, imotmp4_d;

reg [IMOSUM_VALID_DELAY-1:0] imosum_valid_delay;

reg  [DW_DEC+7:0] imowsum_delay [IMOWSUM_DELAY-1:0];

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imosum_valid_delay <= {IMOSUM_VALID_DELAY{1'b0}};
else
    imosum_valid_delay <= {imosum_valid_delay[IMOSUM_VALID_DELAY-2:0], imosum_valid};
end

assign imo1_valid = imosum_valid_delay[IMOSUM_VALID_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i<= IMO_I_J_DELAY-1; i = i+1) begin
            imo_i_j1_delay[i] <= {DW_IN{1'b0}};
        end
    end
    else begin
        for(i = IMO_I_J_DELAY-1; i > 0; i = i-1) begin
            imo_i_j1_delay[i] <= imo_i_j1_delay[i-1]; 
        end
        imo_i_j1_delay[0] <= imo_i_j[DW_IN*4-1:DW_IN*3];
    end
end

assign imo_i_j1_d = imo_i_j1_delay[IMO_I_J_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i<= IMO_I_J_DELAY-1; i = i+1) begin
            imo_i_j2_delay[i] <= {DW_IN{1'b0}};
        end
    end
    else begin
        for(i = IMO_I_J_DELAY-1; i > 0; i = i-1) begin
            imo_i_j2_delay[i] <= imo_i_j2_delay[i-1]; 
        end
        imo_i_j2_delay[0] <= imo_i_j[DW_IN*3-1:DW_IN*2];
    end
end

assign imo_i_j2_d = imo_i_j2_delay[IMO_I_J_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i<= IMO_I_J_DELAY-1; i = i+1) begin
            imo_i_j3_delay[i] <= {DW_IN{1'b0}};
        end
    end
    else begin
        for(i = IMO_I_J_DELAY-1; i > 0; i = i-1) begin
            imo_i_j3_delay[i] <= imo_i_j3_delay[i-1]; 
        end
        imo_i_j3_delay[0] <= imo_i_j[DW_IN*2-1:DW_IN];
    end
end

assign imo_i_j3_d = imo_i_j3_delay[IMO_I_J_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i<= IMO_I_J_DELAY-1; i = i+1) begin
            imo_i_j4_delay[i] <= {DW_IN{1'b0}};
        end
    end
    else begin
        for(i = IMO_I_J_DELAY-1; i > 0; i = i-1) begin
            imo_i_j4_delay[i] <= imo_i_j4_delay[i-1]; 
        end
        imo_i_j4_delay[0] <= imo_i_j[DW_IN-1:0];
    end
end

assign imo_i_j4_d = imo_i_j4_delay[IMO_I_J_DELAY-1];

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imo_i_j_d_sel <= {DW_IN*4{1'b0}};
else begin
    imo_i_j_d_sel[DW_IN*4-1:DW_IN*3] <= imo_i_j1_d;
    imo_i_j_d_sel[DW_IN*3-1:DW_IN*2] <= imo_i_j2_d;
    imo_i_j_d_sel[DW_IN*2-1:DW_IN  ] <= imo_i_j3_d;
    imo_i_j_d_sel[DW_IN-1  :0      ] <= imo_i_j4_d;
end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i<= IMOWSUM_DELAY-1; i = i+1) begin
            imowsum_delay[i] <= {(DW_DEC+8){1'b0}};
        end
    end
    else begin
        for(i = IMOWSUM_DELAY-1; i > 0; i = i-1) begin
            imowsum_delay[i] <= imowsum_delay[i-1]; 
        end
        imowsum_delay[0] <= imowsum;
    end
end

assign imowsum_d = imowsum_delay[IMOWSUM_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i<= IMOTMP_DELAY-1; i = i+1) begin
            imotmp1_delay[i] <= {DW_IN{1'b0}};
        end
    end
    else begin
        for(i = IMOTMP_DELAY-1; i > 0; i = i-1) begin
            imotmp1_delay[i] <= imotmp1_delay[i-1]; 
        end
        imotmp1_delay[0] <= imotmp1_clamp;
    end
end

assign imotmp1_d = imotmp1_delay[IMOTMP_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i<= IMOTMP_DELAY-1; i = i+1) begin
            imotmp2_delay[i] <= {DW_IN{1'b0}};
        end
    end
    else begin
        for(i = IMOTMP_DELAY-1; i > 0; i = i-1) begin
            imotmp2_delay[i] <= imotmp2_delay[i-1]; 
        end
        imotmp2_delay[0] <= imotmp2_clamp;
    end
end

assign imotmp2_d = imotmp2_delay[IMOTMP_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i<= IMOTMP_DELAY-1; i = i+1) begin
            imotmp3_delay[i] <= {DW_IN{1'b0}};
        end
    end
    else begin
        for(i = IMOTMP_DELAY-1; i > 0; i = i-1) begin
            imotmp3_delay[i] <= imotmp3_delay[i-1]; 
        end
        imotmp3_delay[0] <= imotmp3_clamp;
    end
end

assign imotmp3_d = imotmp3_delay[IMOTMP_DELAY-1];

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i<= IMOTMP_DELAY-1; i = i+1) begin
            imotmp4_delay[i] <= {DW_IN{1'b0}};
        end
    end
    else begin
        for(i = IMOTMP_DELAY-1; i > 0; i = i-1) begin
            imotmp4_delay[i] <= imotmp4_delay[i-1]; 
        end
        imotmp4_delay[0] <= imotmp4_clamp;
    end
end

assign imotmp4_d = imotmp4_delay[IMOTMP_DELAY-1];

wire [DW_IN+DW_DEC:0] imo1_1_tmp1, imo1_1_tmp2;
wire [DW_IN+DW_DEC+1:0] imo1_1_tmp;

assign imo1_1_tmp1 = imotmp1_d * (9'd256 - blurweight);
assign imo1_1_tmp2 = imo_i_j1_d * blurweight;
assign imo1_1_tmp  = imo1_1_tmp1 + imo1_1_tmp2;

wire [DW_IN+DW_DEC:0] imo1_2_tmp1, imo1_2_tmp2;
wire [DW_IN+DW_DEC+1:0] imo1_2_tmp;

assign imo1_2_tmp1 = imotmp2_d * (9'd256 - blurweight);
assign imo1_2_tmp2 = imo_i_j2_d * blurweight;
assign imo1_2_tmp  = imo1_2_tmp1 + imo1_2_tmp2;

wire [DW_IN+DW_DEC:0] imo1_3_tmp1, imo1_3_tmp2;
wire [DW_IN+DW_DEC+1:0] imo1_3_tmp;

assign imo1_3_tmp1 = imotmp3_d * (9'd256 - blurweight);
assign imo1_3_tmp2 = imo_i_j3_d * blurweight;
assign imo1_3_tmp  = imo1_3_tmp1 + imo1_3_tmp2;

wire [DW_IN+DW_DEC:0] imo1_4_tmp1, imo1_4_tmp2;
wire [DW_IN+DW_DEC+1:0] imo1_4_tmp;

assign imo1_4_tmp1 = imotmp4_d * (9'd256 - blurweight);
assign imo1_4_tmp2 = imo_i_j4_d * blurweight;
assign imo1_4_tmp  = imo1_4_tmp1 + imo1_4_tmp2;

//clk 8
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) 
        imo1 <= {DW_IN*4{1'b0}};
    else begin
        imo1[DW_IN*4-1:DW_IN*3] <= ((&imo1_1_tmp[DW_DEC+9:DW_DEC]) || (imo1_1_tmp[DW_DEC-1:0] == 1'b0))? 
                                   (imo1_1_tmp[DW_DEC+9:DW_DEC]):(imo1_1_tmp[DW_DEC+9:DW_DEC]+1'b1);
        imo1[DW_IN*3-1:DW_IN*2] <= ((&imo1_2_tmp[DW_DEC+9:DW_DEC]) || (imo1_2_tmp[DW_DEC-1:0] == 1'b0))? 
                                   (imo1_2_tmp[DW_DEC+9:DW_DEC]):(imo1_2_tmp[DW_DEC+9:DW_DEC]+1'b1);
        imo1[DW_IN*2-1:DW_IN  ] <= ((&imo1_3_tmp[DW_DEC+9:DW_DEC]) || (imo1_3_tmp[DW_DEC-1:0] == 1'b0))? 
                                   (imo1_3_tmp[DW_DEC+9:DW_DEC]):(imo1_3_tmp[DW_DEC+9:DW_DEC]+1'b1);
        imo1[DW_IN-1  :0      ] <= ((&imo1_4_tmp[DW_DEC+9:DW_DEC]) || (imo1_4_tmp[DW_DEC-1:0] == 1'b0))? 
                                   (imo1_4_tmp[DW_DEC+9:DW_DEC]):(imo1_4_tmp[DW_DEC+9:DW_DEC]+1'b1);                                   
    end
end

endmodule
