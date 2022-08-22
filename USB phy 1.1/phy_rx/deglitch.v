module deglitch(
    input  clk  ,
    input  rst_n,

    input  r_d0 ,
    input  r_d1 ,

    output rr_d0,
    output rr_d1
);

reg  d0_reg0;
reg  d0_reg1;

reg  d1_reg0;
reg  d1_reg1;

wire d0_buf ;
wire d1_buf ;

// handle r_d0
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    d0_reg0 <= 1'b1;
else
    d0_reg0 <= r_d0;
end

assign d0_buf = r_d0 && d0_reg0;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    d0_reg1 <= 1'b1;
else
    d0_reg1 <= d0_buf;
end

assign rr_d0 = d0_buf || d0_reg1;

//handle r_d1
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    d1_reg0 <= 1'b0;
else
    d1_reg0 <= r_d1;
end

assign d1_buf = r_d1 && d1_reg0;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    d1_reg1 <= 1'b0;
else
    d1_reg1 <= d1_buf;
end

assign rr_d1 = d1_buf || d1_reg1;

endmodule
