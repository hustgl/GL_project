`timescale 1ns/1ns

module tb_phy_tx();

reg        clk     ;
reg        rst_n   ;                
reg        tx_sop  ;
reg        tx_eop  ;
reg        tx_valid;
wire       tx_ready;
reg  [7:0] tx_data ;
                     
wire       t_d0    ;
wire       t_d1    ;

phy_tx U_phy_tx0(
    .clk     (clk     ),
    .rst_n   (rst_n   ),
                       
    .tx_sop  (tx_sop  ),
    .tx_eop  (tx_eop  ),
    .tx_valid(tx_valid),
    .tx_ready(tx_ready),
    .tx_data (tx_data ),
                       
    .t_d0    (t_d0    ),
    .t_d1    (t_d1    )
);

integer i;

initial begin
    clk = 1'b0; rst_n = 1'b0; tx_sop = 1'b0; tx_eop = 1'b0;
    tx_valid = 1'b0;  tx_data = 8'd0;
    #30 rst_n = 1'b1;
    tx_packages(3'd4);
//    tx_case2;
    $finish;
end

always #10 clk = ~clk;

initial begin
    $fsdbDumpfile("wave_phy_tx.fsdb");
    $fsdbDumpvars;
end

task tx_case1;
begin
    @(posedge clk) begin
        tx_sop   <= 1'b1;
        tx_eop   <= 1'b1;
        tx_valid <= 1'b1;
        tx_data  <= 8'd0;
    end
    wait(tx_ready == 1'b1);
    @(posedge clk) tx_sop <= 1'b0;
    repeat(31) @(posedge clk);
    @(posedge clk) begin
        tx_valid <= 1'b0;
        tx_eop   <= 1'b0;
    end
    repeat(30) @(posedge clk);
end
endtask

task tx_case2;
begin
    @(posedge clk) begin
        tx_sop   <= 1'b1;
        tx_eop   <= 1'b0;
        tx_valid <= 1'b1;
        tx_data  <= 8'd0;
    end
    wait(tx_ready == 1'b1);
    @(posedge clk) begin
        tx_sop  <= 1'b0 ;
        tx_eop  <= 1'b1 ;
        tx_data <= 8'hff;
    end
    #1 wait(tx_ready == 1'b1);
    @(posedge clk) begin
        tx_valid <= 1'b0;
        tx_eop   <= 1'b0;
    end
    repeat(100) @(posedge clk);
end 
endtask

reg [7:0] data_buf [7:0];

//LSB first
initial begin
    data_buf[0] = 8'b00000000;
    data_buf[1] = 8'b11111111; 
    data_buf[2] = 8'b00001111;
    data_buf[3] = 8'b11111100;
    data_buf[4] = 8'b11001100;
    data_buf[5] = 8'b10101010; 
    data_buf[6] = 8'b00011111;
    data_buf[7] = 8'b11100000;
end

task tx_packages;
input [2:0] num;
begin
    @(posedge clk);
    i = 0;
    while(i < num) begin
        assign tx_sop   = (i==3'd0 )?1'b1:1'b0;
        assign tx_eop   = (i==num-1)?1'b1:1'b0;

        assign tx_valid = (i<num)?1'b1:1'b0;   
        assign tx_data  = data_buf[i];

        @(posedge clk) begin
        if(tx_ready == 1'b1)
            i <= i+1;
        end
    end
    repeat(300) @(posedge clk);
end
endtask
   
endmodule
