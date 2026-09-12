`timescale 1ns / 1ps

// EXPLANATION: 2-Stage D-Flip-Flop synchronizer passing Read Gray Pointer (rgray)
// across clock domains into Write Clock Domain (wclk) to prevent metastability.

module async_rptr_sync_wd #(
parameter addressize = 4  // Address bit width
)(
input wclk,                          // Destination Write clock
input [addressize:0] rgray,          // Source Gray code read pointer from rclk domain
input rst,                           // Reset
output reg [addressize:0] w_rptr2    // Synchronized Gray read pointer output in wclk domain
);

reg [addressize:0] w_rptr1;

// 2-Stage Flip-Flop Synchronizer Pipeline
always @(posedge wclk or posedge rst) begin
if (rst) begin
w_rptr1 <= 0;
w_rptr2 <= 0;
end else begin
w_rptr1 <= rgray;     // 1st Flip-Flop Stage (samples asynchronous input)
w_rptr2 <= w_rptr1;   // 2nd Flip-Flop Stage (outputs stable synchronized signal)
end
end

endmodule
