module async_fifo_write_pointer #(
parameter addressize =4,
parameter prog_full_thresh = 3
)(
input wclk,
input winc,
input rst,
input  [addressize:0] w_rptr2,
output reg [addressize:0] wbin,
output reg [addressize:0] wgray,
output reg wfull,
output almost_full,
output prog_full

);
wire [addressize:0]wbinnext;
wire [addressize:0] wgraynext;
wire wfullval;
wire [addressize : 0 ] fifo_depth;
wire [addressize : 0 ] free_space;
wire [addressize : 0 ] write_level;
reg [addressize : 0 ] rbin_async;
integer i;

assign wbinnext=(winc && !wfull) ? (wbin+1) : wbin;
assign wgraynext = wbinnext ^(wbinnext>>1);
assign wfullval= 
(wgraynext=={~w_rptr2[addressize:addressize-1],w_rptr2[addressize-2:0]});

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
always @(*)
begin
rbin_async[addressize] = w_rptr2[addressize];
for(i=addressize -1;i>=0;i = i-1)
begin
rbin_async[i]=rbin_async[i+1]^w_rptr2[i];
end
end

assign fifo_depth = 2**addressize;
assign write_level= wbin-rbin_async;
assign free_space= fifo_depth - write_level;
assign almost_full = (free_space <= 2) ? 1:0;
assign prog_full = (free_space <= prog_full_thresh) ? 1 : 0;

endmodule 
