//======================================================
// GALAXY CORE COPY RIGHT
//
// SOC -- GC602S 
// DESIGN: Ivy
// REVIEW: 
//
// FUNCTION DESCRIPTION:
// 1.to test single-posrt sram 8192x32  March C
// 2.log 2  
// 3.2 col redundancy
// NOTE:
// SMIC 40nm
//  
// revision log  
// v1.0.2  2017.07.10
// v1.0.3  2017.07.12 for dc
// v1.0.4  2017.07.13 optimize
//======================================================
module SRAM_MBIST 
    #(
    parameter   ADDR    = 10,       // ceil(log2(DEPTH))
                DATA    = 32,       // IO_WIDTH, max=144
                DEPTH   = 1024,     // Words, max=2^24
                WMASK   = 1         // write mask width
    )         
    (
    input                 clk,
    input                 rst_n,
     

    input                 mbist_en,
    output reg            mbist_done,
    output reg            mbist_pass,

    input                 CEN,
    input                 GWEN,
    input  [WMASK-1 : 0]  WEN,
    input  [ADDR-1 : 0]   A,
    input  [DATA-1 : 0]   D,

    output                mbist_CEN,
    output                mbist_GWEN,
    output [WMASK-1: 0]   mbist_WEN,
    output [ADDR-1 : 0]   mbist_A,
    output [DATA-1 : 0]   mbist_D,          
    input  [DATA-1 : 0]   mbist_Q

    //output reg [8:0]     mbist_log0,  // bit[8] = 1, lower part has an error
    //output reg [8:0]     mbist_log1   // bit[8] = 1, higher part has an error
);  
localparam DEPTH_USE = DEPTH-1;

reg [ADDR-1 : 0]         test_A;
reg [DATA-1 : 0]         test_D;
reg                      test_WEN;
wire                     test_CEN = 1'b0;

assign  mbist_CEN  = mbist_en ? test_CEN : CEN;
assign  mbist_GWEN = mbist_en ? test_WEN : GWEN;
assign  mbist_WEN  = mbist_en ? {WMASK{test_WEN}} : WEN;
assign  mbist_A    = mbist_en ? test_A   : A;
assign  mbist_D    = mbist_en ? test_D   : D;
wire error_checking= 1'b0;

//===================================================================
// test items ff 00 aa 55 
//===================================================================
localparam TEST_IDLE         = 5'h0;
localparam TEST_W0_U         = 5'h1; //write 0        address up 
localparam TEST_R0W1_U_R     = 5'h2; //read 0 write 1 address up   
localparam TEST_R0W1_U_CHECK = 5'h3;
localparam TEST_R0W1_U_W_WAIT= 5'h4;
localparam TEST_R0W1_U_W     = 5'h5;
localparam TEST_R0W1_U_ADD   = 5'h6;
localparam TEST_R1W0_U_R     = 5'h7; //read 1 write 0 address up
localparam TEST_R1W0_U_CHECK = 5'h8;
localparam TEST_R1W0_U_W_WAIT= 5'h9;
localparam TEST_R1W0_U_W     = 5'ha; 
localparam TEST_R1W0_U_ADD   = 5'hb; 
localparam TEST_R0_U         = 5'hc; //read 0         address up
localparam TEST_R0_U_CHECK   = 5'hd;
localparam TEST_R0_U_ADD_WAIT= 5'he;
localparam TEST_R0_U_ADD     = 5'hf; 
localparam TEST_R0W1_D_R     = 5'h10; //read 0 write 1 address down
localparam TEST_R0W1_D_CHECK = 5'h11;
localparam TEST_R0W1_D_W_WAIT= 5'h12;
localparam TEST_R0W1_D_W     = 5'h13;
localparam TEST_R0W1_D_DEC   = 5'h14;
localparam TEST_R1W0_D_R     = 5'h15; //read 1 write 0 address down
localparam TEST_R1W0_D_CHECK = 5'h16;
localparam TEST_R1W0_D_W_WAIT =5'h17;
localparam TEST_R1W0_D_W     = 5'h18;
localparam TEST_R1W0_D_DEC   = 5'h19;
localparam TEST_R0_D         = 5'h1a; //read 0        address down
localparam TEST_R0_D_CHECK   = 5'h1b;
localparam TEST_R0_D_DEC_WAIT= 5'h1c;
localparam TEST_R0_D_DEC     = 5'h1d;
localparam TEST_LOG          = 5'h1e;
localparam TEST_CMP          = 5'h1f; 

reg [4:0] test_state,next_test_state;
wire   cnt_finish;

always@(posedge clk or negedge rst_n)
      if(~rst_n)
           test_state <= 5'h0;
       else if (error_checking)
           test_state <= test_state;
       else
           test_state <= next_test_state;

always@(*)
       case(test_state) 
  TEST_IDLE       : begin
                        if(mbist_en)         
                            next_test_state = TEST_W0_U;
                        else
                            next_test_state = TEST_IDLE;
                    end
            
  TEST_W0_U       : begin
                        if(cnt_finish)
                            next_test_state = TEST_R0W1_U_R;
                        else
                            next_test_state = TEST_W0_U; 
                    end 

  TEST_R0W1_U_R   :         next_test_state = TEST_R0W1_U_CHECK;
  TEST_R0W1_U_CHECK :       next_test_state = TEST_R0W1_U_W_WAIT;
  TEST_R0W1_U_W_WAIT:       next_test_state = TEST_R0W1_U_W;
  TEST_R0W1_U_W   :         next_test_state = TEST_R0W1_U_ADD;
  TEST_R0W1_U_ADD : begin
                        if(cnt_finish)
                            next_test_state = TEST_R1W0_U_R;
                        else
                            next_test_state = TEST_R0W1_U_R; 
                    end 

  TEST_R1W0_U_R   :         next_test_state = TEST_R1W0_U_CHECK;
  TEST_R1W0_U_CHECK :       next_test_state = TEST_R1W0_U_W_WAIT;
  TEST_R1W0_U_W_WAIT:       next_test_state = TEST_R1W0_U_W;
  TEST_R1W0_U_W   :         next_test_state = TEST_R1W0_U_ADD;
  TEST_R1W0_U_ADD : begin
                        if(cnt_finish)
                            next_test_state = TEST_R0_U;
                        else
                            next_test_state = TEST_R1W0_U_R; 
                    end 

  TEST_R0_U       :         next_test_state = TEST_R0_U_CHECK;
  TEST_R0_U_CHECK :         next_test_state = TEST_R0_U_ADD_WAIT; 
  TEST_R0_U_ADD_WAIT :         next_test_state = TEST_R0_U_ADD; 
  TEST_R0_U_ADD   : begin
                        if(cnt_finish)
                            next_test_state = TEST_R0W1_D_R;
                        else
                            next_test_state = TEST_R0_U; 
                    end

  TEST_R0W1_D_R   :         next_test_state = TEST_R0W1_D_CHECK;
  TEST_R0W1_D_CHECK :       next_test_state = TEST_R0W1_D_W_WAIT;
  TEST_R0W1_D_W_WAIT:       next_test_state = TEST_R0W1_D_W;
  TEST_R0W1_D_W   :         next_test_state = TEST_R0W1_D_DEC;
  TEST_R0W1_D_DEC : begin
                        if(cnt_finish)
                            next_test_state = TEST_R1W0_D_R;
                        else
                            next_test_state = TEST_R0W1_D_R; 
                    end 

  TEST_R1W0_D_R   :         next_test_state = TEST_R1W0_D_CHECK;
  TEST_R1W0_D_CHECK :       next_test_state = TEST_R1W0_D_W_WAIT;
  TEST_R1W0_D_W_WAIT:       next_test_state = TEST_R1W0_D_W;
  TEST_R1W0_D_W   :         next_test_state = TEST_R1W0_D_DEC;
  TEST_R1W0_D_DEC : begin
                        if(cnt_finish)
                            next_test_state = TEST_R0_D;
                        else
                            next_test_state = TEST_R1W0_D_R; 
                    end 

  TEST_R0_D      :          next_test_state = TEST_R0_D_CHECK;
  TEST_R0_D_CHECK :         next_test_state = TEST_R0_D_DEC_WAIT; 
  TEST_R0_D_DEC_WAIT :         next_test_state = TEST_R0_D_DEC; 
  TEST_R0_D_DEC  :  begin
                        if(cnt_finish)
                            next_test_state = TEST_LOG;
                        else
                            next_test_state = TEST_R0_D; 
                    end 
  TEST_LOG       :          next_test_state = TEST_CMP;
  TEST_CMP       :  begin
                        if(~mbist_en)
                            next_test_state = TEST_IDLE;
                        else
                            next_test_state = TEST_CMP;  
                    end 
  default        :          next_test_state = TEST_IDLE;
 endcase

//=======================================================================
reg [14:0] test_cnt;
always@(posedge clk)
    test_A <= test_cnt[ADDR-1 : 0];    
wire  cnt_up_valid   = test_state == TEST_W0_U       || test_state == TEST_R0W1_U_ADD || test_state ==TEST_R1W0_U_ADD || test_state ==TEST_R0_U_ADD ;
wire  cnt_down_valid = test_state == TEST_R0W1_D_DEC || test_state == TEST_R1W0_D_DEC || test_state ==TEST_R0_D_DEC;
assign cnt_finish    = (cnt_up_valid && test_cnt == DEPTH_USE) || (cnt_down_valid && test_cnt == 0);

wire  reset0_valid   = (test_state == TEST_W0_U      || test_state == TEST_R0W1_U_ADD || test_state ==TEST_R1W0_U_ADD) && test_cnt == DEPTH_USE;
wire  resetf_valid   = (test_state == TEST_R0_U_ADD  && test_cnt == DEPTH_USE)     || (cnt_down_valid && test_cnt == 0);

always@(posedge clk or negedge rst_n)
       if(~rst_n)
            test_cnt <= 'h0;
       else if(test_state == TEST_IDLE)
            test_cnt <= 'h0;          
       else if (~error_checking)
       begin
            if(reset0_valid)
                test_cnt <= 'h0;
            else if(resetf_valid)
                test_cnt <= DEPTH_USE; //{ADDR{1'b1}};
            else if(cnt_up_valid)
                test_cnt <= test_cnt + 15'h1;
            else if(cnt_down_valid)
                test_cnt <= test_cnt - 15'h1;  
       end
            
//=============================================================================       Write
always@(posedge clk)
    test_WEN    <= ~(test_state == TEST_W0_U || test_state == TEST_R0W1_U_W || test_state == TEST_R1W0_U_W || test_state == TEST_R0W1_D_W || test_state == TEST_R1W0_D_W); 
wire    write1_valid =  (test_state >= TEST_R0W1_U_R && test_state <= TEST_R0W1_U_ADD) || (test_state >= TEST_R0W1_D_R && test_state <= TEST_R0W1_D_DEC);
always@(posedge clk)
    test_D      <=  write1_valid ? {DATA{1'b1}} : {DATA{1'b0}};

//=============================================================================       Read check
//reg check_valid;
//always@(posedge clk)
//    check_valid <= (test_state == TEST_R0W1_U_CHECK || test_state == TEST_R1W0_U_CHECK || test_state == TEST_R0W1_D_CHECK || test_state == TEST_R1W0_D_CHECK || test_state == TEST_R0_U_CHECK || test_state == TEST_R0_D_CHECK);
wire     check_valid = (test_state == TEST_R0W1_U_W || test_state == TEST_R1W0_U_W || test_state == TEST_R0W1_D_W || test_state == TEST_R1W0_D_W || test_state == TEST_R0_U_ADD || test_state == TEST_R0_D_DEC);
wire            check1_valid = (test_state >= TEST_R1W0_U_R && test_state <= TEST_R1W0_U_ADD) || (test_state >= TEST_R1W0_D_R && test_state <= TEST_R1W0_D_DEC);
reg [DATA-1:0] check_D;
always@(posedge clk)
    check_D <= check1_valid ? {DATA{1'b1}} : {DATA{1'b0}};

//=============================================== addresss log
reg [DATA-1 : 0]   mbist_Q_d;

always@(posedge clk or negedge rst_n)
    if (~rst_n)
       mbist_Q_d <= {(DATA){1'b0}};
    else 
       mbist_Q_d <= mbist_Q ;  


wire  error_valid =  (mbist_Q_d != check_D) && check_valid;

reg error_fail;

always@(posedge clk or negedge rst_n)
    if (~rst_n)
        error_fail <= 1'b0;
    else if(test_state == TEST_IDLE)
        error_fail <= 1'b0;
    else if (error_valid)
        error_fail <= 1'b1;

//reg [127:0] error_info0, error_info1;
//always@(posedge clk)
//begin
//     error_info0 <= {{(128-DATA/2){1'b0}}, mbist_Q[(DATA/2-1) : 0     ] ^ check_D[(DATA/2-1) : 0     ]};
//     error_info1 <= {{(128-DATA/2){1'b0}}, mbist_Q[(DATA-1)   : DATA/2] ^ check_D[(DATA-1)   : DATA/2]};
//end

//wire [127:0]    error_info0 = {{(128-DATA/2){1'b0}}, mbist_Q[(DATA/2-1) : 0     ] ^ check_D[(DATA/2-1) : 0     ]};
//wire [127:0]    error_info1 = {{(128-DATA/2){1'b0}}, mbist_Q[(DATA-1)   : DATA/2] ^ check_D[(DATA-1)   : DATA/2]};

/*
//=============================================== column redundancy
reg [1:0] error_col_cnt0, error_col_cnt1;  
reg [3:0] error_bit_cnt;

assign error_checking = error_valid && error_bit_cnt <= 'h7; 

always@(posedge clk or negedge rst_n)
    if (~rst_n)
        error_bit_cnt <= 'h0;
    else if (error_valid)
        error_bit_cnt <= error_bit_cnt + 'b1;
    else error_bit_cnt <= 'b0;

reg [6:0] error_bit0, error_bit1;
reg [1:0] error_flag0, error_flag1;
reg [63:0] error_info_tmp0, error_info_tmp1;
always@(posedge clk or negedge rst_n)
    if (~rst_n)
        error_bit0  <= 7'b0;
    else if (error_valid)
        case (error_bit_cnt)
        4'h0 : if (|error_info0[127:64]) 
                    error_bit0  <= {1'b1, 6'b0};
               else 
                    error_bit0  <= {1'b0, 6'b0};

        4'h1 : if (|error_info_tmp0[63:32])
                   error_bit0  <= {error_bit0[6], 1'b1, 5'b0}; 
               else 
                   error_bit0  <= {error_bit0[6], 1'b0, 5'b0};

        4'h2 : if (|error_info_tmp0[31:16])
                    error_bit0  <= {error_bit0[6:5], 1'b1, 4'b0};
               else 
                    error_bit0  <= {error_bit0[6:5], 1'b0, 4'b0};

        4'h3 : if (|error_info_tmp0[15:8])
                    error_bit0  <= {error_bit0[6:4], 1'b1, 3'b0};
               else 
                    error_bit0  <= {error_bit0[6:4], 1'b0, 3'b0};

        4'h4 : if (|error_info_tmp0[7:4])
                    error_bit0  <= {error_bit0[6:3], 1'b1, 2'b0};
               else 
                    error_bit0  <= {error_bit0[6:3], 1'b0, 2'b0};

        4'h5 : if (|error_info_tmp0[3:2])
                    error_bit0  <=  {error_bit0[6:2], 1'b1, 1'b0};
               else 
                    error_bit0  <=  {error_bit0[6:2], 1'b0, 1'b0};

        4'h6 : if (error_info_tmp0[1])
                    error_bit0  <= {error_bit0[6:1], 1'b1};
               else
                    error_bit0  <= {error_bit0[6:1], 1'b0};
        endcase

wire error_flag0_not_full = ~error_flag0[1];
always@(posedge clk or negedge rst_n)
    if (~rst_n)
        error_flag0 <= 2'b0;
    else if (error_valid && error_flag0_not_full)
        case (error_bit_cnt)
        4'h0 : error_flag0 <= |error_info0    [127:64]+ |error_info0    [63:0];
        4'h1 : error_flag0 <= |error_info_tmp0[63:32] + |error_info_tmp0[31:0];
        4'h2 : error_flag0 <= |error_info_tmp0[31:16] + |error_info_tmp0[15:0];
        4'h3 : error_flag0 <= |error_info_tmp0[15:8]  + |error_info_tmp0[7:0];
        4'h4 : error_flag0 <= |error_info_tmp0[7:4]   + |error_info_tmp0[3:0];
        4'h5 : error_flag0 <= |error_info_tmp0[3:2]   + |error_info_tmp0[1:0];
        4'h6 : error_flag0 <=  error_info_tmp0[1]     +  error_info_tmp0[0];
        endcase

always@(posedge clk or negedge rst_n)
    if (~rst_n)
        error_info_tmp0 <= 64'b0;
    else if (error_valid)
        case (error_bit_cnt)
        4'h0 : if (|error_info0[127:64])
                    error_info_tmp0 <= error_info0[127:64];
               else 
                    error_info_tmp0 <= error_info0[63:0];

        4'h1 : if (|error_info_tmp0[63:32])
                    error_info_tmp0 <= error_info_tmp0[63:32];
               else 
                    error_info_tmp0 <= error_info_tmp0[31:0];

        4'h2 : if (|error_info_tmp0[31:16])
                    error_info_tmp0 <= error_info_tmp0[31:16];
               else 
                    error_info_tmp0 <= error_info_tmp0[15:0];

        4'h3 : if (|error_info_tmp0[15:8])
                    error_info_tmp0 <= error_info_tmp0[15:8];
               else 
                    error_info_tmp0 <= error_info_tmp0[7:0];

        4'h4 : if (|error_info_tmp0[7:4])
                    error_info_tmp0 <= error_info_tmp0[7:4];
               else 
                    error_info_tmp0 <= error_info_tmp0[3:0];

        4'h5 : if (|error_info_tmp0[3:2])
                    error_info_tmp0 <= error_info_tmp0[3:2];
               else 
                    error_info_tmp0 <= error_info_tmp0[1:0];
         endcase

always@(posedge clk or negedge rst_n)
    if (~rst_n)
        error_bit1  <= 7'b0;
    else if (error_valid)
        case (error_bit_cnt)
        4'h0 : if (|error_info1[127:64])
                    error_bit1 <= {1'b1, 6'b0};
               else 
                    error_bit1 <= {1'b0, 6'b0};

        4'h1 : if (|error_info_tmp1[63:32])
                    error_bit1  <= {error_bit1[6], 1'b1, 5'b0};
               else 
                    error_bit1  <= {error_bit1[6], 1'b0, 5'b0};

        4'h2 : if (|error_info_tmp1[31:16])
                    error_bit1  <= {error_bit1[6:5], 1'b1, 4'b0};
               else
                    error_bit1  <= {error_bit1[6:5], 1'b0, 4'b0};

        4'h3 : if (|error_info_tmp1[15:8])
                    error_bit1  <= {error_bit1[6:4], 1'b1, 3'b0};
               else 
                    error_bit1  <= {error_bit1[6:4], 1'b0, 3'b0};
        
        4'h4 : if (|error_info_tmp1[7:4])
                    error_bit1  <= {error_bit1[6:3], 1'b1, 2'b0};
               else
                    error_bit1  <= {error_bit1[6:3], 1'b0, 2'b0};

        4'h5 : if (|error_info_tmp1[3:2])
                    error_bit1  <= {error_bit1[6:2], 1'b1, 1'b0};
               else
                    error_bit1  <= {error_bit1[6:2], 1'b0, 1'b0};

        4'h6 : if (error_info_tmp1[1])
                    error_bit1  <= {error_bit1[6:1], 1'b1};
               else
                    error_bit1  <= {error_bit1[6:1], 1'b0};
        endcase

wire error_flag1_not_full = ~error_flag1[1];

always@(posedge clk or negedge rst_n)
    if (~rst_n)
        error_flag1 <= 2'b0;
    else if (error_valid & error_flag1_not_full)
        case (error_bit_cnt)
        4'h0 : error_flag1 <= |error_info1    [127:64]+ |error_info1    [63:0];
        4'h1 : error_flag1 <= |error_info_tmp1[63:32] + |error_info_tmp1[31:0];
        4'h2 : error_flag1 <= |error_info_tmp1[31:16] + |error_info_tmp1[15:0];
        4'h3 : error_flag1 <= |error_info_tmp1[15:8]  + |error_info_tmp1[7:0];
        4'h4 : error_flag1 <= |error_info_tmp1[7:4]   + |error_info_tmp1[3:0];
        4'h5 : error_flag1 <= |error_info_tmp1[3:2]   + |error_info_tmp1[1:0];
        4'h6 : error_flag1 <=  error_info_tmp1[1]     +  error_info_tmp1[0];
        endcase

always@(posedge clk or negedge rst_n)
    if (~rst_n)
        error_info_tmp1 <= 64'b0;
    else if (error_valid)
        case (error_bit_cnt)
        4'h0 : if (|error_info1[127:64])
                    error_info_tmp1 <= error_info1[127:64];
               else
                    error_info_tmp1 <= error_info1[63:0];

        4'h1 : if (|error_info_tmp1[63:32])
                    error_info_tmp1 <= error_info_tmp1[63:32];
               else
                    error_info_tmp1 <= error_info_tmp1[31:0];

        4'h2 : if (|error_info_tmp1[31:16])
                    error_info_tmp1 <= error_info_tmp1[31:16];
               else
                    error_info_tmp1 <= error_info_tmp1[15:0];

        4'h3 : if (|error_info_tmp1[15:8])
                    error_info_tmp1 <= error_info_tmp1[15:8];
               else 
                    error_info_tmp1 <= error_info_tmp1[7:0];

        4'h4 : if (|error_info_tmp1[7:4])
                    error_info_tmp1 <= error_info_tmp1[7:4];
               else 
                    error_info_tmp1 <= error_info_tmp1[3:0];

        4'h5 : if (|error_info_tmp1[3:2])
                    error_info_tmp1 <= error_info_tmp1[3:2];
               else 
                    error_info_tmp1 <= error_info_tmp1[1:0];
         endcase

reg [7:0] error_bit_log0, error_bit_log1;
wire error_col_cnt0_full = (error_col_cnt0 == 2'b10);
wire error_col_cnt0_tmp1 = (error_col_cnt0 == 2'b1);
always @(posedge clk or negedge rst_n)
    if (~rst_n)
        error_col_cnt0 <= 2'b0;
    else if (error_bit_cnt == 'h7)
         begin
            if (error_flag0 == 2'b10 || error_col_cnt0_full)
                error_col_cnt0 <= 2'b10;
            else if (error_flag0 == 2'b1)
                 begin
                    if (error_col_cnt0_tmp1 && error_bit0 != error_bit_log0)
                        error_col_cnt0 <= 2'b10;
                    else
                        error_col_cnt0 <= 2'b1;
                 end
         end
                

always @(posedge clk or negedge rst_n)
    if (~rst_n)
        error_bit_log0 <= 8'b0;
    else if (error_bit_cnt == 'h7)
         begin
            if (error_flag0 == 2'b10 || error_col_cnt0_full)
                error_bit_log0 <= 8'hff;
            else if (error_flag0 == 2'b1) 
                 begin
                    if (error_col_cnt0 == 2'b1 && error_bit0 != error_bit_log0)
                        error_bit_log0 <= 8'hff;
                    else 
                        error_bit_log0 <= error_bit0;
                 end      
         end   
wire error_col_cnt1_full = (error_col_cnt1 == 2'b10);
wire error_col_cnt1_tmp1 = (error_col_cnt1 == 2'b1);
always @(posedge clk or negedge rst_n)
    if (~rst_n)
        error_col_cnt1 <= 2'b0;
    else if (error_bit_cnt == 'h7)
         begin
            if (error_flag1 == 2'b10 || error_col_cnt1_full)
                error_col_cnt1 <= 2'b10;
            else if (error_flag1 == 2'b1) 
                 begin
                    if (error_col_cnt1_tmp1 && (error_bit1 + DATA/2) != error_bit_log1)
                        error_col_cnt1 <= 2'b10;
                    else 
                        error_col_cnt1 <= 2'b1;
                 end            
         end    

always @(posedge clk or negedge rst_n)
    if (~rst_n)
        error_bit_log1 <= 8'b0;
    else if (error_bit_cnt == 'h7)
         begin
            if (error_flag1 == 2'b10 || error_col_cnt1_full)
                error_bit_log1 <= 8'hff;
            else if (error_flag1 == 2'b1) 
                 begin
                    if (error_col_cnt1 == 2'b1 && (error_bit1 + DATA/2) != error_bit_log1)
                        error_bit_log1 <= 8'hff;
                    else 
                        error_bit_log1 <= error_bit1 + DATA/2;
                 end            
         end    

always@(posedge clk or negedge rst_n)
       if(~rst_n)
           mbist_log0 <= 9'b0;
       else if (test_state == TEST_IDLE)
                    mbist_log0 <= 9'b0;
       else if(test_state == TEST_LOG && error_col_cnt0 >= 2'b1)
                    mbist_log0 <= {1'b1, error_bit_log0};

always@(posedge clk or negedge rst_n)
       if(~rst_n)
           mbist_log1 <= 9'b0;
       else if (test_state == TEST_IDLE)
                    mbist_log1 <= 9'b0;
       else if(test_state == TEST_LOG && error_col_cnt1 >= 2'b1)
                    mbist_log1 <= {1'b1, error_bit_log1};
*/

always @(posedge clk or negedge rst_n)
    if(~rst_n) 
        mbist_done <= 1'b0;
    else
        mbist_done <= (test_state == TEST_CMP);

always @(posedge clk or negedge rst_n)
    if(~rst_n)
       mbist_pass <= 1'b0;
    else   
       mbist_pass <= ~error_fail;//(error_col_cnt0==2'b0 && error_col_cnt1 == 2'b0);

//always @(posedge clk)
//    mbist_repairable <= ~(error_col_cnt0_full || error_col_cnt1_full);

endmodule                     
