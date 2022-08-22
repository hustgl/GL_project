module phy_tx_nrzi(
    input      clk           ,
    input      rst_n         ,

    input      tx_dat        ,
    input      tx_dat_en     ,
    output     tx_nrzi_stop  ,
    input      tx_nrzi_en    ,
    input      tx_se_en      ,

    output reg tx_nrzi_dat   ,
    output reg tx_nrzi_dat_en,
    output reg tx_nrzi_se_en 
);

reg [2:0] clk6_cnt;

wire nrzi_flip;
wire nrzi_hold;

assign nrzi_hold = tx_dat;
assign nrzi_flip = ~tx_dat || (tx_dat_en && tx_nrzi_stop);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_nrzi_dat <= 1'b1;
else if(tx_dat_en && tx_nrzi_en && nrzi_flip)
    tx_nrzi_dat <= ~tx_nrzi_dat;
else if(tx_dat_en && tx_nrzi_en && nrzi_hold)
    tx_nrzi_dat <= tx_nrzi_dat;
else if(tx_dat_en && ~tx_nrzi_en)
    tx_nrzi_dat <= tx_dat;  
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    clk6_cnt <= 3'd0;
else if(tx_dat_en && ~tx_dat)
    clk6_cnt <= 3'd0;
else if(clk6_cnt == 3'd6 && tx_dat_en)
    clk6_cnt <= 3'd0;
else if(tx_dat_en && tx_nrzi_en && tx_dat && ~tx_nrzi_stop)    
    clk6_cnt <= clk6_cnt+1'b1;
end

assign tx_nrzi_stop = clk6_cnt==3'd6;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_nrzi_dat_en <= 1'b0;
else if(tx_dat_en)
    tx_nrzi_dat_en <= 1'b1;
else   
    tx_nrzi_dat_en <= 1'b0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_nrzi_se_en <= 1'b0;
else if(tx_dat_en && ~tx_nrzi_stop)
    tx_nrzi_se_en <= tx_se_en;
end

endmodule
