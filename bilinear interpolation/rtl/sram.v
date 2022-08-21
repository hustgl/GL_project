module sram #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 40
)(
    input                       clk  ,
    input                       rst_n,
    input                       CEN  ,
    input                       WEN  ,
    input      [ADDR_WIDTH-1:0] A    ,
    input      [DATA_WIDTH-1:0] D    ,
    output reg [DATA_WIDTH-1:0] Q
);

localparam RAM_DEPTH = 1<<ADDR_WIDTH;

reg [DATA_WIDTH-1:0] mem[RAM_DEPTH-1:0];

integer i;

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) begin
        for(i = 0; i < RAM_DEPTH; i = i+1)
            mem[i] <= {DATA_WIDTH{1'b0}};
    end
    else if(!CEN && !WEN)
        mem[A] <= D;
end

always@(posedge clk or negedge rst_n) begin
if(!rst_n)
    Q <= {DATA_WIDTH{1'b0}};
else if(!CEN && WEN)
    Q <= mem[A];    
end

endmodule