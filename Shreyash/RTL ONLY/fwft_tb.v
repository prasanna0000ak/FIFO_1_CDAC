`timescale 1ns / 1ps

module fwft_tb;
parameter DATA_WIDTH = 8;


reg RCLK;
reg RST;
reg REN;
reg REMPTY;
reg FWFT_enable;
reg [DATA_WIDTH-1:0] mem_rdata;

wire [DATA_WIDTH-1:0] rdata;
wire valid;
wire ren_fifo;


fwft #(
.read_datasize(DATA_WIDTH)
) DUT (

.RCLK (RCLK),
.RST (RST),
.REN (REN),
.REMPTY (REMPTY),
.FWFT_enable (FWFT_enable),
.mem_rdata (mem_rdata),

.rdata (rdata),
.valid (valid),
.ren_fifo (ren_fifo)
);


initial begin

RCLK = 0;
forever #5 RCLK = ~RCLK;

end


initial begin

RST = 1;
REN = 0;
REMPTY = 1;
FWFT_enable = 1;

mem_rdata = 8'h00;
#20;

RST = 0;
#10;

REMPTY = 0;
mem_rdata = 8'h1A;
#30;

REN = 1;
#10;

REN = 0;
mem_rdata = 8'h5A;
#30;

$finish;

end

endmodule