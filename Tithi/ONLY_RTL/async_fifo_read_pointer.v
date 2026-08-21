module async_fifo_read_pointer #(
parameter addressize =4,
parameter prog_empty_thresh=3
)(
input rclk,                       // Read clock
input rst,                        // Reset signal
input rinc,                       // Read increment request
input [addressize :0] r_wptr2,   // Synchronized write pointer in Gray code
output reg [addressize:0] rbin,  // Read pointer in binary
output reg [addressize:0] rgray, // Read pointer in Gray code
output reg rempty,               // FIFO empty flag
output almost_empty,             // FIFO almost-empty flag
output prog_empty                // FIFO programmable empty flag
);
wire[addressize:0] rbinnext;      // Next read pointer in binary
wire[addressize:0] rgraynext;     // Next read pointer in Gray code
wire remptyval;                   // Next empty flag value
reg [addressize:0] wbin_sync;     // Synchronized write pointer converted to binary
wire[addressize:0]read_level;     // Number of unread data words
integer i;

// Update read pointer only when a valid read occurs and FIFO is not empty
assign rbinnext = (rinc && !rempty ) ? (rbin+1) : rbin;
assign rgraynext = rbinnext^(rbinnext>>1);
assign remptyval = (rgraynext==r_wptr2);

// Register read pointer and empty status on the read clock
always@(posedge rclk or posedge rst)
begin
if(rst)
begin
rbin<=0;
rgray<=0;
rempty<=1;
end
else
begin
rbin<=rbinnext;
rgray<=rgraynext;
rempty<=remptyval;
end 
end 

// Convert synchronized write pointer from Gray code to binary
always @(*)
begin
wbin_sync[addressize]=r_wptr2[addressize];
for(i=addressize-1;i>=0;i=i-1)
begin
wbin_sync[i]=wbin_sync[i+1]^r_wptr2[i];
end 
end 

assign read_level= wbin_sync-rbin;
assign almost_empty = (read_level <= 2) ? 1:0;
assign prog_empty = (read_level <= prog_empty_thresh) ? 1 : 0;


endmodule
