 module async_wptr_sync_rd #(
parameter addressize =4
)(
input rclk,
input [addressize:0] wgray,
input rst,
output reg [addressize:0] r_wptr2
);
 reg [addressize : 0]r_wptr1;

always@(posedge rclk or posedge rst)
begin
if(rst)
begin
r_wptr1<= 0;
r_wptr2<= 0;
end
else
begin
r_wptr1<= wgray;
r_wptr2<= r_wptr1;
end 
end 
endmodule
