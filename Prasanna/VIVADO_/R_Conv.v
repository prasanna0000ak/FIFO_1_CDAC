`timescale 1ns / 1ps

module fifo_read_width_converter #(
parameter READ_DATA_SIZE = 8,
parameter MEM_DATA_SIZE  = 32
)(
input                              rclk,
input                              rst,
input                              ren,
input      [MEM_DATA_SIZE-1:0]     mem_rdata,
output reg                         mem_ren,
output     [READ_DATA_SIZE-1:0]    rdata
);

localparam RATIO = MEM_DATA_SIZE / READ_DATA_SIZE;
localparam CNT_WIDTH = (RATIO > 1) ? $clog2(RATIO) : 1;

generate
if (RATIO == 1) begin : gen_direct_read
always @(*) begin
mem_ren = ren;
end
assign rdata = mem_rdata[READ_DATA_SIZE-1:0];

end else begin : gen_unpack_read
reg [CNT_WIDTH-1:0]       sub_word_cnt;
reg [MEM_DATA_SIZE-1:0]   output_reg;

always @(posedge rclk or posedge rst) begin
if (rst) begin
sub_word_cnt <= 0;
output_reg   <= 0;
mem_ren      <= 1'b0;
end else begin
mem_ren <= 1'b0;
                    
if (ren) begin
if (sub_word_cnt == 0) begin
output_reg <= mem_rdata;
end
                        
if (sub_word_cnt == RATIO - 1) begin
sub_word_cnt <= 0;
mem_ren      <= 1'b1;
end else begin
sub_word_cnt <= sub_word_cnt + 1'b1;
end
end
end
end

assign rdata = (sub_word_cnt == 0) ? 
mem_rdata[READ_DATA_SIZE-1:0] : 
output_reg[sub_word_cnt * READ_DATA_SIZE +: READ_DATA_SIZE];
end
endgenerate

endmodule

