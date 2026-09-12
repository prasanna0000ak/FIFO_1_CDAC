`timescale 1ns / 1ps

// EXPLANATION: Manages read pointer counter (rbin) for single-clock synchronous FIFO.
// Calculates status flags: rempty (Empty), almost_empty (<=2 items left), and prog_empty.

module sync_fifo_read_pointer #(
parameter addressize = 4,         // Address bit width (depth = 2^addressize)
parameter prog_empty_thresh = 3   // Word level threshold for prog_empty flag
)(
input clk,                           // Synchronous clock
input rst,                           // Reset
input rinc,                          // Read increment request
input [addressize : 0] wbin_sync,    // Write pointer for comparison
output reg rempty,                   // Empty flag output
output reg [addressize : 0] rbin,    // Read pointer counter output
output almost_empty,                 // Almost empty flag output
output prog_empty                    // Programmable empty flag output
);

wire [addressize : 0] rbinnext;
wire [addressize : 0] read_level;
wire remptyval;

// Calculate next read pointer value
assign rbinnext = (rinc && !rempty) ? rbin + 1 : rbin;
// Empty condition: Read pointer equals Write pointer
assign remptyval = (rbinnext == wbin_sync);

always @(posedge clk or posedge rst) 

begin
if (rst) 

begin
rbin <= 0;
rempty <= 1;
end

else 

begin
rempty <= remptyval;
rbin <= rbinnext;
end
end

// Calculate used word level
assign read_level = wbin_sync - rbin;

// Flag thresholds
assign almost_empty = (read_level <= 2) ? 1 : 0;
assign prog_empty   = (read_level <= prog_empty_thresh) ? 1 : 0;

endmodule
