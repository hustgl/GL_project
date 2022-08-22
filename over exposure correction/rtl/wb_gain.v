// 1clk get the result
module wb_gain #(
    parameter DW_IN   = 10,
    parameter DW_GAIN = 10,
    parameter DW_DEC  = 8 
)(
    input                    clk      ,
    input                    rst_n    ,

    input      [1:0]         CFA      ,

    input                    wb_en    ,
    input                    vsync_in ,
    input                    hsync_in ,
    input      [DW_IN*4-1:0] data_in  ,

    input      [DW_GAIN-1:0] R_gain   ,
    input      [DW_GAIN-1:0] G_gain   ,
    input      [DW_GAIN-1:0] B_gain   ,

    output reg               vsync_out,
    output reg               hsync_out,
    output reg [DW_IN*4-1:0] data_out
);

reg [DW_GAIN-1:0] awb_gain1,awb_gain2,awb_gain3,awb_gain4; // comb

always@(*) begin
if(wb_en) 
    case(CFA)
        2'b00:begin {awb_gain1,awb_gain2,awb_gain3,awb_gain4}={G_gain,R_gain,B_gain,G_gain}; end
        2'b01:begin {awb_gain1,awb_gain2,awb_gain3,awb_gain4}={R_gain,G_gain,G_gain,B_gain}; end
        2'b10:begin {awb_gain1,awb_gain2,awb_gain3,awb_gain4}={B_gain,G_gain,G_gain,R_gain}; end
        2'b11:begin {awb_gain1,awb_gain2,awb_gain3,awb_gain4}={G_gain,B_gain,R_gain,G_gain}; end
    endcase   
else     
    {awb_gain1,awb_gain2,awb_gain3,awb_gain4}={DW_GAIN{1'b0}};  
end

wire [DW_IN+DW_GAIN-1:0] data1_11_mult = data_in[DW_IN*4-1:DW_IN*3] * awb_gain1; 
wire [DW_IN+DW_GAIN-1:0] data1_12_mult = data_in[DW_IN*3-1:DW_IN*2] * awb_gain2;
wire [DW_IN+DW_GAIN-1:0] data1_21_mult = data_in[DW_IN*2-1:DW_IN]   * awb_gain3;
wire [DW_IN+DW_GAIN-1:0] data1_22_mult = data_in[DW_IN-1:0]         * awb_gain4;

wire [DW_IN+DW_GAIN-DW_DEC-1:0] data1_11_clamp = data1_11_mult >>DW_DEC;
wire [DW_IN+DW_GAIN-DW_DEC-1:0] data1_12_clamp = data1_12_mult >>DW_DEC;
wire [DW_IN+DW_GAIN-DW_DEC-1:0] data1_21_clamp = data1_21_mult >>DW_DEC;
wire [DW_IN+DW_GAIN-DW_DEC-1:0] data1_22_clamp = data1_22_mult >>DW_DEC;

wire [DW_IN-1:0] data1_11_tmp = (|data1_11_clamp[DW_IN+DW_GAIN-DW_DEC-1:DW_IN+DW_GAIN-DW_DEC-2])? 
                                {DW_IN{1'b1}} : data1_11_clamp[DW_IN-1:0];

wire [DW_IN-1:0] data1_12_tmp = (|data1_12_clamp[DW_IN+DW_GAIN-DW_DEC-1:DW_IN+DW_GAIN-DW_DEC-2])? 
                                {DW_IN{1'b1}} : data1_12_clamp[DW_IN-1:0];

wire [DW_IN-1:0] data1_21_tmp = (|data1_21_clamp[DW_IN+DW_GAIN-DW_DEC-1:DW_IN+DW_GAIN-DW_DEC-2])? 
                                {DW_IN{1'b1}} : data1_21_clamp[DW_IN-1:0];

wire [DW_IN-1:0] data1_22_tmp = (|data1_22_clamp[DW_IN+DW_GAIN-DW_DEC-1:DW_IN+DW_GAIN-DW_DEC-2])? 
                                {DW_IN{1'b1}} : data1_22_clamp[DW_IN-1:0];

always@(posedge clk) 
begin
    if(!rst_n) begin
        data_out  <= {DW_IN*4{1'b0}};
        hsync_out <= 1'b0;
        vsync_out <= 1'b0;
    end
    else begin
        data_out  <= {data1_11_tmp,data1_12_tmp,data1_21_tmp,data1_22_tmp}; 
        hsync_out <= hsync_in;
        vsync_out <= vsync_in;
    end
end    

endmodule
