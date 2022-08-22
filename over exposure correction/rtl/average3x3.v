module average3x3 #(
    parameter DW_DEC = 8
)(
    input             clk          ,
    input             rst_n        ,
    input  [DW_DEC:0] in1          ,
    input  [DW_DEC:0] in2          ,
    input  [DW_DEC:0] in3          ,
    input             filter_start ,
    input             filter_end   ,
    output [DW_DEC:0] average_out  ,
    output            average_valid
);

localparam AVERAGE_DELAY = 5;

reg [DW_DEC:0] buf11,buf12,buf13;
reg [DW_DEC:0] buf21,buf22,buf23;
reg [DW_DEC:0] buf31,buf32,buf33;

reg filter_end_d1, filter_start_d1, filter_end_d2;
reg array_ready;
reg [AVERAGE_DELAY-1:0] average_delay;

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        filter_end_d1 <= 1'b0;
        filter_end_d2 <= 1'b0;
    end    
    else begin
        filter_end_d1 <= filter_end   ;
        filter_end_d2 <= filter_end_d1;
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    filter_start_d1 <= 1'b0;
else
    filter_start_d1 <= filter_start;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    array_ready <= 1'b0;
else if(filter_end_d2)
    array_ready <= 1'b0;
else if(filter_start_d1)
    array_ready <= 1'b1;
end

//wait 1clk and get array 2
//clk1~2
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        buf11 <= {(DW_DEC+1){1'b0}}; buf12 <= {(DW_DEC+1){1'b0}}; buf13 <= {(DW_DEC+1){1'b0}};
        buf21 <= {(DW_DEC+1){1'b0}}; buf22 <= {(DW_DEC+1){1'b0}}; buf23 <= {(DW_DEC+1){1'b0}};
        buf31 <= {(DW_DEC+1){1'b0}}; buf32 <= {(DW_DEC+1){1'b0}}; buf33 <= {(DW_DEC+1){1'b0}};
    end
    else if(filter_start) begin
        buf12 <= in1;  buf13 <= in1;
        buf22 <= in2;  buf23 <= in2;
        buf32 <= in3;  buf33 <= in3;
    end
    else if(filter_end_d1) begin
        buf11 <= buf12; buf12 <= buf13; buf13 <= buf13;
        buf21 <= buf22; buf22 <= buf23; buf23 <= buf23;
        buf31 <= buf32; buf32 <= buf33; buf33 <= buf33;
    end
    else begin
        buf11 <= buf12; buf12 <= buf13; buf13 <= in1;
        buf21 <= buf22; buf22 <= buf23; buf23 <= in2;
        buf31 <= buf32; buf32 <= buf33; buf33 <= in3;
    end
end

reg [DW_DEC+2:0] row1_sum;
reg [DW_DEC+2:0] row2_sum; 
reg [DW_DEC+2:0] row3_sum; 

//clk3
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        row1_sum <= {(DW_DEC+3){1'b0}};
        row2_sum <= {(DW_DEC+3){1'b0}};
        row3_sum <= {(DW_DEC+3){1'b0}};
    end
    else begin
        row1_sum <= buf11+buf12+buf13;
        row2_sum <= buf21+buf22+buf23;
        row3_sum <= buf31+buf32+buf33;
    end
end

//clk4
reg [DW_DEC+4:0] sum3x3;
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sum3x3 <= {(DW_DEC+5){1'b0}};
else
    sum3x3 <= row1_sum + row2_sum + row3_sum;
end
    
//clk5~7
wire [DW_DEC+4:0] average_tmp;
DW_div_pipe #(.a_width(DW_DEC+5),.b_width(4),.tc_mode(0),.rem_mode(1),.num_stages(4))
U1(.clk(clk), .rst_n(rst_n), .en(1'b1), .a(sum3x3), .b(4'd9), .quotient(average_tmp), .remainder(),
.divide_by_0());

assign average_out = average_tmp[DW_DEC:0]; //safe

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    average_delay <= {AVERAGE_DELAY{1'b0}};
else
    average_delay <= {average_delay[AVERAGE_DELAY-2:0], array_ready};
end

assign average_valid = average_delay[AVERAGE_DELAY-1];

endmodule
