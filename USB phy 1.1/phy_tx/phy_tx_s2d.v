module phy_tx_s2d(
    input      clk           ,
    input      rst_n         ,

    input      tx_nrzi_dat   ,
    input      tx_nrzi_dat_en,
    input      tx_nrzi_se_en ,

    output reg t_d0          ,
    output reg t_d1
);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    t_d0 <= 1'b1;
else if(tx_nrzi_dat_en)
    t_d0 <= tx_nrzi_dat;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    t_d1 <= 1'b0;
else if(tx_nrzi_dat_en && tx_nrzi_se_en)
    t_d1 <= tx_nrzi_dat;
else if(tx_nrzi_dat_en)    //JK encoding
    t_d1 <= ~tx_nrzi_dat;
end


endmodule
