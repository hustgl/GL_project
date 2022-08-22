module uart2apb #(
    parameter APB_ADDR_WIDTH = 16,
    parameter APB_DATA_WIDTH = 32
)(
    input         clk        ,
    input         rst_n      ,

    //datas from upstream module, rx tx cross connect
    input         rx         ,
    output reg    tx         ,

    //apb bus
    output        apb_psel   ,
    output [15:0] apb_paddr  ,
    output [31:0] apb_pwdata ,
    output        apb_pwrite ,
    output        apb_penable,    
    input         apb_pready ,
    input  [31:0] apb_prdata    
);

localparam  IDLE             = 5'd0 ,
            RECV_CMD         = 5'd1 ,
            RECV_ADDR_LOW    = 5'd2 ,
            RECV_ADDR_HIGH   = 5'd3 ,
            RECV_WDATA_BYTE0 = 5'd4 ,
            RECV_WDATA_BYTE1 = 5'd5 ,
            RECV_WDATA_BYTE2 = 5'd6 ,
            RECV_WDATA_BYTE3 = 5'd7 ,
            APB_W_SEL        = 5'd8 ,
            APB_W_EN         = 5'd9 ,
            APB_R_SEL        = 5'd10,
            APB_R_EN         = 5'd11,
            SEND_TX_BYTE0    = 5'd12,
            SEND_TX_DELAY0   = 5'd13,
            SEND_TX_BYTE1    = 5'd14,
            SEND_TX_DELAY1   = 5'd15,
            SEND_TX_BYTE2    = 5'd16,
            SEND_TX_DELAY2   = 5'd17,
            SEND_TX_BYTE3    = 5'd18;

reg [4:0] fsm_cs;
reg [4:0] fsm_ns;

//negedge detection
wire      rx_nedge;
reg [2:0] rx_delay;
wire      rx_sync ;

//buffer signal
reg [7:0]  uart_buf      ; // store the byte received temporarily
reg [7:0]  uart_cmd_buf  ;
reg [15:0] uart_addr_buf ;
reg [31:0] uart_wdata_buf;
reg [31:0] apb_prdata_buf; // APB rdata buffer 


//flag signal
reg       uart_flag           ; // the flag of receiving a byte
reg       uart_addr_flag      ; //classify the addr received
reg [1:0] uart_wdata_flag     ; //classify the wdata received
reg [1:0] uart_send_rdata_flag; //classify the rdata sent
wire      uart_frame_end      ;        

//state signal
wire      uart_recv_state; // the states of receving uart bytes
wire      uart_send_state;

//uart cnt
reg  [8:0] uart_clk_cnt     ;
wire       uart_clk_cnt_en  ;
reg  [3:0] uart_bit_cnt     ;
wire       uart_delay_cnt_en;
reg  [6:0] uart_delay_cnt   ;

wire [7:0] uart_tx_buf      ;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fsm_cs <= IDLE;
else
    fsm_cs <= fsm_ns;
end

//must handle uart datas byte by byte
always @(*) begin
case(fsm_cs)
    IDLE: begin
        if(rx_nedge) //wait for the first rx negedge 
            fsm_ns = RECV_CMD;
        else
            fsm_ns = IDLE;        
    end
    RECV_CMD: begin // the negedge here means the start of next byte
        if(rx_nedge && (uart_flag || uart_frame_end)) //uart_flag==1 means the reception of last byte finishes
            fsm_ns = RECV_ADDR_LOW;
        else 
            fsm_ns = RECV_CMD;       
    end
    RECV_ADDR_LOW:begin
        if(rx_nedge && (uart_flag || uart_frame_end))
            fsm_ns = RECV_ADDR_HIGH;
        else
            fsm_ns = RECV_ADDR_LOW; 
    end
    RECV_ADDR_HIGH:begin
        if(uart_cmd_buf == 8'ha5) begin //write, a5 and 5a is user-defined
            if(rx_nedge && (uart_flag || uart_frame_end))
                fsm_ns = RECV_WDATA_BYTE0;
        end
        else if(uart_cmd_buf == 8'h5a) begin
            if(uart_frame_end)
                fsm_ns = APB_R_SEL;
        end
        else
            fsm_ns = IDLE; //cmd error
    end
    RECV_WDATA_BYTE0:begin
        if(rx_nedge && (uart_flag || uart_frame_end))
            fsm_ns = RECV_WDATA_BYTE1;
        else
            fsm_ns = RECV_WDATA_BYTE0;        
    end
    RECV_WDATA_BYTE1:begin
        if(rx_nedge && (uart_flag || uart_frame_end))
            fsm_ns = RECV_WDATA_BYTE2;
        else
            fsm_ns = RECV_WDATA_BYTE1;        
    end 
    RECV_WDATA_BYTE2:begin
        if(rx_nedge && (uart_flag || uart_frame_end))
            fsm_ns = RECV_WDATA_BYTE3;
        else
            fsm_ns = RECV_WDATA_BYTE2;        
    end
    RECV_WDATA_BYTE3:begin
        if(uart_frame_end)
            fsm_ns = APB_W_SEL;
        else
            fsm_ns = RECV_WDATA_BYTE3;        
    end
    APB_W_SEL:
        fsm_ns = APB_W_EN;
    APB_W_EN:begin
        if(apb_pready) 
            fsm_ns = IDLE;
        else
            fsm_ns = APB_W_EN;    
    end
    APB_R_SEL:begin
        fsm_ns = APB_R_EN;
    end
    APB_R_EN:begin
        if(apb_pready)
            fsm_ns = SEND_TX_BYTE0;
        else
            fsm_ns = APB_R_EN;    
    end
    SEND_TX_BYTE0:begin
        if(uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433)
            fsm_ns = SEND_TX_DELAY0;
        else
            fsm_ns = SEND_TX_BYTE0;        
    end
    SEND_TX_DELAY0:begin
        if(uart_delay_cnt == 7'd99)
            fsm_ns = SEND_TX_BYTE1;
        else
            fsm_ns = SEND_TX_DELAY0;    
    end
    SEND_TX_BYTE1:begin
        if(uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433)
            fsm_ns = SEND_TX_DELAY1;
        else
            fsm_ns = SEND_TX_BYTE1;              
    end
    SEND_TX_DELAY1:begin
        if(uart_delay_cnt == 7'd99)
            fsm_ns = SEND_TX_BYTE2;
        else
            fsm_ns = SEND_TX_DELAY1;    
    end
    SEND_TX_BYTE2:begin
        if(uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433)
            fsm_ns = SEND_TX_DELAY2;
        else
            fsm_ns = SEND_TX_BYTE2;              
    end 
    SEND_TX_DELAY2:begin
        if(uart_delay_cnt == 7'd99)
            fsm_ns = SEND_TX_BYTE3;
        else
            fsm_ns = SEND_TX_DELAY2;    
    end
    SEND_TX_BYTE3:begin
        if(uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433)
            fsm_ns = IDLE;
        else
            fsm_ns = SEND_TX_BYTE3;              
    end
    default: fsm_ns = IDLE;                                
endcase    
end

always@(posedge clk or negedge rst_n) 
begin
if(!rst_n)
    rx_delay <= 3'b000;
else
    rx_delay <= {rx_delay[1:0], rx};    
end

assign rx_nedge = rx_delay[2:1]==2'b10;
assign rx_sync  = rx_delay[2];

assign uart_recv_state = fsm_cs==RECV_CMD || fsm_cs==RECV_ADDR_LOW || fsm_cs==RECV_ADDR_HIGH || fsm_cs==RECV_WDATA_BYTE0 
|| fsm_cs==RECV_WDATA_BYTE1 || fsm_cs==RECV_WDATA_BYTE2 || fsm_cs==RECV_WDATA_BYTE3;

assign uart_frame_end = uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433;

//uart_flag pulled up after receiving a byte
//pulled down if a byte starts
//pulled down when APB read datas sent ,thus can make full use of uart_clk_cnt and uart_bit_cnt
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    uart_flag <= 1'b1;
else if(rx_nedge)   
    uart_flag <= 1'b0;
else if(uart_recv_state && uart_frame_end) 
    uart_flag <= 1'b1;//There may be a delay between bytes
else if(fsm_cs==APB_R_EN && fsm_ns==SEND_TX_BYTE0)
    uart_flag <= 1'b0;    
else if(fsm_cs==IDLE)
    uart_flag <= 1'b1;
end


assign uart_clk_cnt_en = fsm_cs==RECV_CMD || fsm_cs==RECV_ADDR_LOW || fsm_cs==RECV_ADDR_HIGH || fsm_cs==RECV_WDATA_BYTE0 
|| fsm_cs==RECV_WDATA_BYTE1 || fsm_cs==RECV_WDATA_BYTE2 || fsm_cs==RECV_WDATA_BYTE3|| fsm_cs==SEND_TX_BYTE0 || fsm_cs==SEND_TX_BYTE1 
|| fsm_cs==SEND_TX_BYTE2 || fsm_cs==SEND_TX_BYTE3;

//~uart_flag is essential, cnt should be forbidden while uart delay
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    uart_clk_cnt <= 9'd0;
else if(uart_clk_cnt_en && ~uart_flag) begin  
    if(uart_clk_cnt == 9'd433)
        uart_clk_cnt <= 9'd0;
    else
        uart_clk_cnt <= uart_clk_cnt + 9'd1;
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    uart_bit_cnt <= 4'd0;
else if(uart_clk_cnt_en && ~uart_flag) begin
        if(uart_clk_cnt == 9'd433) begin 
            if(uart_bit_cnt == 4'd10)
                uart_bit_cnt <= 4'd0;
            else    
            uart_bit_cnt <= uart_bit_cnt + 4'd1;
        end    
    end         
else
    uart_bit_cnt <= 4'd0;
end

assign uart_delay_cnt_en = fsm_cs==SEND_TX_DELAY0 || fsm_cs==SEND_TX_DELAY1 || fsm_cs==SEND_TX_DELAY2;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    uart_delay_cnt <= 7'd0;
else if(uart_delay_cnt_en)
    uart_delay_cnt <= uart_delay_cnt + 7'd1;
else
    uart_delay_cnt <= 7'd0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    uart_buf <= 8'd0;
else if(uart_clk_cnt==9'd216 && uart_bit_cnt>=4'd1 && uart_bit_cnt<=4'd8 && uart_recv_state)
    uart_buf <= {rx_sync,uart_buf[7:1]};    
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    uart_cmd_buf <= 8'd0;
else if(fsm_cs==RECV_CMD && uart_clk_cnt==9'd216 && uart_bit_cnt==4'd9 && rx_sync==~^uart_buf)
    uart_cmd_buf <= uart_buf;   
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    uart_addr_flag <= 1'b0;
else if(fsm_cs==RECV_ADDR_LOW && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433)
    uart_addr_flag <= 1'b1;
else if(fsm_cs==RECV_ADDR_HIGH && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433)
    uart_addr_flag <= 1'b0;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    uart_addr_buf <= 16'd0;
else if((fsm_cs==RECV_ADDR_LOW || fsm_cs==RECV_ADDR_HIGH) && uart_bit_cnt==4'd9 && uart_clk_cnt==9'd216 && ~^uart_buf==rx_sync)
    uart_addr_buf[uart_addr_flag*8+:8] <= uart_buf;        
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    uart_wdata_flag <= 2'd0;
else if(fsm_cs==RECV_WDATA_BYTE0 && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433)  
    uart_wdata_flag <= 2'd1;
else if(fsm_cs==RECV_WDATA_BYTE1 && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433) 
    uart_wdata_flag <= 2'd2;
else if(fsm_cs==RECV_WDATA_BYTE2 && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433) 
    uart_wdata_flag <= 2'd3;   
else if(fsm_cs==RECV_WDATA_BYTE3 && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433)  
    uart_wdata_flag <= 2'd0;
end

always@(posedge clk or negedge rst_n) 
begin
if(!rst_n)
    uart_wdata_buf <= 32'd0;
else if((fsm_cs==RECV_WDATA_BYTE0 || fsm_cs==RECV_WDATA_BYTE1 || fsm_cs==RECV_WDATA_BYTE2 || fsm_cs==RECV_WDATA_BYTE3) 
&& uart_bit_cnt==4'd9 && uart_clk_cnt==9'd216 && ~^uart_buf==rx_sync)
    uart_wdata_buf[uart_wdata_flag*8+:8] <= uart_buf;        
end

assign apb_pwrite  = fsm_cs==APB_W_SEL || fsm_cs==APB_W_EN;
assign apb_psel    = fsm_cs==APB_W_SEL || fsm_cs==APB_W_EN || fsm_cs==APB_R_SEL || fsm_cs==APB_R_EN;
assign apb_penable = fsm_cs==APB_W_EN  || fsm_cs==APB_R_EN;
assign apb_paddr   = uart_addr_buf;
assign apb_pwdata  = uart_wdata_buf;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    apb_prdata_buf <= 32'd0;
else if(apb_psel && apb_penable && apb_pready)
    apb_prdata_buf <= apb_prdata;     
end

always@(posedge clk or negedge rst_n) 
begin
if(!rst_n)
    uart_send_rdata_flag <= 2'b0;
else if(fsm_cs==SEND_TX_BYTE0 && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433)  
    uart_send_rdata_flag <= 2'd1;
else if(fsm_cs==SEND_TX_BYTE1 && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433) 
    uart_send_rdata_flag <= 2'd2;
else if(fsm_cs==SEND_TX_BYTE2 && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433) 
    uart_send_rdata_flag <= 2'd3;   
else if(fsm_cs==SEND_TX_BYTE3 && uart_bit_cnt==4'd10 && uart_clk_cnt==9'd433) 
    uart_send_rdata_flag <= 2'd0;
end

assign uart_tx_buf = apb_prdata_buf[uart_send_rdata_flag*8+:8];

assign uart_send_state = fsm_cs==SEND_TX_BYTE0 || fsm_cs==SEND_TX_BYTE1 || fsm_cs==SEND_TX_BYTE2 || fsm_cs==SEND_TX_BYTE3;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    tx <= 1'b1;
else if(uart_send_state) begin    
    if(uart_bit_cnt==4'd0)
        tx <= 1'b0;
    else if(uart_bit_cnt>=4'd1 && uart_bit_cnt<=4'd8)
        tx <= uart_tx_buf[uart_bit_cnt-4'd1];
    else if(uart_bit_cnt==4'd9) 
        tx <= ~^uart_tx_buf;
    else
        tx <= 1'b1;
    end
end

endmodule
