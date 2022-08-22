module phy_rx_detchphase(
    input      clk      ,
    input      rst_n    ,

    input      r_dat    ,
    input      r_se_en  ,

    output reg rr_dat   ,
    output reg rr_dat_en,
    output reg rr_se_en 
);

reg       idle     ;
reg [1:0] clk_cnt  ;
reg [1:0] phase_num;

wire package_start;
wire propagate_en ;

assign package_start = ~r_dat && ~r_se_en &&  idle;
assign propagate_en  = clk_cnt==phase_num && ~idle;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    clk_cnt <= 2'd0;
else
    clk_cnt <= clk_cnt + 1'b1;   
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    idle <= 1'b1; 
else if(~idle && ~rr_dat && rr_se_en)
    idle <= 1'b1;    
else if(idle && package_start)
    idle <= 1'b0;            
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    phase_num <= 2'd0;    
else if(package_start)  
    phase_num <= clk_cnt + 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rr_dat <= 1'b1;
else if(rr_se_en)
    rr_dat <= 1'b1;
else if(propagate_en)    
    rr_dat <= r_dat;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rr_dat_en <= 1'b0;
else if(~idle)
    rr_dat_en <= clk_cnt==phase_num;       
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rr_se_en <= 1'b0;
else if(rr_se_en)
    rr_se_en <= 1'b0;
else if(propagate_en && r_se_en)   
    rr_se_en <= 1'b1;
end

endmodule
