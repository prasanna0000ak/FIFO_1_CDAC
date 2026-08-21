`timescale 1ns / 1ps

module FIFOsyncasync_top #(
parameter datasize = 8,                                      // FIFO data width
parameter addressize = 4,                                    // FIFO address width
parameter prog_full_thresh = 3,                             // Programmable full threshold
parameter prog_empty_thresh = 3,                            // Programmable empty threshold
parameter FIFO_mode = 0                                     // FIFO mode: 0 = synchronous, 1 = asynchronous
)(
input wclk,                                                   // Write clock
input rclk,                                                   // Read clock
input rst,                                                    // Reset signal
input rinc,                                                   // Read increment request
input winc,                                                   // Write increment request
input [datasize-1:0] wdata,                                  // Data to be written
output [datasize-1:0] rdata,                                 // Data read from FIFO
output wfull,                                                 // FIFO full flag
output rempty,                                                // FIFO empty flag
output almost_full,                                           // FIFO almost-full flag
output almost_empty,                                          // FIFO almost-empty flag
output prog_full,                                             // FIFO programmable-full flag
output prog_empty                                             // FIFO programmable-empty flag
);
wire [addressize:0] wbin;                                    // Write pointer in binary
wire [addressize:0] rbin;                                    // Read pointer in binary
wire [addressize:0] wgray;                                   // Write pointer in Gray code
wire [addressize:0] rgray;                                   // Read pointer in Gray code
wire [addressize:0] w_rptr2;                                 // Synchronized read pointer in write clock domain
wire [addressize:0] r_wptr2;                                 // Synchronized write pointer in read clock domain
wire wen;                                                     // Memory write enable
wire ren;                                                     // Memory read enable

// Generate memory write and read enables based on FIFO status
assign wen = winc && !wfull;
assign ren = rinc && !rempty;
generate

// Select synchronous FIFO architecture
if(FIFO_mode == 0)
begin : SYNC_MODE

// Synchronous FIFO write pointer and status logic
sync_fifo_write_pointer #(
.addressize(addressize),
.prog_full_thresh(prog_full_thresh)
) sync_fifo_write_pointer1 (
.clk(wclk),
.rst(rst),
.winc(winc),
.rbin_sync(rbin),
.wfull(wfull),
.almost_full(almost_full),
.prog_full(prog_full),
.wbin(wbin)
);

// Synchronous FIFO read pointer and status logic
sync_fifo_read_pointer #(
.addressize(addressize),
.prog_empty_thresh(prog_empty_thresh)
) sync_fifo_read_pointer1 (
.clk(wclk),
.rst(rst),
.rinc(rinc),
.wbin_sync(wbin),
.rempty(rempty),
.almost_empty(almost_empty),
.prog_empty(prog_empty),
.rbin(rbin)
);
end

// Select asynchronous FIFO architecture
else
begin : ASYNC_MODE

// Asynchronous FIFO write pointer and status logic
async_fifo_write_pointer #(
.addressize(addressize),
.prog_full_thresh(prog_full_thresh)
) async_fifo_write_pointer1 (
.wclk(wclk),
.winc(winc),
.rst(rst),
.w_rptr2(w_rptr2),
.wbin(wbin),
.wgray(wgray),
.wfull(wfull),
.almost_full(almost_full),
.prog_full(prog_full)
);

// Asynchronous FIFO read pointer and status logic
async_fifo_read_pointer #(
.addressize(addressize),
.prog_empty_thresh(prog_empty_thresh)
) async_fifo_read_pointer1 (
.rclk(rclk),
.rst(rst),
.rinc(rinc),
.r_wptr2(r_wptr2),
.rbin(rbin),
.rgray(rgray),
.rempty(rempty),
.almost_empty(almost_empty),
.prog_empty(prog_empty)
);

// Synchronize read pointer into write clock domain
async_rptr_sync_wd #(
.addressize(addressize)
) async_rptr_sync_wd1 (
.wclk(wclk),
.rgray(rgray),
.rst(rst),
.w_rptr2(w_rptr2)
);

// Synchronize write pointer into read clock domain
async_wptr_sync_rd #(
.addressize(addressize)
) async_wptr_sync_rd1 (
.rclk(rclk),
.wgray(wgray),
.rst(rst),
.r_wptr2(r_wptr2)
);

end
endgenerate

// FIFO memory for storing and reading data
fifi_memory #(
.datasize(datasize),
.addressize(addressize)
) fifi_memory1 (
.wclk(wclk),
.rclk(rclk),
.wen(wen),
.ren(ren),
.wdata(wdata),
.waddr(wbin[addressize-1:0]),
.raddr(rbin[addressize-1:0]),
.rdata(rdata)
);

endmodule
