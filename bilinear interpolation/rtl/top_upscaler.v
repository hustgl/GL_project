module top_upscaler #(
    parameter DW            = 8 ,
    parameter ROW_CNT_WIDTH = 12,    
    parameter COL_CNT_WIDTH = 12,
    parameter FRAME_WIDTH   = 40,
    parameter FRAME_HEIGHT  = 16
)(
    input                      clk     ,
    input                      rst_n   ,
    input                      hsync_in,
    input                      vsync_in,

    input      [DW*4-1     :0] data_in ,
    output reg [DW*6-1     :0] data_out,

    output                     vsync_o ,
    output reg                 hsync_o
);

reg  hsync_in_d1;
wire hsync_pos  ;
reg  hsync_in_d2;
reg  hsync_in_d3;

reg  [ROW_CNT_WIDTH-1:0] row_cnt     ;
reg  [COL_CNT_WIDTH-1:0] col_cnt     ;
wire [ROW_CNT_WIDTH-1:0] row_cnt_comb;

reg [DW-1:0] buf00_1, buf10_1, buf01_1, buf11_1; 
reg [DW-1:0] buf00_2, buf10_2, buf01_2, buf11_2;
reg [DW-1:0] buf00_3, buf10_3, buf01_3, buf11_3;
reg [DW-1:0] buf00_4, buf10_4, buf01_4, buf11_4;

wire          calc_en1  , calc_en2  , calc_en3  , calc_en4  ;
wire [DW-1:0] target00_1, target10_1, target01_1, target11_1;
wire          valid_o1  , valid_o2  , valid_o3  , valid_o4  ;
wire [DW-1:0] target00_2, target01_2                        ;
wire [DW-1:0] target00_3, target10_3                        ;
wire [DW-1:0] target00_4                                    ;

reg  [DW*6-1:0] my_sync_fifo1_wr_data   ;
wire [DW*4-1:0] my_sync_fifo1_rd_data   ;
wire            my_sync_fifo1_rd_en     ;
wire            my_sync_fifo1_full      ;
wire            my_sync_fifo1_empty     ;
reg             my_sync_fifo1_rd_en_d1  ;
reg  [DW*4-1:0] my_sync_fifo1_rd_data_d1;

reg  [DW*3-1:0] my_sync_fifo2_wr_data;
wire [DW*2-1:0] my_sync_fifo2_rd_data;
wire            my_sync_fifo2_rd_en  ;
wire            my_sync_fifo2_full   ;
wire            my_sync_fifo2_empty  ;

reg             last_line_flag_pre    ;
reg             last_line_flag_pre_d1 ;
wire            last_line_flag_pre_neg;
reg             last_line_flag        ;
reg             last_line_flag_d1     ;
reg             last_line_flag_d2     ;
reg             last_line_flag_d3     ;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    hsync_in_d1 <= 1'b0;
else    
    hsync_in_d1 <= hsync_in;    
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    hsync_in_d2 <= 1'b0;
else    
    hsync_in_d2 <= hsync_in_d1;    
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    hsync_in_d3 <= 1'b0;
else
    hsync_in_d3 <= hsync_in_d2;    
end

assign hsync_pos = (!hsync_in_d1) && hsync_in;

always@(posedge clk or negedge rst_n) begin
if(!rst_n) 
    row_cnt <= {ROW_CNT_WIDTH{1'b0}};
else if(row_cnt == FRAME_HEIGHT && !hsync_in)
    row_cnt <= {ROW_CNT_WIDTH{1'b0}};    
else if(hsync_pos)
    row_cnt <= row_cnt + 2'd2;    
end

assign row_cnt_comb = (hsync_pos)? (row_cnt):(row_cnt-2'd2);

always@(posedge clk or negedge rst_n) begin
if(!rst_n) 
    col_cnt <= {COL_CNT_WIDTH{1'b0}};
else if(col_cnt == FRAME_WIDTH)    
    col_cnt <= {COL_CNT_WIDTH{1'b0}};
else if(hsync_in)
    col_cnt <= col_cnt + 2'd2;    
end

// store the input data
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        buf00_1 <= {DW{1'b0}}; buf10_1 <= {DW{1'b0}};
        buf01_1 <= {DW{1'b0}}; buf11_1 <= {DW{1'b0}};
    end    
    else if(hsync_in) begin
        buf00_1 <= data_in[DW*4-1:DW*3]; buf10_1 <= data_in[DW*3-1:DW*2];
        buf01_1 <= data_in[DW*2-1:DW  ]; buf11_1 <= data_in[DW-1  :0   ];
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        buf00_2 <= {DW{1'b0}}; buf10_2 <= {DW{1'b0}};
        buf01_2 <= {DW{1'b0}}; buf11_2 <= {DW{1'b0}};        
    end
    else if(col_cnt == FRAME_WIDTH) begin  
        buf00_2 <= buf10_1;  buf10_2 <= buf10_1; //the last column
        buf01_2 <= buf11_1;  buf11_2 <= buf11_1;
    end 
    else if(hsync_in && col_cnt >= 2'd2 && col_cnt < FRAME_WIDTH) begin
        buf00_2 <= buf10_1;  buf10_2 <= data_in[DW*4-1:DW*3];
        buf01_2 <= buf11_1;  buf11_2 <= data_in[DW*2-1:DW  ];
    end
end

//sram control logic
wire sram0_cen;  wire sram0_wen;
wire sram1_cen;  wire sram1_wen;

reg  [COL_CNT_WIDTH-1:0] sram0_A;
wire [DW*2-1         :0] sram0_D;
wire [DW*2-1         :0] sram0_Q;

reg  [COL_CNT_WIDTH-1:0] sram1_A;
wire [DW*2-1         :0] sram1_D;
wire [DW*2-1         :0] sram1_Q;

assign sram0_cen = !hsync_in;
assign sram1_cen = !((hsync_in && (row_cnt_comb > 1'b0)) || last_line_flag);
assign sram0_wen = (!sram0_cen && row_cnt_comb[1])? 1'b1:1'b0; 
assign sram1_wen = (!(!sram1_cen && row_cnt_comb[1]) || last_line_flag)? 1'b1:1'b0;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sram0_A <= {COL_CNT_WIDTH{1'b0}};
else if(sram0_A == FRAME_WIDTH/2-1)
    sram0_A <= {COL_CNT_WIDTH{1'b0}};    
else if(!sram0_cen)
    sram0_A <= sram0_A + 1'b1;    
end

assign sram0_D = {data_in[DW*2-1:DW], data_in[DW-1:0]};

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sram1_A <= {COL_CNT_WIDTH{1'b0}};
else if(sram1_A == FRAME_WIDTH/2-1)
    sram1_A <= {COL_CNT_WIDTH{1'b0}};    
else if(!sram1_cen)
    sram1_A <= sram1_A + 1'b1;    
end

assign sram1_D = sram0_D;

sram #(
    .ADDR_WIDTH(COL_CNT_WIDTH),
    .DATA_WIDTH(DW*2         )
)U_sram0(
    .clk  (clk      ),
    .rst_n(rst_n    ),
    .CEN  (sram0_cen),
    .WEN  (sram0_wen),
    .A    (sram0_A  ),
    .D    (sram0_D  ),
    .Q    (sram0_Q  )
);

sram #(
    .ADDR_WIDTH(COL_CNT_WIDTH),
    .DATA_WIDTH(DW*2)
)U_sram1(
    .clk  (clk      ),
    .rst_n(rst_n    ),
    .CEN  (sram1_cen),
    .WEN  (sram1_wen),
    .A    (sram1_A  ),
    .D    (sram1_D  ),
    .Q    (sram1_Q  )
);

// buf 3 4 logic
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) 
    begin
        buf00_3 <= {DW{1'b0}}; buf10_3 <= {DW{1'b0}};
        buf01_3 <= {DW{1'b0}}; buf11_3 <= {DW{1'b0}};
    end   
    else if(last_line_flag_d1)
    begin
        buf00_3 <= sram1_Q[DW*2-1:DW]; buf10_3 <= sram1_Q[DW-1:0];
        buf01_3 <= sram1_Q[DW*2-1:DW]; buf11_3 <= sram1_Q[DW-1:0];    
    end
    else if(hsync_in_d1 && row_cnt_comb > 1'b0) 
    begin
        buf01_3 <= buf00_1; buf11_3 <= buf10_1;
        if(row_cnt_comb[1]) begin
            buf00_3 <= sram0_Q[DW*2-1:DW]; buf10_3 <= sram0_Q[DW-1:0];
        end   
        else begin
            buf00_3 <= sram1_Q[DW*2-1:DW]; buf10_3 <= sram1_Q[DW-1:0];
        end
    end
end

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) 
    begin
        buf00_4 <= {DW{1'b0}}; buf10_4 <= {DW{1'b0}};
        buf01_4 <= {DW{1'b0}}; buf11_4 <= {DW{1'b0}};
    end
    else if(last_line_flag_d2 && last_line_flag_d1) begin
        buf00_4 <= buf10_3; buf10_4 <= sram1_Q[DW*2-1:DW];
        buf01_4 <= buf11_3; buf11_4 <= sram1_Q[DW*2-1:DW];   
    end    
    else if(last_line_flag_d2 && !last_line_flag_d1) begin
        buf00_4 <= buf10_3;  buf10_4 <= buf10_3;
        buf01_4 <= buf11_3;  buf11_4 <= buf11_3;
    end
    else if(row_cnt_comb > 1'b0)
    begin
        if(hsync_in_d2 && hsync_in_d1) 
        begin
            buf00_4 <= buf10_3; buf01_4 <= buf11_3;
            buf11_4 <= buf00_1;
            if(row_cnt_comb[1])
                buf10_4 <= sram0_Q[DW*2-1:DW];
            else
                buf10_4 <= sram1_Q[DW*2-1:DW];
        end
        else if(hsync_in_d2 && !hsync_in_d1) 
        begin
            buf00_4 <= buf10_3; buf01_4 <= buf11_3;
            buf10_4 <= buf10_3; buf11_4 <= buf11_3;
        end
    end
end

// target calc logic
assign calc_en1 = hsync_in_d1;
assign calc_en2 = hsync_in_d2;
assign calc_en3 = (row_cnt_comb > 1'b0 && hsync_in_d2) || last_line_flag_d2;
assign calc_en4 = (row_cnt_comb > 1'b0 && hsync_in_d3) || last_line_flag_d3;

target_calc1 U_target_calc1_1(
    .clk     (clk       ),
    .rst_n   (rst_n     ),
    .calc_en (calc_en1  ),
    .buf00   (buf00_1   ),
    .buf10   (buf10_1   ),
    .buf01   (buf01_1   ),
    .buf11   (buf11_1   ),
    .target00(target00_1),
    .target10(target10_1),
    .target01(target01_1),
    .target11(target11_1),
    .valid_o (valid_o1  )    
);

target_calc2 U_target_calc2_1(
    .clk     (clk       ),
    .rst_n   (rst_n     ),
    .calc_en (calc_en2  ),
    .buf00   (buf00_2   ),
    .buf10   (buf10_2   ),
    .buf01   (buf01_2   ),
    .buf11   (buf11_2   ),
    .target00(target00_2),
    .target01(target01_2),
    .valid_o (valid_o2  )
);

target_calc3 U_target_calc3_1(
    .clk     (clk       ),
    .rst_n   (rst_n     ),
    .calc_en (calc_en3  ),
    .buf00   (buf00_3   ),
    .buf10   (buf10_3   ),
    .buf01   (buf01_3   ),
    .buf11   (buf11_3   ),
    .target00(target00_3),
    .target10(target10_3),
    .valid_o (valid_o3  )
);

target_calc4 U_target_calc4_1(
    .clk     (clk       ),
    .rst_n   (rst_n     ),
    .calc_en (calc_en4  ),
    .buf00   (buf00_4   ),
    .buf10   (buf10_4   ),
    .buf01   (buf01_4   ),
    .buf11   (buf11_4   ),
    .target00(target00_4),
    .valid_o (valid_o4  )
);

//last line logic
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    last_line_flag_pre <= 1'b0;
else if(last_line_flag_pre && my_sync_fifo2_empty) 
    last_line_flag_pre <= 1'b0;
else if(row_cnt == FRAME_HEIGHT && !hsync_in)  
    last_line_flag_pre <= 1'b1;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    last_line_flag_pre_d1 <= 1'b0;
else 
    last_line_flag_pre_d1 <= last_line_flag_pre;    
end

assign last_line_flag_pre_neg = last_line_flag_pre_d1 && !last_line_flag_pre;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    last_line_flag <= 1'b0;
else if(last_line_flag && sram1_A == FRAME_WIDTH/2-1)  
    last_line_flag <= 1'b0;
else if(last_line_flag_pre_neg)
    last_line_flag <= 1'b1;            
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    last_line_flag_d1 <= 1'b0;
else 
    last_line_flag_d1 <= last_line_flag;    
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    last_line_flag_d2 <= 1'b0;
else 
    last_line_flag_d2 <= last_line_flag_d1;    
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    last_line_flag_d3 <= 1'b0;
else 
    last_line_flag_d3 <= last_line_flag_d2;    
end

//output logic

always@(*) begin
if(valid_o1 && !valid_o2)
    my_sync_fifo1_wr_data = {{(2*DW){1'b0}}, {target00_1, target01_1}, {target10_1, target11_1}};
else if(valid_o1 && valid_o2)
    my_sync_fifo1_wr_data = {{target00_2, target01_2}, {target00_1, target01_1}, {target10_1, target11_1}};
else if(!valid_o1 && valid_o2)
    my_sync_fifo1_wr_data = {{target00_2, target01_2}, {(4*DW){1'b0}}};    
else
    my_sync_fifo1_wr_data = {(6*DW){1'b0}};        
end

assign my_sync_fifo1_rd_en = !my_sync_fifo1_empty;

always@(*) begin
if(valid_o3 && !valid_o4)
    my_sync_fifo2_wr_data = {{DW{1'b0}}, target00_3, target10_3};
else if(valid_o3 && valid_o4)  
    my_sync_fifo2_wr_data = {target00_4, target00_3, target10_3};
else if(!valid_o3 && valid_o4)
    my_sync_fifo2_wr_data = {target00_4, {(DW*2){1'b0}}};          
end

assign my_sync_fifo2_rd_en = !my_sync_fifo2_empty;

my_sync_fifo1 U_my_sync_fifo1_1(
    .clk    (clk                  ),
    .rst_n  (rst_n                ),
    .wr_en1 (valid_o1             ),
    .wr_en2 (valid_o2             ),
    .wr_data(my_sync_fifo1_wr_data),
    .rd_en  (my_sync_fifo1_rd_en  ),
    .rd_data(my_sync_fifo1_rd_data),
    .full   (my_sync_fifo1_full   ),
    .empty  (my_sync_fifo1_empty  )
);

my_sync_fifo2 U_my_sync_fifo2_1(
    .clk    (clk                  ),
    .rst_n  (rst_n                ),
    .wr_en1 (valid_o3             ),
    .wr_en2 (valid_o4             ),
    .wr_data(my_sync_fifo2_wr_data),
    .rd_en  (my_sync_fifo2_rd_en  ),
    .rd_data(my_sync_fifo2_rd_data),
    .full   (my_sync_fifo2_full   ),
    .empty  (my_sync_fifo2_empty  )
);

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    my_sync_fifo1_rd_en_d1 <= 1'b0;
else 
    my_sync_fifo1_rd_en_d1 <= my_sync_fifo1_rd_en;        
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    my_sync_fifo1_rd_data_d1 <= {(DW*4){1'b0}};
else    
    my_sync_fifo1_rd_data_d1 <= my_sync_fifo1_rd_data;        
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    data_out <= {(DW*6){1'b0}};
else if(my_sync_fifo1_rd_en_d1 && !my_sync_fifo2_rd_en)  
    data_out <= {{(DW*2){1'b0}}, my_sync_fifo1_rd_data_d1};
else if(my_sync_fifo1_rd_en_d1 && my_sync_fifo2_rd_en)   
    data_out <= {my_sync_fifo2_rd_data, my_sync_fifo1_rd_data_d1};
else if(!my_sync_fifo1_rd_en_d1 && my_sync_fifo2_rd_en)
    data_out <= {my_sync_fifo2_rd_data, {(DW*4){1'b0}}};         
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    hsync_o <= 1'b0;
else 
    hsync_o <= my_sync_fifo1_rd_en_d1 || my_sync_fifo2_rd_en;      
end

endmodule