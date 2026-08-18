module sync_fifo_write_pointer #(
parameter addressize =4,
parameter prog_full_thresh =3
)(
input clk,
input rst,
input winc,
input [addressize : 0]rbin_sync,
output reg wfull,
output almost_full,
output prog_full,
output reg [addressize :0]wbin
);

wire  [addressize : 0]wbinnext;
wire [addressize : 0] write_level;
wire [addressize : 0] free_space;
wire wfullval;
wire [addressize :0]fifo_depth;

assign wbinnext = (winc && !wfull) ? wbin+1 : wbin;
assign wfullval= (wbinnext=={~rbin_sync[addressize],rbin_sync[addressize -1:0]});
 
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

assign  write_level = wbin - rbin_sync;
assign fifo_depth = 2**addressize;
assign free_space= fifo_depth-write_level;
assign almost_full = (free_space <= 2) ? 1 : 0;
assign prog_full = (free_space <= prog_full_thresh) ? 1 : 0;


endmodule
