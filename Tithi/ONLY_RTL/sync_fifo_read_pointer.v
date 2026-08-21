`timescale 1ns / 1ps

module sync_fifo_read_pointer #(
parameter addressize =4,
parameter prog_empty_thresh = 3
)(
input clk,                                      // FIFO clock
input rst,                                      // Reset signal
input rinc,                                     // Read increment request
input [addressize : 0]wbin_sync,                // Synchronized write pointer
output reg rempty,                              // FIFO empty flag
output  reg [addressize : 0]rbin,               // Read pointer in binary
output almost_empty,                            // FIFO almost-empty flag
output prog_empty                               // FIFO programmable empty flag
);

wire [ addressize : 0] rbinnext;                // Next read pointer
wire [ addressize : 0] read_level;              // Number of unread data words
wire remptyval ;                                // Next empty flag value

// Update read pointer only when a valid read occurs and FIFO is not empty
assign rbinnext = (rinc && !rempty) ? rbin+1 : rbin;
assign remptyval = (rbinnext==wbin_sync);

// Register read pointer and empty status on the FIFO clock
always@(posedge clk or posedge rst)
begin 
if(rst)
begin 
rbin <= 0;
rempty<=1;
end 
else
begin 
rempty <= remptyval;
rbin <= rbinnext;
end
end

// Calculate current number of unread data words
assign read_level=wbin_sync-rbin;

// Generate almost-empty and programmable-empty status flags
assign almost_empty= (read_level <= 2) ? 1:0;
assign prog_empty = (read_level <= prog_empty_thresh) ? 1:0;

endmodule 
