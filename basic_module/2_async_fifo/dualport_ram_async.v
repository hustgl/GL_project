module dualport_ram_async #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4  //ram depth is equal to 2^ADDR_WIDTH
)(
    input                   wr_clk  ,
    input                   wr_rst_n,
    input                   wr_en   ,
    input  [ADDR_WIDTH-1:0] wr_addr ,
    input  [DATA_WIDTH-1:0] wr_data ,
    input                   rd_clk  ,
    input                   rd_rst_n,
    input                   rd_en   ,
    input  [ADDR_WIDTH-1:0] rd_addr ,
    output [DATA_WIDTH-1:0] rd_data
);
    
localparam  RAM_DEPTH = 1<<ADDR_WIDTH;

reg [DATA_WIDTH-1:0] mem [RAM_DEPTH-1:0];

generate
genvar i;
for(i=0;i<RAM_DEPTH;i=i+1) begin:mem_assign
    always @ (posedge wr_clk or negedge wr_rst_n)
    begin
        if(!wr_rst_n)
            mem[i] <= {DATA_WIDTH{1'b0}};
        else if(wr_en & (wr_addr==i))
            mem[i] <= wr_data;
    end 
end 
endgenerate
    
assign rd_data = mem[rd_addr];
endmodule
