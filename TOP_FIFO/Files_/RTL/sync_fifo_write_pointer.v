`timescale 1ns / 1ps

// EXPLANATION: Manages write pointer counter (wbin) for single-clock synchronous FIFO.
// Calculates status flags: wfull (Full), almost_full (<=2 free spaces left), and prog_full.

module sync_fifo_write_pointer #(
parameter addressize = 4,        // Address bit width (depth = 2^addressize)
parameter prog_full_thresh = 3   // Free space threshold for prog_full flag
)(
input clk,                           // Synchronous clock
input rst,                           // Reset
input winc,                          // Write increment request
input [addressize : 0] rbin_sync,     // Read pointer for comparison
output reg wfull,                    // Full flag output
output almost_full,                  // Almost full flag output
output prog_full,                    // Programmable full flag output
output reg [addressize : 0] wbin     // Write pointer counter output
);

wire [addressize : 0] wbinnext;
wire [addressize : 0] write_level;
wire [addressize : 0] free_space;
wire wfullval;
wire [addressize : 0] fifo_depth;

// Calculate next write pointer value
assign wbinnext = (winc && !wfull) ? wbin + 1 : wbin;
// Check if write pointer matches read pointer with MSB inverted (Full condition)
assign wfullval = (wbinnext == {~rbin_sync[addressize], rbin_sync[addressize-1:0]});

always @(posedge clk or posedge rst) 

begin
if (rst)
begin
wfull <= 0;
wbin <= 0;
end 

else
begin
wfull <= wfullval;
wbin <= wbinnext;
end
end

// Calculate used level and remaining free space
assign write_level = wbin - rbin_sync;
assign fifo_depth = 2**addressize;
assign free_space = fifo_depth - write_level;

// Flag thresholds
assign almost_full = (free_space <= 2) ? 1 : 0;
assign prog_full   = (free_space <= prog_full_thresh) ? 1 : 0;

endmodule
