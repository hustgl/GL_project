module phy_rx_nrzi(
    input      clk          ,
    input      rst_n        ,

    input      rr_dat       ,
    input      rr_dat_en    ,
    input      rr_se_en     ,

    output reg r_nrzi_dat   ,
    output reg r_nrzi_dat_en,
    output reg r_nrzi_se_en  
);

reg        data_buf;
wire       se0_flag;
reg  [2:0] count6  ;

assign se0_flag = ~rr_dat && rr_dat_en && rr_se_en;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    data_buf <= 1'b1  ;
else if(se0_flag)
    data_buf <= 1'b1  ;
else if(rr_dat_en) 
    data_buf <= rr_dat;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    r_nrzi_dat <= 1'b1;
else if(r_nrzi_se_en)
    r_nrzi_dat <= 1'b1;
else if(se0_flag)
    r_nrzi_dat <= 1'b0;
else if(rr_dat_en)
    r_nrzi_dat <= ~(rr_dat ^ data_buf);
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    count6 <= 3'd0;
else if(se0_flag || (rr_dat_en && (rr_dat^data_buf)))
    count6 <= 3'd0;
else if(rr_dat_en && rr_dat==data_buf)    
    count6 <= count6 + 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    r_nrzi_dat_en <= 1'b0;
else 
    r_nrzi_dat_en <= rr_dat_en && (count6!=3'd6);
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    r_nrzi_se_en <= 1'b0;
else if(r_nrzi_se_en)    
    r_nrzi_se_en <= 1'b0;
else if(rr_dat_en && rr_se_en)
    r_nrzi_se_en <= 1'b1;
end

endmodule
