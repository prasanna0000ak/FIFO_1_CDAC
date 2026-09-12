`timescale 1ns / 1ps

// EXPLANATION: Converts standard 1-cycle read latency RAM into 0-cycle latency show-ahead mode.
// Pre-fetches head data into rdata_buf so data is available on rdata immediately when non-empty.

module fwft #(
parameter read_datasize = 8  // Bit width of read data bus
)(
input wire RCLK,                           // Read clock
input wire RST,                            // Reset
input wire REN,                            // User read enable request
input wire REMPTY,                         // Empty flag from read pointer
input wire FWFT_enable,                    // 1 = FWFT enabled, 0 = Standard mode
input wire [read_datasize-1:0] mem_rdata,  // Read data from memory RAM/converter

output wire [read_datasize-1:0] rdata,     // Converted output read data
output wire valid,                         // Output data valid flag
output wire ren_fifo                       // Generated read enable signal to memory RAM/pointer
);

reg [read_datasize-1:0] rdata_buf;
reg valid_reg;
reg pending;

wire ren_fifo_fwft;

// Generate pre-fetch read request when buffer is empty or when user reads current word
assign ren_fifo_fwft = (!valid_reg && !REMPTY && !pending) || (valid_reg && REN && !REMPTY && !pending);
assign ren_fifo = FWFT_enable ? ren_fifo_fwft : (REN && !REMPTY);

always @(posedge RCLK or posedge RST)  
begin
if (RST)  
begin
rdata_buf <= 0;
valid_reg <= 1'b0;
pending   <= 1'b0;
end  
else if (FWFT_enable)  
begin
if (pending)  
begin
rdata_buf <= mem_rdata;
valid_reg <= 1'b1;
pending   <= 1'b0;
end  
else if (REN && valid_reg)  
begin
valid_reg <= 1'b0;
end

if (ren_fifo_fwft)
begin
pending <= 1'b1;
end
end  
else  
begin
rdata_buf <= 0;
valid_reg <= 1'b0;
pending   <= 1'b0;
end
end

assign rdata = FWFT_enable ? rdata_buf : mem_rdata;
assign valid = FWFT_enable ? valid_reg : (REN && !REMPTY);

endmodule
