module ahb2apb #(
    parameter AHB_DATA_WIDTH = 32,
    parameter AHB_ADDR_WIDTH = 32,
    parameter APB_DATA_WIDTH = 32,
    parameter APB_ADDR_WIDTH = 32
)(
    input                           ahb_hclk   ,
    input                           ahb_hrstn  ,
    input                           ahb_hsel   ,
    input      [1               :0] ahb_htrans ,
    input      [AHB_ADDR_WIDTH-1:0] ahb_haddr  ,
    input      [AHB_DATA_WIDTH-1:0] ahb_hwdata ,
    input                           ahb_hwrite ,
    output                          ahb_hready ,
    output reg [AHB_DATA_WIDTH-1:0] ahb_hrdata ,

    input                           apb_pclk   ,
    input                           apb_prstn  ,
    output reg                      apb_psel   ,
    output reg                      apb_pwrite ,
    output reg                      apb_penable,
    output reg [APB_ADDR_WIDTH-1:0] apb_paddr  ,
    output reg [APB_DATA_WIDTH-1:0] apb_pwdata ,
    input                           apb_pready ,
    input      [APB_DATA_WIDTH-1:0] apb_prdata
); 

//ahb rw signal
wire ahb_wr_en    ;
wire ahb_rd_en    ;
wire ahb_wr_hready;
reg  ahb_rd_hready;

//ahb delay 1 clk
reg  [AHB_ADDR_WIDTH-1:0] ahb_haddr_reg; 
reg                       ahb_wr_en_dly;
reg                       ahb_rd_en_dly;

//ahb wr fifo
wire                                   async_fifo_cmd_wr_en ;
wire [AHB_ADDR_WIDTH+AHB_DATA_WIDTH:0] async_fifo_cmd_wdata ;
wire                                   async_fifo_cmd_rd_en ;
wire [AHB_ADDR_WIDTH+AHB_DATA_WIDTH:0] async_fifo_cmd_rdata ;
wire                                   async_fifo_cmd_full  ;
wire                                   async_fifo_cmd_empty ;

wire                                   async_fifo_recv_wr_en;
wire [APB_DATA_WIDTH-1:0]              async_fifo_recv_wdata;
wire                                   async_fifo_recv_rd_en;
wire [APB_DATA_WIDTH-1:0]              async_fifo_recv_rdata;
wire                                   aysnc_fifo_recv_full ;
wire                                   async_fifo_recv_empty;

// apb flag
reg  apb_cmd_flag;

//ahb wr rd en
assign ahb_wr_en = ahb_hsel &&  ahb_hwrite && ahb_htrans[1] && ahb_hready;
assign ahb_rd_en = ahb_hsel && ~ahb_hwrite && ahb_htrans[1] && ahb_hready;

//haddr wr_en rd_en delay 1clk
always@(posedge ahb_hclk or negedge ahb_hrstn) 
begin
    if(!ahb_hrstn) begin
        ahb_wr_en_dly <= 1'b0;
        ahb_rd_en_dly <= 1'b0;
        ahb_haddr_reg <= {AHB_ADDR_WIDTH{1'b0}};
    end
    else begin
        ahb_wr_en_dly <= ahb_wr_en;
        ahb_rd_en_dly <= ahb_rd_en;
        ahb_haddr_reg <= ahb_haddr;
    end
end

//cmd fifo logic
assign async_fifo_cmd_wr_en = ahb_wr_en_dly || ahb_rd_en_dly         ;
assign async_fifo_cmd_wdata  = {ahb_hwrite, ahb_haddr_reg, ahb_hwdata};
assign ahb_wr_hready        = ~async_fifo_cmd_full                   ;
assign async_fifo_cmd_rd_en = ~async_fifo_cmd_empty && ~apb_cmd_flag ;

async_fifo #(
    .DATA_WIDTH(AHB_ADDR_WIDTH+AHB_DATA_WIDTH+1)
)async_fifo_cmd_u0(
    .wr_clk  (ahb_hclk            ),
    .wr_rst_n(ahb_hrstn           ),
    .wr_en   (async_fifo_cmd_wr_en),
    .wr_data (async_fifo_cmd_wdata),
    .rd_clk  (apb_pclk            ),
    .rd_rst_n(apb_prstn           ),
    .rd_en   (async_fifo_cmd_rd_en),
    .rd_data (async_fifo_cmd_rdata),
    .full    (async_fifo_cmd_full ),
    .afull   (                    ),
    .empty   (async_fifo_cmd_empty),
    .aempty  (                    )
);

async_fifo #(
    .DATA_WIDTH(AHB_DATA_WIDTH)
)async_fifo_recv_u0(
    .wr_clk  (apb_pclk             ),
    .wr_rst_n(apb_prstn            ),
    .wr_en   (async_fifo_recv_wr_en),
    .wr_data (async_fifo_recv_wdata),
    .rd_clk  (ahb_hclk             ),
    .rd_rst_n(ahb_hrstn            ),
    .rd_en   (async_fifo_recv_rd_en),
    .rd_data (async_fifo_recv_rdata),
    .full    (aysnc_fifo_recv_full ),
    .afull   (                     ),
    .empty   (async_fifo_recv_empty),
    .aempty  (                     )
);

//apb flag
always@(posedge apb_pclk or negedge apb_prstn) begin
if(!apb_prstn)
    apb_cmd_flag <= 1'b0;
else if(apb_penable && apb_pready)
    apb_cmd_flag <= 1'b0;
else if(async_fifo_cmd_rd_en)
    apb_cmd_flag <= 1'b1; // read a cmd once, cannot read next cmd until APB finishes
end

//apb logic write logic
always@(posedge apb_pclk or negedge apb_prstn) 
begin
    if(!apb_prstn) begin
        apb_psel    <= 1'b0;
        apb_pwrite <= 1'b0;
        apb_paddr   <= {APB_ADDR_WIDTH{1'b0}};
        apb_pwdata  <= {APB_DATA_WIDTH{1'b0}};
    end    
    else if(apb_penable && apb_pready) begin
        apb_psel   <= 1'b0;
        apb_pwrite <= 1'b0;
    end
    else if(async_fifo_cmd_rd_en) begin
        apb_psel   <= 1'b1;
        apb_pwrite <= async_fifo_cmd_rdata[AHB_ADDR_WIDTH+AHB_DATA_WIDTH                 ];
        apb_paddr  <= async_fifo_cmd_rdata[AHB_ADDR_WIDTH+AHB_DATA_WIDTH-1:AHB_DATA_WIDTH]; 
        apb_pwdata <= async_fifo_cmd_rdata[AHB_DATA_WIDTH-1               :0             ];
    end
end

always@(posedge apb_pclk or negedge apb_prstn) begin
if(!apb_prstn)
    apb_penable <= 1'b0;
else if(apb_penable && apb_pready)
    apb_penable <= 1'b0;
else if(apb_psel)
    apb_penable <= 1'b1;
end

//recv fifo logic
assign async_fifo_recv_wr_en = apb_penable && apb_pready && ~apb_pwrite; //only read transaction can write recv fifo
assign async_fifo_recv_rd_en = ~async_fifo_recv_empty                  ;
assign async_fifo_recv_wdata = apb_prdata                              ;

//rd_hready and hrdata sync
always@(posedge ahb_hclk or negedge ahb_hrstn) begin
if(!ahb_hrstn)
    ahb_rd_hready <= 1'b1;
else if(async_fifo_recv_rd_en)
    ahb_rd_hready <= 1'b1;
else if(ahb_rd_en)
    ahb_rd_hready <= 1'b0;
end

assign ahb_hready = ahb_wr_hready && ahb_rd_hready;

always@(posedge ahb_hclk or negedge ahb_hrstn) begin
if(!ahb_hrstn)
    ahb_hrdata <= {AHB_DATA_WIDTH{1'b0}};
else
    ahb_hrdata <= async_fifo_recv_rdata;
end

endmodule
