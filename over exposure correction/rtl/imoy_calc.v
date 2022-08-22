// 2 clks get the average
module imoy_calc #(
    parameter DW_IN = 10
)(
    input                    clk         ,
    input                    rst_n       ,
    input                    imoy_calc_en,
    input      [DW_IN*4-1:0] imcin       ,
    output reg [DW_IN-1  :0] imoy        
);

wire [DW_IN:0] imcin_sum1 = imcin[DW_IN*4-1:DW_IN*3] + imcin[DW_IN*3-1:DW_IN*2];
wire [DW_IN:0] imcin_sum2 = imcin[DW_IN*2-1:DW_IN  ] + imcin[DW_IN-1  :0]      ;

reg  [DW_IN:0] imcin_sum1_d1, imcin_sum2_d1;

wire [DW_IN+1:0] imcin_sum;
wire [DW_IN-1:0] imoy_temp;

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        imcin_sum1_d1 <= {(DW_IN+1){1'b0}};
        imcin_sum2_d1 <= {(DW_IN+1){1'b0}};
    end  
    else if(imoy_calc_en) begin
        imcin_sum1_d1 <= imcin_sum1;
        imcin_sum2_d1 <= imcin_sum2;
    end
end

assign imcin_sum = imcin_sum1_d1 + imcin_sum2_d1;
assign imoy_temp = ((&imcin_sum[DW_IN+1:2]) || (imcin_sum[1]==1'b0))? imcin_sum[DW_IN+1:2]:(imcin_sum[DW_IN+1:2]+1'b1);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    imoy <= {DW_IN{1'b0}};
else
    imoy <= imoy_temp;
end


endmodule
