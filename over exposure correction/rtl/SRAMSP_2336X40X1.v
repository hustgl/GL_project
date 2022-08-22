//==========================================================
// GALAXY CORE COPYRIGHT
//
// DESIGN: Luke
// REVIEW: 
//
// FUNCTION:
//     single port SRAM top (smic40nm and Xilinx SRAM)
//
//==========================================================
module SRAMSP_2336X40X1(
input         CLK,
input         rst_n,
input         scan_mode,
input         MBIST_en,
output        MBIST_DONE,
output        MBIST_PASS,
input         CEN,
input         WEN,
input  [11:0] A,
input  [39:0] D,
output [39:0] Q
);

wire        mbist_CEN;
wire        mbist_GWEN;
wire        mbist_WEN;
wire [11:0] mbist_A;
wire [39:0] mbist_D;
wire [39:0] mbist_Q;
SRAM_MBIST #(.ADDR(12),.DEPTH(2336),.DATA(40),.WMASK(1)) U_MBIST(
                            .clk(CLK),
                            .rst_n(rst_n),
                            .CEN(CEN),
                            .GWEN(WEN),
                            .WEN(WEN),
                            .A(A),
                            .D(D),
                            .mbist_en(MBIST_en),
                            .mbist_done(MBIST_DONE),
                            .mbist_pass(MBIST_PASS),
                            .mbist_CEN(mbist_CEN),
                            .mbist_GWEN(mbist_GWEN),
                            .mbist_WEN(mbist_WEN),
                            .mbist_A(mbist_A),
                            .mbist_D(mbist_D),
                            .mbist_Q(mbist_Q)
);
wire [39:0] Q1,Q2;

wire [12:0] A_tmp = mbist_A-12'd1168;

wire CEN1 = mbist_CEN | (~A_tmp[12]);
wire CEN2 = mbist_CEN | (A_tmp[12]);
wire [10:0] A1 = CEN1 ? 11'h0 : mbist_A[10:0];
wire [10:0] A2 = CEN2 ? 11'h0 : A_tmp[10:0];

`ifdef FPGA
blk_mem_gen_1168x40 U_blk_mem1(
  .clka(CLK),
  .ena(~CEN1),
  .wea(~mbist_WEN),
  .addra(A1),
  .dina(mbist_D),
  .douta(Q1)
);

blk_mem_gen_1168x40 U_blk_mem2(
  .clka(CLK),
  .ena(~CEN2),
  .wea(~mbist_WEN),
  .addra(A2),
  .dina(mbist_D),
  .douta(Q2)
);
`else
rhd_1168x40x1_m8 U_SRAM1(
    .CLK(CLK),
    .CEN(CEN1),
    .WEN(mbist_WEN),
    .EMA(3'b010),
    .EMAW(2'b00),
    .RET1N(1'b1),
    .A(A1),
    .D(mbist_D),
    .Q(Q1)
);
rhd_1168x40x1_m8 U_SRAM2(
    .CLK(CLK),
    .CEN(CEN2),
    .WEN(mbist_WEN),
    .EMA(3'b010),
    .EMAW(2'b00),
    .RET1N(1'b1),
    .A(A2),
    .D(mbist_D),
    .Q(Q2)
);
`endif

reg cen1_d1;
always @(posedge CLK)
    cen1_d1 <= CEN1;

assign mbist_Q = cen1_d1 ? Q2 : Q1;

assign Q = scan_mode ? mbist_D : mbist_Q;


endmodule



