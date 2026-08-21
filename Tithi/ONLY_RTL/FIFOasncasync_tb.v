`timescale 1ns / 1ps

module FIFOsyncasync_tb;

parameter datasize = 8;                         // FIFO data width
parameter addressize = 2;                       // FIFO address width
parameter prog_full_thresh = 2;                // Programmable full threshold
parameter prog_empty_thresh = 2;               // Programmable empty threshold

reg wclk_sync;                                  // Synchronous FIFO write clock
reg rclk_sync;                                  // Synchronous FIFO read clock

reg wclk_async;                                 // Asynchronous FIFO write clock
reg rclk_async;                                 // Asynchronous FIFO read clock

reg rst_sync;                                   // Synchronous FIFO reset
reg rst_async;                                  // Asynchronous FIFO reset

reg winc_sync;                                  // Synchronous FIFO write enable
reg rinc_sync;                                  // Synchronous FIFO read enable
reg [datasize-1:0] wdata_sync;                 // Synchronous FIFO write data

reg winc_async;                                 // Asynchronous FIFO write enable
reg rinc_async;                                 // Asynchronous FIFO read enable
reg [datasize-1:0] wdata_async;                // Asynchronous FIFO write data

wire [datasize-1:0] rdata_sync;                // Synchronous FIFO read data
wire wfull_sync;                                // Synchronous FIFO full flag
wire rempty_sync;                               // Synchronous FIFO empty flag
wire almost_full_sync;                          // Synchronous FIFO almost-full flag
wire almost_empty_sync;                         // Synchronous FIFO almost-empty flag
wire prog_full_sync;                            // Synchronous FIFO programmable-full flag
wire prog_empty_sync;                           // Synchronous FIFO programmable-empty flag

wire [datasize-1:0] rdata_async;               // Asynchronous FIFO read data
wire wfull_async;                               // Asynchronous FIFO full flag
wire rempty_async;                              // Asynchronous FIFO empty flag
wire almost_full_async;                         // Asynchronous FIFO almost-full flag
wire almost_empty_async;                        // Asynchronous FIFO almost-empty flag
wire prog_full_async;                           // Asynchronous FIFO programmable-full flag


// Instantiate synchronous FIFO
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


// Instantiate asynchronous FIFO
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


// Generate waveform dump file
initial
begin
$dumpfile("FIFOsyncasync_tb.vcd");
$dumpvars(0,FIFOsyncasync_tb);
end


// Generate synchronous FIFO write clock
initial
begin
wclk_sync = 0;
forever #5 wclk_sync = ~wclk_sync;
end


// Generate synchronous FIFO read clock
initial
begin
rclk_sync = 0;
forever #5 rclk_sync = ~rclk_sync;
end


// Generate asynchronous FIFO write clock
initial
begin
wclk_async = 0;
forever #5 wclk_async = ~wclk_async;
end


// Generate asynchronous FIFO read clock
initial
begin
rclk_async = 0;
forever #7 rclk_async = ~rclk_async;
end


// Apply reset and perform FIFO write/read operations
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


// Write data into synchronous FIFO
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


// Write data into asynchronous FIFO
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


// Allow synchronous FIFO data to become available for reading
repeat(3) @(posedge rclk_sync);

rinc_sync = 1;

repeat(4) @(posedge rclk_sync);

rinc_sync = 0;


// Allow asynchronous FIFO data to become available for reading
repeat(4) @(posedge rclk_async);

rinc_async = 1;

repeat(4) @(posedge rclk_async);

rinc_async = 0;


#50;

$finish;

end

endmodule
