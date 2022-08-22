module phy_tx_p2s(
    input            clk         ,   //48M
    input            rst_n       ,

    input            tx_sop      ,
    input            tx_eop      ,
    input            tx_valid    ,
    output       reg tx_ready    ,
    input  [7:0]     tx_data     ,

    output       reg tx_dat      ,
    output       reg tx_dat_en   ,
    input            tx_nrzi_stop,   //delay 4 clks to insert 0
    output       reg tx_nrzi_en  ,
    output       reg tx_se_en    
);

//control signal
reg  [1:0] operation   ; //the operation flow
wire       sync_save   ; //prepare to send sync
wire       tx_data_save; //store tx_data, once a byte
wire       eop_save    ; //send eop
wire       shift_en    ; //send bit0, change to next bit
reg        eop_flag    ;
wire       tx_en       ; //every 4clks tx once
wire       byte_over   ; //have sent a byte
wire       eop_over    ; //have sent 2bits SE0 and J

//buf and cnt
reg [7:0] tx_data_buf;
reg [2:0] bit_cnt    ;
reg [1:0] tx_cnt     ;

//constant
wire [7:0] sync      ;
wire [7:0] eop       ;

assign sync = 8'b1000_0000;
assign eop  = 8'b1111_1100; //0xfc

//work state
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    operation <= 2'd0;
else if(sync_save)
    operation <= 2'd1;
else if(eop_save)
    operation <= 2'd3;
else if(byte_over)
    operation <= 2'd2;
else if(eop_over) 
    operation <= 2'd0;
end

//cnt logic, 2bits, modulus 4
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_cnt <= 2'd0;
else if(~(|operation))
    tx_cnt <= 2'd0;
else 
    tx_cnt <= tx_cnt + 2'd1;
end

assign tx_en = (&tx_cnt);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    bit_cnt <= 3'd0;
else if(~(|operation))//operation = 0, bit_cnt = 0
    bit_cnt <= 3'd0;
else if(tx_en && ~tx_nrzi_stop)
    bit_cnt <= bit_cnt + 1'b1;
end

//data flow
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_data_buf <= 8'd0;
else if(sync_save)
    tx_data_buf <= sync;
else if(eop_save)
    tx_data_buf <= eop;    
else if(tx_data_save)
    tx_data_buf <= tx_data;
else if(shift_en)
    tx_data_buf <= {1'b1, tx_data_buf[7:1]};
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_dat <= 1'b1;
else if(tx_en && ~tx_nrzi_stop)
    tx_dat <= tx_data_buf[0];
end

assign sync_save    = tx_sop        && tx_valid && (~(|operation)); //operation = 0
assign byte_over    = bit_cnt==3'd7 && tx_en    && ~tx_nrzi_stop  ; 

assign tx_data_save = byte_over && ((operation==2'd1) || (operation==2'd2));
assign eop_save     = byte_over && eop_flag                                ;
assign shift_en     = tx_en     && (bit_cnt!=3'd7) && ~tx_nrzi_stop        ;

assign eop_over     = operation==3'd3 && bit_cnt==3'd3 && tx_en;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_ready <= 1'b0;
else if(tx_valid && tx_ready)
    tx_ready <= 1'b0;
else if(&operation)
    tx_ready <= 1'b0;
else if(&bit_cnt && tx_cnt==2'd2 && ~tx_nrzi_stop)
    tx_ready <= 1'b1;    
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_dat_en <= 1'b0;
else if(tx_en)
    tx_dat_en <= 1'b1;
else
    tx_dat_en <= 1'b0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_nrzi_en <= 1'b0;
else if(operation == 2'd0)
    tx_nrzi_en <= 1'b0;
else if(operation == 2'd3 && ~tx_nrzi_stop)
    tx_nrzi_en <= 1'b0;
else
    tx_nrzi_en <= 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx_se_en <= 1'b0;
else if(operation==2'd0)
    tx_se_en <= 1'b0;
else if(operation==2'd3 && bit_cnt<=3'd1)
    tx_se_en <= 1'b1;
else 
    tx_se_en <= 1'b0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    eop_flag <= 1'b0;
else if(eop_save)
    eop_flag <= 1'b0;
else if(tx_valid && tx_ready && tx_eop)
    eop_flag <= 1'b1;
end

endmodule
