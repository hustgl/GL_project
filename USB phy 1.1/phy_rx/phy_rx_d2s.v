module phy_rx_d2s(
    input      rr_d0  ,
    input      rr_d1  ,

    output reg r_dat  ,
    output reg r_se_en
);

always@(*) begin
if(rr_d0 == ~rr_d1)
    r_dat = rr_d0;
else if(~rr_d0 && ~rr_d1)
    r_dat = 1'b0;
else
    r_dat = 1'b1 ;    
end

always@(*) begin
if(~rr_d0 && ~rr_d1)
    r_se_en = 1'b1;
else
    r_se_en = 1'b0;     
end

endmodule
