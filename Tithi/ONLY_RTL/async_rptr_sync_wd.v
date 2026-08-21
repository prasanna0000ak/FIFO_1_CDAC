module async_rptr_sync_wd #(
parameter addressize =4
)(
input wclk,                              // Write clock
input [addressize:0] rgray,              // Read pointer in Gray code
input rst,                               // Reset signal
output reg [addressize:0] w_rptr2        // Synchronized read pointer in write clock domain
);
reg [addressize : 0]w_rptr1;             // First-stage synchronized read pointer

// Synchronize the read pointer into the write clock domain
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
