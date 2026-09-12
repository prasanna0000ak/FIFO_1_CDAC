`timescale 1ns / 1ps

// Converts binary counter to Gray code (wgray) for safe clock domain crossing.

module async_fifo_write_pointer #(
parameter addressize = 4,        // Address bit width (depth = 2^addressize)
parameter prog_full_thresh = 3   // Threshold for prog_full flag
)(
input wclk,                          // Write clock
input winc,                          // Write enable request
input rst,                           // Reset
input [addressize:0] w_rptr2,        // Synchronized read Gray pointer from read clock domain
output reg [addressize:0] wbin,      // Binary write pointer
output reg [addressize:0] wgray,     // Gray code write pointer
output reg wfull,                    // Full flag output
output almost_full,                  // Almost full flag output
output prog_full                     // Programmable full flag output
);

wire [addressize:0] wbinnext;
wire [addressize:0] wgraynext;
wire wfullval;
wire [addressize:0] fifo_depth;
wire [addressize:0] free_space;
wire [addressize:0] write_level;
reg [addressize:0] rbin_async;
integer i;

// Binary increment and Binary-to-Gray Conversion
assign wbinnext = (winc && !wfull) ? (wbin + 1) : wbin;
assign wgraynext = wbinnext ^ (wbinnext >> 1); // Gray Code = Binary ^ (Binary >> 1)

// Full condition: Top 2 MSBs inverted, rest matching
assign wfullval = (wgraynext == {~w_rptr2[addressize:addressize-1], w_rptr2[addressize-2:0]});

always @(posedge wclk or posedge rst) begin
if (rst) begin
wbin <= 0;
wgray <= 0;
wfull <= 0;
end else begin
wbin <= wbinnext;
wgray <= wgraynext;
wfull <= wfullval;
end
end

// Gray to Binary conversion of synchronized read pointer to calculate level
always @(*) begin
rbin_async[addressize] = w_rptr2[addressize];
for (i = addressize - 1; i >= 0; i = i - 1) begin
rbin_async[i] = rbin_async[i+1] ^ w_rptr2[i];
end
end

assign fifo_depth = 2**addressize;
assign write_level = wbin - rbin_async;
assign free_space = fifo_depth - write_level;

assign almost_full = (free_space <= 2) ? 1 : 0;
assign prog_full   = (free_space <= prog_full_thresh) ? 1 : 0;

endmodule
