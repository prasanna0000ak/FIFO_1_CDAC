```verilog
module async_wptr_sync_rd #(
parameter addressize =4
)(
input rclk,                              // Read clock
input [addressize:0] wgray,              // Write pointer in Gray code
input rst,                               // Reset signal
output reg [addressize:0] r_wptr2        // Synchronized write pointer in read clock domain
);
reg [addressize : 0]r_wptr1;             // First-stage synchronized write pointer

// Synchronize the write pointer into the read clock domain
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
```
