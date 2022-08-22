`timescale 1ns/1ns
module tb_uart2apb();

parameter APB_ADDR_WIDTH = 16;
parameter APB_DATA_WIDTH = 32;

reg         clk        ;
reg         rst_n      ;

reg         rx         ;
wire        tx         ;

wire        apb_psel   ;
wire [15:0] apb_paddr  ;
wire [31:0] apb_pwdata ;
wire        apb_pwrite ;
wire        apb_penable;    
reg         apb_pready ;
reg  [31:0] apb_prdata ;   

integer I = 0;
integer J = 0;
integer UART_DELAY = 0;

uart2apb U_uart2apb0(
    .clk        (clk        ),
    .rst_n      (rst_n      ),
                            
    .rx         (rx         ),
    .tx         (tx         ),
                            
    .apb_psel   (apb_psel   ),
    .apb_paddr  (apb_paddr  ),
    .apb_pwdata (apb_pwdata ),
    .apb_pwrite (apb_pwrite ),
    .apb_penable(apb_penable),
    .apb_pready (apb_pready ),
    .apb_prdata (apb_prdata )
);

initial begin
    clk = 1'b0; rst_n = 1'b0;
    rx = 1'b1; apb_pready = 1'b0;
    apb_prdata = 32'd0;
    #10 rst_n = 1'b1;
end

always #5 clk = ~clk;

task send_uart_byte;
input [7:0] din;
begin
    for(I=0; I<11; I = I+1) begin
        if(I == 0) begin
            @(posedge clk) rx <= 1'b0;
            repeat(433) @(posedge clk);
        end 
        else if(I >=1 && I <=8) begin
            @(posedge clk) rx <= din[I-1];
            repeat(433) @(posedge clk);
        end
        else if(I == 9) begin
            @(posedge clk) rx <= ~^din;
            repeat(433) @(posedge clk);
        end
        else begin
            @(posedge clk) rx <= 1'b1;
            repeat(433) @(posedge clk);
        end
    end
    if(UART_DELAY == 1)
        repeat(100) @(posedge clk);
end
endtask

task send_write;
input [55:0] data;
begin
    for(J=0; J<=6; J=J+1) begin
        send_uart_byte(data[J*8+:8]);
    end
    @(posedge clk) apb_pready <= 1'b1;
    wait(apb_penable == 1'b1);
    @(posedge clk) apb_pready <= 1'b0;
end
endtask

task send_read;
input [23:0] data;
begin
    for(J=0; J<=2; J=J+1) begin
        send_uart_byte(data[J*8+:8]);
    end
    wait(apb_psel == 1'b1);
    @(posedge clk) begin
        apb_pready <= 1'b1;
        apb_prdata <= {8'd14,8'd13,8'd12,8'd11};
    end
    @(posedge clk) begin
        apb_pready <= 1'b0;
        apb_prdata <= 32'd0;
    end    
end
endtask

initial begin
    #20 send_write({8'd13,8'd12,8'd11,8'd10,8'd101,8'd100,8'ha5});
    repeat(100) @(posedge clk);
    send_read({8'd51,8'd50,8'h5a});
    repeat(30000) @(posedge clk);
    $finish;
end

initial begin
    $fsdbDumpfile("wave_uart2apb.fsdb");
    $fsdbDumpvars;
end




endmodule
