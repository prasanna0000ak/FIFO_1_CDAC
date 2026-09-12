`timescale 1ns / 1ps

// EXPLANATION: Converts input write data width (WRITE_DATA_SIZE) into RAM data width (MEM_DATA_SIZE).
// If WRITE_DATA_SIZE < MEM_DATA_SIZE, it packs multiple small write words into one wide memory word.

module fifo_write_width_converter #(
parameter WRITE_DATA_SIZE = 8,  // Input write bus data width
parameter MEM_DATA_SIZE   = 8   // Internal memory RAM data width
)(
input wire wclk,                          // Write clock
input wire rst,                           // Reset
input wire wen,                           // Write enable request
input wire [WRITE_DATA_SIZE-1:0] wdata,   // Input data word
output reg mem_wen,                       // Generated RAM write enable
output reg [MEM_DATA_SIZE-1:0] mem_wdata  // Generated memory data word
);

generate
if (WRITE_DATA_SIZE == MEM_DATA_SIZE) begin : gen_direct

// Direct Pass-Through: When write data width equals memory width
always @(*) 

begin
mem_wen = wen;
mem_wdata = wdata;
end


end 

else if (WRITE_DATA_SIZE < MEM_DATA_SIZE) 

begin : gen_pack
// N:1 Packing Logic: Packs multiple small write words into one wide RAM word
localparam RATIO = MEM_DATA_SIZE / WRITE_DATA_SIZE;
localparam CNT_WIDTH = (RATIO > 1) ? $clog2(RATIO) : 1;

reg [CNT_WIDTH-1:0] sub_word_cnt;
reg [MEM_DATA_SIZE-1:0] input_buffer;

always @(posedge wclk or posedge rst) 

begin

if (rst) 
begin
sub_word_cnt <= 0;
input_buffer <= 0;
mem_wen <= 1'b0;
mem_wdata <= 0;
end 

else begin

mem_wen <= 1'b0;

if (wen) 
begin
input_buffer[sub_word_cnt * WRITE_DATA_SIZE +: WRITE_DATA_SIZE] <= wdata;

if (sub_word_cnt == RATIO - 1) 
begin
sub_word_cnt <= 0;
mem_wen <= 1'b1;
mem_wdata <= {wdata, input_buffer[MEM_DATA_SIZE - WRITE_DATA_SIZE - 1 : 0]};

end 

else
begin
sub_word_cnt <= sub_word_cnt + 1'b1;
end
end

end

end

end

else
begin : gen_unpack
// 1:N Unpacking Logic: Splits one wide write word into multiple small RAM writes
localparam RATIO = WRITE_DATA_SIZE / MEM_DATA_SIZE;
localparam CNT_WIDTH = (RATIO > 1) ? $clog2(RATIO) : 1;

reg [CNT_WIDTH-1:0] cnt;
reg [WRITE_DATA_SIZE-1:0] holding_reg;
reg busy;

always @(posedge wclk or posedge rst) 

begin

if (rst) 
begin
cnt <= 0;
holding_reg <= 0;
busy <= 0;
mem_wen <= 0;
mem_wdata <= 0;
end 

else begin

if (busy) 

begin
mem_wen <= 1'b1;
mem_wdata <= holding_reg[cnt * MEM_DATA_SIZE +: MEM_DATA_SIZE];

if (cnt == RATIO - 1)
begin
busy <= 1'b0;
cnt <= 0;
end 

else 

begin
cnt <= cnt + 1'b1;
end


end else

if (wen) 

begin
holding_reg <= wdata;
mem_wen <= 1'b1;
mem_wdata <= wdata[0 +: MEM_DATA_SIZE];

if (RATIO > 1) 
begin
busy <= 1'b1;
cnt <= 1;
end


end 

else 

begin
mem_wen <= 1'b0;
end

end

end
end

endgenerate
endmodule
