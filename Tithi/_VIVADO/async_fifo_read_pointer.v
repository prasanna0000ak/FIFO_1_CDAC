module async_fifo_read_pointer #(
parameter addressize =4,
parameter prog_empty_thresh=3
)(
input rclk,
input rst,
input rinc,
input [addressize :0] r_wptr2,
output reg [addressize:0] rbin,
output reg [addressize:0] rgray,
output reg rempty,
output almost_empty,
output prog_empty
);
wire[addressize:0] rbinnext;
wire[addressize:0] rgraynext;
wire remptyval;
reg [addressize:0] wbin_sync;
wire[addressize:0]read_level;
integer i;

assign rbinnext = (rinc && !rempty ) ? (rbin+1) : rbin;
assign rgraynext = rbinnext^(rbinnext>>1);
assign remptyval = (rgraynext==r_wptr2);

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


