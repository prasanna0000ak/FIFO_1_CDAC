 module async_rptr_sync_wd #(
parameter addressize =4
)(
input wclk,
input [addressize:0] rgray,
input rst,
output reg [addressize:0] w_rptr2
);
 reg [addressize : 0]w_rptr1;

always@(posedge wclk or posedge rst)
begin
if(rst)
begin
w_rptr1<= 0;
w_rptr2<= 0;
end
else
begin
w_rptr1<= rgray;
w_rptr2<= w_rptr1;
end 
end 
endmodule
