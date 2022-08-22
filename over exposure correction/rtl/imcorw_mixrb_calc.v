//10bit interger
//8bit decimal 
module imcorw_mixrb_calc #(
    parameter DW_IN  = 10,
    parameter DW_DEC = 8 
)(
    input                    clk         ,
    input                    rst_n       ,

    input      [1:0]         CFA         ,

    input                    vsync       ,
    input                    hsync       ,
    
    input      [DW_IN*4-1:0] data_in     ,
    output reg               hsync_out   ,
    output reg [DW_DEC:0]    imcorw_mixrb
);

reg [DW_IN-1:0] data_r,data_g1,data_g2,data_b;
always@(*) begin
    case(CFA)
    2'b00: begin
        data_g1 = data_in[DW_IN*4-1:DW_IN*3]; data_r  = data_in[DW_IN*3-1:DW_IN*2];
        data_b  = data_in[DW_IN*2-1:DW_IN]  ; data_g2 = data_in[DW_IN-1:0]        ;  
    end
    2'b01: begin
        data_r  = data_in[DW_IN*4-1:DW_IN*3]; data_g1 = data_in[DW_IN*3-1:DW_IN*2];
        data_g2 = data_in[DW_IN*2-1:DW_IN]  ; data_b  = data_in[DW_IN-1:0]        ;       
    end
    2'b10: begin
        data_b  = data_in[DW_IN*4-1:DW_IN*3]; data_g1 = data_in[DW_IN*3-1:DW_IN*2];
        data_g2 = data_in[DW_IN*2-1:DW_IN]  ; data_r  = data_in[DW_IN-1:0]        ;       
    end
    2'b11: begin
        data_g1 = data_in[DW_IN*4-1:DW_IN*3]; data_b  = data_in[DW_IN*3-1:DW_IN*2];
        data_r  = data_in[DW_IN*2-1:DW_IN]  ; data_g2 = data_in[DW_IN-1:0]        ;       
    end
    endcase
end

wire [DW_IN  :0] imcing_comb         ;
reg  [DW_IN-1:0] imcing,imcinr,imcinb;
reg              hsync_d1            ;
reg              vsync_d1            ;

assign imcing_comb = (data_g1 + data_g2)>>1;

//clk 1
always@(posedge clk) 
begin
    if(!rst_n) begin
        imcing   <= {DW_IN{1'b0}};
        imcinr   <= {DW_IN{1'b0}};
        imcinb   <= {DW_IN{1'b0}};
        hsync_d1 <= 1'b0         ;
        vsync_d1 <= 1'b0         ;
    end
    else begin
        imcing   <= imcing_comb[DW_IN-1:0];
        imcinr   <= data_r                ;
        imcinb   <= data_b                ;
        hsync_d1 <= hsync                 ;
        vsync_d1 <= vsync                 ;
    end
end

wire [DW_IN+DW_DEC-1:0] imcinr_ext = (imcinr << DW_DEC);  //extend 8 bits
wire [DW_IN+DW_DEC-1:0] imcinb_ext = (imcinb << DW_DEC);
wire [DW_IN+DW_DEC-1:0] imcor_tmp, imcob_tmp;
reg  [DW_IN+DW_DEC-1:0] imcor, imcob        ;

// the quotient: 10bit.8bit, 18 bits in all
// the second clk posedge the quotient can be sampled, delay 1 clk
// clk 2-4
DW_div_pipe #(.a_width(DW_IN+DW_DEC), .b_width(DW_IN), .tc_mode(0), .rem_mode(1), .num_stages(4))
U_DIV0 (.clk(clk), .rst_n(rst_n), .en(1'b1), 
.a(imcinr_ext), .b(imcing), .quotient(imcor_tmp), .remainder(), .divide_by_0());

DW_div_pipe #(.a_width(DW_IN+DW_DEC), .b_width(DW_IN), .tc_mode(0), .rem_mode(1), .num_stages(4))
U_DIV1 (.clk(clk), .rst_n(rst_n), .en(1'b1), 
.a(imcinb_ext), .b(imcing), .quotient(imcob_tmp), .remainder(), .divide_by_0());

//clk 5
always@(posedge clk) 
begin
    if(!rst_n) begin
        imcor <= {(DW_IN+DW_DEC){1'b0}};
        imcob <= {(DW_IN+DW_DEC){1'b0}};
    end
    else begin
        imcor <= (&imcor_tmp[DW_IN+DW_DEC-1:DW_DEC])? {imcor_tmp[DW_IN+DW_DEC-1:DW_DEC], {DW_DEC{1'b0}}}: imcor_tmp;
        imcob <= (&imcob_tmp[DW_IN+DW_DEC-1:DW_DEC])? {imcob_tmp[DW_IN+DW_DEC-1:DW_DEC], {DW_DEC{1'b0}}}: imcob_tmp;
    end
end

reg [DW_IN+DW_DEC-1:0] imcor_1_diff, imcob_1_diff;

// diff max = 64, 7 bits
always@(*) begin
if(imcor>18'd192 && imcor<18'd320)
    imcor_1_diff = (imcor>18'd256)? (imcor-18'd256):(18'd256-imcor);
else
    imcor_1_diff = 18'd64;
end

always@(*) begin
if(imcob>18'd192 && imcob<18'd320)
    imcob_1_diff = (imcob>18'd256)? (imcob-18'd256):(18'd256-imcob);
else
    imcob_1_diff = 18'd64;
end

wire [DW_DEC*2:0] imcorw_tmp,imcobw_tmp; //The integer part only store 1 bit, decimal part 16 bits
reg  [DW_DEC:0  ] imcorw,imcobw;         // max 1.00000000 min 0
wire [DW_DEC:0  ] imcorw_tmp_clamp;
wire [DW_DEC:0  ] imcobw_tmp_clamp;

assign imcorw_tmp = {1'b1, {(DW_DEC*2){1'b0}} } - ((imcor_1_diff * imcor_1_diff) << 4);
assign imcobw_tmp = {1'b1, {(DW_DEC*2){1'b0}} } - ((imcob_1_diff * imcob_1_diff) << 4);

assign imcorw_tmp_clamp[DW_DEC    ] = imcorw_tmp[DW_DEC*2];
assign imcorw_tmp_clamp[DW_DEC-1:0] = ((imcorw_tmp[DW_DEC-1]==1'b0) || (&imcorw_tmp[DW_DEC*2-1:DW_DEC])) ? imcorw_tmp[DW_DEC*2-1:DW_DEC]: (imcorw_tmp[DW_DEC*2-1:DW_DEC]+1'b1);

assign imcobw_tmp_clamp[DW_DEC    ] = imcobw_tmp[DW_DEC*2];
assign imcobw_tmp_clamp[DW_DEC-1:0] = ((imcobw_tmp[DW_DEC-1]==1'b0) || (&imcobw_tmp[DW_DEC*2-1:DW_DEC])) ? imcobw_tmp[DW_DEC*2-1:DW_DEC]: (imcobw_tmp[DW_DEC*2-1:DW_DEC]+1'b1);

//clk 6
always@(posedge clk) begin
if(!rst_n)
    imcorw <= {(DW_DEC+1){1'b0}};     
else
    imcorw <= imcorw_tmp_clamp;
end

always@(posedge clk) begin
if(!rst_n)
    imcobw <= {(DW_DEC+1){1'b0}};     
else
    imcobw <= imcobw_tmp_clamp;
end

//select the smaller one
//clk 7
always@(posedge clk) begin
if(!rst_n)
    imcorw_mixrb <= {(DW_DEC+1){1'b0}};
else if(imcorw >= imcobw)
    imcorw_mixrb <= imcobw;
else
    imcorw_mixrb <= imcorw;
end

endmodule
