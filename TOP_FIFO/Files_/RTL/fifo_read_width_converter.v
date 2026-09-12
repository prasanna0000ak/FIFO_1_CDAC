`timescale 1ns / 1ps

// EXPLANATION: Converts internal RAM memory data width (MEM_DATA_SIZE) into output bus width (READ_DATA_SIZE).
// If MEM_DATA_SIZE > READ_DATA_SIZE, it unpacks 1 wide memory word into multiple small output read words.

module fifo_read_width_converter #(
parameter READ_DATA_SIZE = 8,  // Output read bus data width
parameter MEM_DATA_SIZE  = 8   // Internal memory RAM data width
)(
input wire rclk,                          // Read clock
input wire rst,                           // Reset
input wire ren,                           // Read enable request
input wire [MEM_DATA_SIZE-1:0] mem_rdata, // Read data from memory RAM
output reg mem_ren,                       // Generated RAM read enable
output reg [READ_DATA_SIZE-1:0] rdata     // Converted output read data
);

generate
if (READ_DATA_SIZE == MEM_DATA_SIZE) begin : gen_direct
// Direct Pass-Through: When read width equals memory width
always @(*) begin
mem_ren = ren;
rdata = mem_rdata;
end
end else if (MEM_DATA_SIZE > READ_DATA_SIZE) begin : gen_unpack
// Wide RAM Word to Narrow Read Data: Unpacks 1 RAM word into multiple read words
localparam RATIO = MEM_DATA_SIZE / READ_DATA_SIZE;
localparam CNT_WIDTH = (RATIO > 1) ? $clog2(RATIO) : 1;

reg [CNT_WIDTH-1:0] sub_word_cnt;
reg [MEM_DATA_SIZE-1:0] output_reg;

always @(posedge rclk or posedge rst) begin
if (rst) begin
sub_word_cnt <= 0;
output_reg <= 0;
mem_ren <= 1'b0;
rdata <= 0;
end else begin
mem_ren <= 1'b0;
if (ren) begin
if (sub_word_cnt == 0) begin
output_reg <= mem_rdata;
rdata <= mem_rdata[READ_DATA_SIZE-1:0];
end else begin
rdata <= output_reg[sub_word_cnt * READ_DATA_SIZE +: READ_DATA_SIZE];
end

if (sub_word_cnt == RATIO - 1) begin
sub_word_cnt <= 0;
mem_ren <= 1'b1;
end else begin
sub_word_cnt <= sub_word_cnt + 1'b1;
end
end
end
end
end else begin : gen_pack


// Narrow RAM Word to Wide Read Data: Packs multiple RAM words into 1 wide read word
localparam RATIO = READ_DATA_SIZE / MEM_DATA_SIZE;
localparam CNT_WIDTH = (RATIO > 1) ? $clog2(RATIO) : 1;

reg [CNT_WIDTH-1:0] cnt;
reg [READ_DATA_SIZE-1:0] accum_reg;

always @(posedge rclk or posedge rst) begin
if (rst) begin
cnt <= 0;
accum_reg <= 0;
mem_ren <= 1'b0;
rdata <= 0;
end else begin
if (ren) begin
mem_ren <= 1'b1;
accum_reg[cnt * MEM_DATA_SIZE +: MEM_DATA_SIZE] <= mem_rdata;
if (cnt == RATIO - 1) begin
cnt <= 0;
rdata <= {mem_rdata, accum_reg[READ_DATA_SIZE - MEM_DATA_SIZE - 1 : 0]};
end else begin
cnt <= cnt + 1'b1;
end
end else begin
mem_ren <= 1'b0;
end
end
end
end
endgenerate

endmodule
