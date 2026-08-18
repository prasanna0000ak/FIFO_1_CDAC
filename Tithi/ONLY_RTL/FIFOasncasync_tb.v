`timescale 1ns / 1ps

module FIFOsyncasync_tb;

parameter datasize = 8;
parameter addressize = 2;
parameter prog_full_thresh = 2;
parameter prog_empty_thresh = 2;

reg wclk_sync;
reg rclk_sync;

reg wclk_async;
reg rclk_async;

reg rst_sync;
reg rst_async;

reg winc_sync;
reg rinc_sync;
reg [datasize-1:0] wdata_sync;

reg winc_async;
reg rinc_async;
reg [datasize-1:0] wdata_async;

wire [datasize-1:0] rdata_sync;
wire wfull_sync;
wire rempty_sync;
wire almost_full_sync;
wire almost_empty_sync;
wire prog_full_sync;
wire prog_empty_sync;

wire [datasize-1:0] rdata_async;
wire wfull_async;
wire rempty_async;
wire almost_full_async;
wire almost_empty_async;
wire prog_full_async;
wire prog_empty_async;


FIFOsyncasync_top #(
.datasize(datasize),
.addressize(addressize),
.prog_full_thresh(prog_full_thresh),
.prog_empty_thresh(prog_empty_thresh),
.FIFO_mode(0)
) DUT_SYNC (
.wclk(wclk_sync),
.rclk(rclk_sync),
.rst(rst_sync),
.rinc(rinc_sync),
.winc(winc_sync),
.wdata(wdata_sync),
.rdata(rdata_sync),
.wfull(wfull_sync),
.rempty(rempty_sync),
.almost_full(almost_full_sync),
.almost_empty(almost_empty_sync),
.prog_full(prog_full_sync),
.prog_empty(prog_empty_sync)
);


FIFOsyncasync_top #(
.datasize(datasize),
.addressize(addressize),
.prog_full_thresh(prog_full_thresh),
.prog_empty_thresh(prog_empty_thresh),
.FIFO_mode(1)
) DUT_ASYNC (
.wclk(wclk_async),
.rclk(rclk_async),
.rst(rst_async),
.rinc(rinc_async),
.winc(winc_async),
.wdata(wdata_async),
.rdata(rdata_async),
.wfull(wfull_async),
.rempty(rempty_async),
.almost_full(almost_full_async),
.almost_empty(almost_empty_async),
.prog_full(prog_full_async),
.prog_empty(prog_empty_async)
);


initial
begin
$dumpfile("FIFOsyncasync_tb.vcd");
$dumpvars(0,FIFOsyncasync_tb);
end

initial
begin
wclk_sync = 0;
forever #5 wclk_sync = ~wclk_sync;
end

initial
begin
rclk_sync = 0;
forever #5 rclk_sync = ~rclk_sync;
end

initial
begin
wclk_async = 0;
forever #5 wclk_async = ~wclk_async;
end

initial
begin
rclk_async = 0;
forever #7 rclk_async = ~rclk_async;
end


initial
begin

rst_sync = 1;
winc_sync = 0;
rinc_sync = 0;
wdata_sync = 0;

rst_async = 1;
winc_async = 0;
rinc_async = 0;
wdata_async = 0;

#20;

rst_sync = 0;
rst_async = 0;


winc_sync = 1;

wdata_sync = 8'hA1;
@(posedge wclk_sync);
#1;

wdata_sync = 8'hB2;
@(posedge wclk_sync);
#1;

wdata_sync = 8'hC3;
@(posedge wclk_sync);
#1;

wdata_sync = 8'hD4;
@(posedge wclk_sync);
#1;

winc_sync = 0;


winc_async = 1;

wdata_async = 8'h11;
@(posedge wclk_async);
#1;

wdata_async = 8'h22;
@(posedge wclk_async);
#1;

wdata_async = 8'h33;
@(posedge wclk_async);
#1;

wdata_async = 8'h44;
@(posedge wclk_async);
#1;

winc_async = 0;


repeat(3) @(posedge rclk_sync);

rinc_sync = 1;

repeat(4) @(posedge rclk_sync);

rinc_sync = 0;


repeat(4) @(posedge rclk_async);

rinc_async = 1;

repeat(4) @(posedge rclk_async);

rinc_async = 0;


#50;

$finish;

end

endmodule

