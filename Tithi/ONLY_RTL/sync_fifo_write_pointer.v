module sync_fifo_write_pointer #(
parameter addressize =4,
parameter prog_full_thresh =3
)(
input clk,                                      // FIFO clock
input rst,                                      // Reset signal
input winc,                                     // Write increment request
input [addressize : 0]rbin_sync,               // Synchronized read pointer
output reg wfull,                              // FIFO full flag
output almost_full,                            // FIFO almost-full flag
output prog_full,                              // FIFO programmable full flag
output reg [addressize :0]wbin                // Write pointer in binary
);

wire  [addressize : 0]wbinnext;                // Next write pointer
wire [addressize : 0] write_level;             // Number of data words currently stored
wire [addressize : 0] free_space;              // Available space in FIFO
wire wfullval;                                  // Next full flag value
wire [addressize :0]fifo_depth;                // Total FIFO depth

// Update write pointer only when a valid write occurs and FIFO is not full
assign wbinnext = (winc && !wfull) ? wbin+1 : wbin;

// Detect FIFO full condition by comparing the next write pointer
// with the read pointer having its MSB inverted
assign wfullval= (wbinnext=={~rbin_sync[addressize],rbin_sync[addressize -1:0]});
 
// Register write pointer and full status on the FIFO clock
always @(posedge clk or posedge rst)
begin
if(rst)
begin
wfull<=0;
wbin<= 0;
end
else
begin
wfull<=wfullval;
wbin<=wbinnext;
end
end

// Calculate current FIFO occupancy and available free space
assign  write_level = wbin - rbin_sync;
assign fifo_depth = 2**addressize;
assign free_space= fifo_depth-write_level;

// Generate almost-full and programmable-full status flags
assign almost_full = (free_space <= 2) ? 1 : 0;
assign prog_full = (free_space <= prog_full_thresh) ? 1 : 0;


endmodule
