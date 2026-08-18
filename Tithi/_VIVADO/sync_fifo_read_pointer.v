`timescale 1ns / 1ps

module sync_fifo_read_pointer #(
parameter addressize =4,
parameter prog_empty_thresh = 3
)(
input clk,
input rst,
input rinc,
input [addressize : 0]wbin_sync,
output reg rempty,
output  reg [addressize : 0]rbin,
output almost_empty,
output prog_empty
);

wire [ addressize : 0] rbinnext;
wire [ addressize : 0] read_level;
wire remptyval ;


assign rbinnext = (rinc && !rempty) ? rbin+1 : rbin;
assign remptyval = (rbinnext==wbin_sync);

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

assign read_level=wbin_sync-rbin;
assign almost_empty= (read_level <= 2) ? 1:0;
assign prog_empty = (read_level <= prog_empty_thresh) ? 1:0;

endmodule 

