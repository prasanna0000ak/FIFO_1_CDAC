`timescale 1ns / 1ps

// Converts binary counter to Gray code (rgray) for safe clock domain crossing.

module async_fifo_read_pointer #(
parameter addressize = 4,             // Address bit width (depth = 2^addressize)
parameter prog_empty_thresh = 3      // Threshold for prog_empty flag
)(
input rclk,                          // Read clock
input rst,                           // Reset
input rinc,                          // Read enable request
input [addressize:0] r_wptr2,        // Synchronized write Gray pointer from write clock domain
output reg [addressize:0] rbin,      // Binary read pointer
output reg [addressize:0] rgray,     // Gray code read pointer
output reg rempty,                   // Empty flag output
output almost_empty,                 // Almost empty flag output
output prog_empty                    // Programmable empty flag output
);

wire [addressize:0] rbinnext;
wire [addressize:0] rgraynext;
wire remptyval;
reg [addressize:0] wbin_sync;
wire [addressize:0] read_level;
integer i;

// Binary increment and Binary-to-Gray Conversion
assign rbinnext = (rinc && !rempty) ? (rbin + 1) : rbin;
assign rgraynext = rbinnext ^ (rbinnext >> 1); // Gray Code = Binary ^ (Binary >> 1)

// Empty condition: Read Gray pointer matches synchronized Write Gray pointer
assign remptyval = (rgraynext == r_wptr2);

always @(posedge rclk or posedge rst) begin
if (rst) begin
rbin <= 0;
rgray <= 0;
rempty <= 1;
end else begin
rbin <= rbinnext;
rgray <= rgraynext;
rempty <= remptyval;
end
end

// Gray to Binary conversion of synchronized write pointer to calculate level
always @(*) begin
wbin_sync[addressize] = r_wptr2[addressize];
for (i = addressize - 1; i >= 0; i = i - 1) begin
wbin_sync[i] = wbin_sync[i+1] ^ r_wptr2[i];
end
end

assign read_level = wbin_sync - rbin;
assign almost_empty = (read_level <= 2) ? 1 : 0;
assign prog_empty   = (read_level <= prog_empty_thresh) ? 1 : 0;

endmodule
