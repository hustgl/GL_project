module phy_rx_s2p(
    input            clk          ,
    input            rst_n        ,

    input            r_nrzi_dat   ,
    input            r_nrzi_dat_en,
    input            r_nrzi_se_en ,

    output reg       rx_sop       ,
    output reg       rx_eop       ,
    output reg       rx_valid     ,
    input            rx_ready     ,
    output     [7:0] rx_data      
);

reg bit_buf_flag;
reg bit_buf     ;

reg [7:0] data_buf;
reg [2:0] bit_cnt ;

wire se0_flag ;
reg  sync_done;
reg  sop_flag ;

assign se0_flag = r_nrzi_dat_en && ~r_nrzi_dat && r_nrzi_se_en;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    bit_buf <= 1'b0;
else if(r_nrzi_dat_en)    
    bit_buf <= r_nrzi_dat;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    bit_buf_flag <= 1'b0;
else if(se0_flag)
    bit_buf_flag <= 1'b0;
else if(r_nrzi_dat_en)
    bit_buf_flag <= 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    data_buf <= 8'd0;
else if(r_nrzi_dat_en && bit_buf_flag)
    data_buf <= {bit_buf, data_buf[7:1]};
end

assign rx_data = data_buf;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    bit_cnt <= 3'd0;
else if(se0_flag) //handle unexpected situation
    bit_cnt <= 3'd0;
else if(r_nrzi_dat_en && bit_buf_flag) 
    bit_cnt <= bit_cnt + 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sync_done <= 1'b0;
else if(se0_flag)
    sync_done <= 1'b0;
else if(bit_cnt==3'd7 && r_nrzi_dat_en && bit_buf_flag)   
    sync_done <= 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rx_valid <= 1'b0;
else if(rx_valid && rx_ready)
    rx_valid <= 1'b0;
else if(rx_valid && r_nrzi_dat_en && bit_buf_flag)
    rx_valid <= 1'b0;
else if(bit_cnt==3'd7 && r_nrzi_dat_en && bit_buf_flag && sync_done)  
    rx_valid <= 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sop_flag <= 1'b0;
else if(bit_cnt==3'd7 && r_nrzi_dat_en && bit_buf_flag &&  sync_done)   
    sop_flag <= 1'b0;
else if(bit_cnt==3'd7 && r_nrzi_dat_en && bit_buf_flag && ~sync_done) 
    sop_flag <= 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rx_sop <= 1'b0;
else if(rx_valid && rx_ready)
    rx_sop <= 1'b0;
else if(rx_valid && r_nrzi_dat_en && bit_buf_flag)    
    rx_sop <= 1'b0;
else if(bit_cnt==3'd7 && r_nrzi_dat_en && bit_buf_flag && sop_flag)   
    rx_sop <= 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rx_eop <= 1'b0;
else if(rx_valid && rx_ready) 
    rx_eop <= 1'b0;
else if(rx_valid && r_nrzi_dat_en && bit_buf_flag)    
    rx_eop <= 1'b0;
else if(se0_flag)
    rx_eop <= 1'b1;
end

endmodule
