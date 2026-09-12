`timescale 1ns / 1ps

// EXPLANATION: Creates dual-port RAM memory to store data words. Writes on wclk and reads on rclk.

module fifo_memory #(
parameter datasize=8,    // Bit width of stored data word
parameter addressize=4   // Bit width of memory address (Depth = 2^addressize)
)(
input wclk,                         // Write domain clock
input rclk,                         // Read domain clock
input wen,                          // Write enable signal
input ren,                          // Read enable signal
input [datasize-1:0] wdata,         // Write data word input
input [addressize-1:0] waddr,       // Write address pointer
input [addressize-1:0] raddr,       // Read address pointer
output reg [datasize-1:0] rdata     // Read data register output
);

// Memory Array storage definition: 2^addressize locations of datasize width
reg[datasize-1:0] mem[0:(2**addressize)-1];

// Write Process: Executes write into memory location waddr on posedge wclk
always @(posedge wclk)
begin
if(wen)
begin
mem[waddr] <= wdata;
end
end

// Read Process: Executes read from memory location raddr on posedge rclk
always @(posedge rclk)
begin
if(ren)
begin
rdata <= mem[raddr];
end
end

endmodule
