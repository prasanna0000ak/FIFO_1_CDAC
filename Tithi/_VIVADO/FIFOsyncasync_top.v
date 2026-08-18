`timescale 1ns / 1ps

module FIFOsyncasync_top #(
parameter datasize = 8,
parameter addressize = 4,
parameter prog_full_thresh = 3,
parameter prog_empty_thresh = 3,
parameter FIFO_mode = 0
)(
input wclk,
input rclk,
input rst,
input rinc,
input winc,
input [datasize-1:0] wdata,
output [datasize-1:0] rdata,
output wfull,
output rempty,
output almost_full,
output almost_empty,
output prog_full,
output prog_empty
);

wire [addressize:0] wbin;
wire [addressize:0] rbin;
wire [addressize:0] wgray;
wire [addressize:0] rgray;

wire [addressize:0] w_rptr2;
wire [addressize:0] r_wptr2;

wire wen;
wire ren;

assign wen = winc && !wfull;
assign ren = rinc && !rempty;

generate

if(FIFO_mode == 0)
begin : SYNC_MODE

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

else
begin : ASYNC_MODE

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

async_rptr_sync_wd #(
.addressize(addressize)
) async_rptr_sync_wd1 (
.wclk(wclk),
.rgray(rgray),
.rst(rst),
.w_rptr2(w_rptr2)
);

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

