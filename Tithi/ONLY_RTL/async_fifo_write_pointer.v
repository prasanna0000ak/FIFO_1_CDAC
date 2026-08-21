module async_fifo_write_pointer #(
parameter addressize =4,
parameter prog_full_thresh = 3
)(
input wclk,                                      // Write clock
input winc,                                      // Write increment request
input rst,                                       // Reset signal
input  [addressize:0] w_rptr2,                   // Synchronized read pointer in Gray code
output reg [addressize:0] wbin,                  // Write pointer in binary
output reg [addressize:0] wgray,                 // Write pointer in Gray code
output reg wfull,                                // FIFO full flag
output almost_full,                              // FIFO almost-full flag
output prog_full                                 // FIFO programmable full flag

);
wire [addressize:0]wbinnext;                     // Next write pointer in binary
wire [addressize:0] wgraynext;                   // Next write pointer in Gray code
wire wfullval;                                    // Next full flag value
wire [addressize : 0 ] fifo_depth;               // Total FIFO depth
wire [addressize : 0 ] free_space;               // Available space in FIFO
wire [addressize : 0 ] write_level;              // Number of data words currently stored
reg [addressize : 0 ] rbin_async;                // Synchronized read pointer converted to binary
integer i;

// Update write pointer only when a valid write occurs and FIFO is not full
assign wbinnext=(winc && !wfull) ? (wbin+1) : wbin;
assign wgraynext = wbinnext ^(wbinnext>>1);

// Detect FIFO full condition by comparing the next write pointer
// with the read pointer having its two MSBs inverted
assign wfullval= 
(wgraynext=={~w_rptr2[addressize:addressize-1],w_rptr2[addressize-2:0]});

// Register write pointer and full status on the write clock
always @(posedge wclk or posedge  rst)
begin 
if(rst)
begin
wbin<=0;
wgray<=0;

wfull <= 0;
end 
else
begin
wbin<=wbinnext;
wgray<= wgraynext;
wfull<=wfullval;
end
end

// Convert synchronized read pointer from Gray code to binary
always @(*)
begin
rbin_async[addressize] = w_rptr2[addressize];
for(i=addressize -1;i>=0;i = i-1)
begin
rbin_async[i]=rbin_async[i+1]^w_rptr2[i];
end
end

// Calculate FIFO depth, current write level and available free space
assign fifo_depth = 2**addressize;
assign write_level= wbin-rbin_async;
assign free_space= fifo_depth - write_level;

// Generate almost-full and programmable-full status flags
assign almost_full = (free_space <= 2) ? 1:0;
assign prog_full = (free_space <= prog_full_thresh) ? 1 : 0;

endmodule
