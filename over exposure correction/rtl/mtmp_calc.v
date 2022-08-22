module mtmp_calc #(
    parameter DW_IN  = 10,
    parameter DW_DEC = 8
)(
    input                   clk                ,
    input                   rst_n              ,
    input      [DW_IN-1 :0] imoy_ii_jj,imoy_i_j,
    output reg [DW_DEC  :0] mtmp  
);

wire [DW_IN-1       :0] tmp       ;
wire [DW_IN+DW_DEC-1:0] tmp_ext8  ;                             ;
wire [DW_IN+DW_DEC-1:0] tmp_div800;

assign tmp      = (imoy_i_j>imoy_ii_jj)? (imoy_i_j-imoy_ii_jj):{DW_IN{1'b0}};
assign tmp_ext8 = tmp<<8                                                    ;

DW_div_pipe #(.a_width(DW_IN+DW_DEC),.b_width(10),.tc_mode(0),.rem_mode(1),.num_stages(4))
U_DW_div_pipe0(.clk(clk), .rst_n(rst_n), .en(1'b1), .a(tmp_ext8), .b(10'd800), .quotient(tmp_div800), .remainder(),.divide_by_0());

wire [DW_DEC  :0] tmp_div800_clamp = tmp_div800[DW_DEC:0]        ; // safe max 1023/800 = 1.27875

reg [(DW_DEC+1)*2-1:0] tmp_div800_pow2;
reg [(DW_DEC+1)*4-1:0] tmp_div800_pow4;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tmp_div800_pow2 <= {((DW_DEC+1)*2){1'b0}};
else
    tmp_div800_pow2 <= tmp_div800_clamp * tmp_div800_clamp;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tmp_div800_pow4 <= {((DW_DEC+1)*2){1'b0}};
else
    tmp_div800_pow4 <= tmp_div800_pow2 * tmp_div800_pow2;
end

wire [DW_DEC:0] mtmp_tmp;

assign mtmp_tmp[DW_DEC    ] = (|tmp_div800_pow4[(DW_DEC+1)*4-1:DW_DEC*4]);
assign mtmp_tmp[DW_DEC-1:0] = ((|tmp_div800_pow4[DW_DEC*4-1:DW_DEC*3]) || (tmp_div800_pow4[DW_DEC*3-1]==1'b0))? 
                              tmp_div800_pow4[DW_DEC*4-1:DW_DEC*3]:(tmp_div800_pow4[DW_DEC*4-1:DW_DEC*3]+1'b1);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    mtmp <= {(DW_DEC+1){1'b0}};
else
    mtmp <= mtmp_tmp;
end

endmodule
