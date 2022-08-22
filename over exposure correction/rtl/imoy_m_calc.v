module imoy_m_calc #(
    parameter DW_DEC      = 8        ,
    parameter DW_IN       = 10       ,
    parameter M_DELAY     = 21       ,
    parameter IMCIN_DELAY = M_DELAY+4
)(
    input                clk           ,
    input                rst_n         ,
    input  [DW_IN*4-1:0] imcin         ,
    input                imoy_m_calc_en,
    output [DW_IN-1  :0] imoy_i_j      ,
    output [DW_DEC   :0] m_d           ,   
    output [DW_IN*4-1:0] imcin_d       
);

wire [DW_DEC :0]   m                            ;

reg  [DW_DEC :0]   m_delay     [M_DELAY-1    :0];
reg  [DW_IN*4-1:0] imcin_delay [IMCIN_DELAY-1:0];

integer i;

//2clk
imoy_calc U_imoy_calc0(
    .clk         (clk           ),
    .rst_n       (rst_n         ),
    .imoy_calc_en(imoy_m_calc_en),
    .imcin       (imcin         ),
    .imoy        (imoy_i_j      )
);

//2clk
tanhcurve U_tanhcurve0(
    .clk  (clk  ),
    .rst_n(rst_n),

    .y1_0 (9'd0  ),.y1_1 (9'd0  ),.y1_2 (9'd0  ),.y1_3 (9'd0  ),.y1_4 (9'd0  ),.y1_5 (9'd0  ),.y1_6 (9'd0  ),.y1_7 (9'd0  ),.y1_8 (9'd0  ),.y1_9 (9'd0  ),.y1_10(9'd0  ),.y1_11(9'd0  ),.y1_12(9'd0  ),
    .y1_13(9'd0  ),.y1_14(9'd0  ),.y1_15(9'd1  ),.y1_16(9'd1  ),.y1_17(9'd1  ),.y1_18(9'd1  ),.y1_19(9'd2  ),.y1_20(9'd2  ),.y1_21(9'd3  ),.y1_22(9'd4  ),.y1_23(9'd5  ),.y1_24(9'd7  ),.y1_25(9'd9  ),
    .y1_26(9'd11 ),.y1_27(9'd15 ),.y1_28(9'd19 ),.y1_29(9'd24 ),.y1_30(9'd31 ),.y1_31(9'd38 ),.y1_32(9'd48 ),.y1_33(9'd59 ),.y1_34(9'd72 ),.y1_35(9'd87 ),.y1_36(9'd103),.y1_37(9'd119),.y1_38(9'd137),
    .y1_39(9'd153),.y1_40(9'd169),.y1_41(9'd184),.y1_42(9'd197),.y1_43(9'd208),.y1_44(9'd218),.y1_45(9'd225),.y1_46(9'd232),.y1_47(9'd237),.y1_48(9'd241),.y1_49(9'd245),.y1_50(9'd247),.y1_51(9'd249),
    .y1_52(9'd251),.y1_53(9'd252),.y1_54(9'd253),.y1_55(9'd254),.y1_56(9'd254),.y1_57(9'd255),.y1_58(9'd255),.y1_59(9'd255),.y1_60(9'd255),.y1_61(9'd256),.y1_62(9'd256),.y1_63(9'd256),.y1_64(9'd256),

    .in    (imoy_i_j),
    .out_d2(m       )    
);

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i <= M_DELAY-1; i = i+1) begin
            m_delay[i] <= {(DW_DEC+1){1'b0}};
        end
    end    
    else begin
        for(i = M_DELAY-1; i > 0; i = i-1) begin
            m_delay[i] <= m_delay[i-1];
        end
        m_delay[0] <= m;
    end    
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i <= IMCIN_DELAY-1; i = i+1) begin
            imcin_delay[i] <= {DW_IN{1'b0}};
        end
    end    
    else begin
        for(i = IMCIN_DELAY-1; i > 0; i = i-1) begin
            imcin_delay[i] <= imcin_delay[i-1];
        end
        imcin_delay[0] <= imcin;
    end    
end

assign m_d     = m_delay[M_DELAY-1]        ;
assign imcin_d = imcin_delay[IMCIN_DELAY-1];


endmodule
