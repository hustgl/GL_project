module i2c_bit_shift #(
    parameter CMD_WIDTH  = 6         ,
    parameter DATA_WIDTH = 8         ,
    parameter SYS_CLK    = 50_000_000,  //clk freq: 50M
    parameter SCLK_FREQ  = 400_000      //i2c freq: 400k
)(
`ifdef SDA_IN_TEST  
    output     [2           :0] fsm_cs_o  ,
    output                      flag_o    ,
    output                      isout_o   , 
`endif

    input                       clk       ,
    input                       rst_n     ,

    input      [CMD_WIDTH-1 :0] cmd       ,  //i2c cmd 
    input                       work_en   ,  //i2c work enable

    input      [DATA_WIDTH-1:0] tx_data   ,  
    output reg [DATA_WIDTH-1:0] rx_data   ,
    output reg                  trans_done,
    output reg                  ack_o     ,  //ack from slave to upstream 

    inout                       i2c_sda   ,
    output reg                  i2c_sclk  
);

localparam SCLK_CNT = SYS_CLK/SCLK_FREQ/4 - 1; // 

//one-hot encoding, resolve input cmd
localparam WR    = 6'b000001, //write 
           START = 6'b000010, //the transmission includes start signal
           RD    = 6'b000100, //read
           STOP  = 6'b001000, //include stop
           ACK   = 6'b010000, //master ACK
           NACK  = 6'b100000; //master NACK

//FSM
localparam IDLE      = 3'd0,
           GEN_START = 3'd1,
           WR_DATA   = 3'd2,
           RD_DATA   = 3'd3,  //read one byte
           CHECK_ACK = 3'd4,
           GEN_ACK   = 3'd5,
           GEN_STOP  = 3'd6;

// sda direction flag and sda reg
reg sda_isout; 
reg i2c_sda_o;

reg [6:0] div_cnt          ; //count inside each stage
reg       div_cnt_en       ; 
reg [4:0] stage_cnt        ; //4 stages in all
wire      stage_change_flag; //div_cnt == SCLK_CNT

reg [2:0] fsm_cs, fsm_ns;

wire      sample_sda;

`ifdef SDA_IN_TEST
//FSM test
assign fsm_cs_o = fsm_cs;
assign flag_o   = stage_change_flag;
assign isout_o  = sda_isout;
`endif

// FSM logic 
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    fsm_cs <= 3'd0;
else
    fsm_cs <= fsm_ns;
end

always@(*) begin
case(fsm_cs)
    IDLE: begin
        if(work_en) begin
            if(cmd & START)
                fsm_ns = GEN_START;
            else if(cmd & WR)
                fsm_ns = WR_DATA;
            else if(cmd & RD)    
                fsm_ns = RD_DATA;
            else 
                fsm_ns = IDLE;
        end
        else
            fsm_ns = IDLE;
    end
    GEN_START: begin
        if(stage_cnt==5'd3 && stage_change_flag) begin
            if(cmd & WR)
                fsm_ns = WR_DATA;
            else if(cmd & RD)
                fsm_ns = RD_DATA;
            else
                fsm_ns = IDLE; //error, return to IDLE, transmission done
        end  
        else
            fsm_ns = GEN_START;
    end
    WR_DATA: begin
        if(stage_cnt==5'd31 && stage_change_flag) 
            fsm_ns = CHECK_ACK;
        else
            fsm_ns = WR_DATA;
    end  
    RD_DATA: begin
        if(stage_cnt==5'd31 && stage_change_flag)
            fsm_ns = GEN_ACK;
        else
            fsm_ns = RD_DATA;
    end
    CHECK_ACK: begin
        if(stage_cnt==5'd3 && stage_change_flag) begin
            if(cmd & STOP)
                fsm_ns = GEN_STOP;
            else
                fsm_ns = IDLE;  //trans_done
        end
        else
            fsm_ns = CHECK_ACK;       
    end
    GEN_ACK: begin
        if(stage_cnt==5'd3 && stage_change_flag) begin
            if(cmd & STOP)
                fsm_ns = GEN_STOP;
            else
                fsm_ns = IDLE;  //trans_done            
        end
        else
            fsm_ns = GEN_ACK;            
    end
    GEN_STOP: begin
        if(stage_cnt==5'd3 && stage_change_flag)
            fsm_ns = IDLE;
        else
            fsm_ns = GEN_STOP;
    end        
endcase
end

//div cnt in order to change within 4 stages
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    div_cnt <= 7'd0;
else if(div_cnt_en) begin
    if(div_cnt == SCLK_CNT)
        div_cnt <= 7'd0;
    else
        div_cnt <= div_cnt + 1'b1;
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    div_cnt_en <= 1'b0;
else if(trans_done)
    div_cnt_en <= 1'b0;
else if(work_en)
    div_cnt_en <= 1'b1;
end

assign stage_change_flag = div_cnt==SCLK_CNT;

// stage cnt
always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    stage_cnt <= 5'd0;
else if((fsm_cs==WR_DATA || fsm_cs==RD_DATA) && stage_change_flag) begin
    if(stage_cnt == 5'd31)
        stage_cnt <= 5'd0;
    else
        stage_cnt <= stage_cnt + 1'b1;
    end
    else if((fsm_cs==GEN_START || fsm_cs==CHECK_ACK || fsm_cs==GEN_ACK || fsm_cs==GEN_STOP) && stage_change_flag) begin
    if(stage_cnt == 5'd3)
        stage_cnt <= 5'd0;
    else
        stage_cnt <= stage_cnt + 1'b1;
    end
end

// trans_done is to tell the upstream module when to sample rx_data and ack_o
always@(*) begin
if(stage_cnt==5'd3 && stage_change_flag) begin
    if(fsm_cs==CHECK_ACK && !(cmd & STOP))
        trans_done = 1'b1;
    else if(fsm_cs==GEN_ACK && !(cmd & STOP)) 
        trans_done = 1'b1;
    else if(fsm_cs==GEN_STOP)
        trans_done = 1'b1;
    else
        trans_done = 1'b0;
end
else
    trans_done = 1'b0;
end

//i2c bus logic
assign i2c_sda = (sda_isout)? i2c_sda_o:1'bz;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    sda_isout <= 1'b1;
else if(trans_done)
    sda_isout <= 1'b1;
else if(stage_change_flag) begin
    if(fsm_cs==CHECK_ACK || fsm_cs==RD_DATA)
        sda_isout <= 1'b0;
    else
        sda_isout <= 1'b1;
    end
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    i2c_sda_o <= 1'b1;
else if(trans_done)
    i2c_sda_o <= 1'b1;
else begin
    case(fsm_cs)
        GEN_START: begin
            if(stage_change_flag)
                case(stage_cnt)
                    5'd0,5'd1: i2c_sda_o <= 1'b1;
                    5'd2,5'd3: i2c_sda_o <= 1'b0;
                endcase                
        end
        WR_DATA: begin
            if(stage_change_flag)
                case(stage_cnt)
                    5'd0, 5'd4, 5'd8, 5'd12, 5'd16, 5'd20, 5'd24, 5'd28:
                        i2c_sda_o <= tx_data[7-stage_cnt[4:2]];                    
                endcase
        end
        GEN_ACK: begin
            if(stage_change_flag && stage_cnt==5'd0) begin
                if(cmd & ACK)
                    i2c_sda_o <= 1'b0;
                else if(cmd & NACK)
                    i2c_sda_o <= 1'b1;
            end
        end
        GEN_STOP: begin
            if(stage_change_flag) 
                case(stage_cnt)
                    5'd0, 5'd1:i2c_sda_o <= 1'b0;
                    5'd2, 5'd3:i2c_sda_o <= 1'b1;
                endcase    
        end
    endcase
    end    
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    i2c_sclk <= 1'b1;
else if(trans_done)
    i2c_sclk <= 1'b1;
else begin
    case(fsm_cs)
        GEN_START: begin
            if(stage_change_flag)
                case(stage_cnt)
                    5'd0, 5'd1, 5'd2: i2c_sclk <= 1'b1;
                    5'd3            : i2c_sclk <= 1'b0;
                endcase
        end
        WR_DATA, RD_DATA: begin
            if(stage_change_flag)
                case(stage_cnt)
                    5'd0, 5'd4, 5'd8 , 5'd12, 5'd16, 5'd20, 5'd24, 5'd28:
                        i2c_sclk <= 1'b0;
                    5'd1, 5'd5, 5'd9 , 5'd13, 5'd17, 5'd21, 5'd25, 5'd29:
                        i2c_sclk <= 1'b1;
                    5'd2, 5'd6, 5'd10, 5'd14, 5'd18, 5'd22, 5'd26, 5'd30:
                        i2c_sclk <= 1'b1;
                    5'd3, 5'd7, 5'd11, 5'd15, 5'd19, 5'd23, 5'd27, 5'd31:
                        i2c_sclk <= 1'b0;
                endcase
        end
        CHECK_ACK, GEN_ACK: begin
            if(stage_change_flag)
                case(stage_cnt)
                    5'd0, 5'd3: i2c_sclk <= 1'b0;
                    5'd1, 5'd2: i2c_sclk <= 1'b1;
                endcase
        end
        GEN_STOP: begin
            if(stage_change_flag)
                case(stage_cnt)
                    5'd0            : i2c_sclk <= 1'b0;
                    5'd1, 5'd2, 5'd3: i2c_sclk <= 1'b1;
                endcase
        end
    endcase
    end
end

//output to upstream
assign sample_sda = fsm_cs==RD_DATA && stage_change_flag && stage_cnt[1:0]==2'b10;

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    rx_data <= 8'd0;
else if(sample_sda)
    rx_data <= {rx_data[6:0], i2c_sda};
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    ack_o <= 1'b0;
else if(fsm_cs==CHECK_ACK && stage_change_flag && stage_cnt==5'd2)
    ack_o <= i2c_sda;
end

endmodule
