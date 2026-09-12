`timescale 1ns / 1ps

// EXPLANATION: 2-Stage D-Flip-Flop synchronizer passing Write Gray Pointer (wgray)
// across clock domains into Read Clock Domain (rclk) to prevent metastability.

module async_wptr_sync_rd #(
parameter addressize = 4  // Address bit width
)(
input rclk,                          // Destination Read clock
input [addressize:0] wgray,          // Source Gray code write pointer from wclk domain
input rst,                           // Reset
output reg [addressize:0] r_wptr2    // Synchronized Gray write pointer output in rclk domain
);

reg [addressize:0] r_wptr1;

// 2-Stage Flip-Flop Synchronizer Pipeline
always @(posedge rclk or posedge rst) begin
if (rst) begin
r_wptr1 <= 0;
r_wptr2 <= 0;
end else begin
r_wptr1 <= wgray;     // 1st Flip-Flop Stage (samples asynchronous input)
r_wptr2 <= r_wptr1;   // 2nd Flip-Flop Stage (outputs stable synchronized signal)
end
end

endmodule
