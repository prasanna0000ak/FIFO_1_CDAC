`timescale 1ns / 1ps

module fifo_write_width_converter #(
parameter WRITE_DATA_SIZE = 8,
parameter MEM_DATA_SIZE   = 32
)(
input   wclk,
input   rst,
input  wen,
input  [WRITE_DATA_SIZE-1:0] wdata,
output reg mem_wen,
output [MEM_DATA_SIZE-1:0] mem_wdata
);

localparam RATIO = MEM_DATA_SIZE / WRITE_DATA_SIZE;
localparam CNT_WIDTH = (RATIO > 1) ? $clog2(RATIO) : 1;

generate
if (RATIO == 1) begin : gen_direct_write
always @(*) begin
mem_wen   = wen;
end
assign mem_wdata = wdata;
            
end else begin : gen_pack_write
reg [CNT_WIDTH-1:0]       sub_word_cnt;
reg [MEM_DATA_SIZE-1:0]   input_buffer;

always @(posedge wclk or posedge rst) begin
if (rst) begin
sub_word_cnt <= 0;
input_buffer <= 0;
mem_wen      <= 1'b0;
end else begin
mem_wen <= 1'b0;
                    
if (wen) begin
input_buffer[sub_word_cnt * WRITE_DATA_SIZE +: WRITE_DATA_SIZE] <= wdata;
                        
if (sub_word_cnt == RATIO - 1) begin
sub_word_cnt <= 0;
mem_wen      <= 1'b1;
end else begin
sub_word_cnt <= sub_word_cnt + 1'b1;
end
end
end
end

assign mem_wdata = (sub_word_cnt == RATIO - 1) ? 
{wdata, input_buffer[MEM_DATA_SIZE - WRITE_DATA_SIZE - 1 : 0]} : 
input_buffer;
end
endgenerate

endmodule

