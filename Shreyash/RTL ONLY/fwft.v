`timescale 1ns / 1ps

module fwft #(parameter read_datasize = 8)

(
input wire RCLK,
input wire RST,
input wire REN,
input wire REMPTY,
input wire FWFT_enable,
input wire [read_datasize-1:0] mem_rdata,

output wire [read_datasize-1:0] rdata,
output wire valid,
output wire ren_fifo

);

reg [read_datasize-1:0] rdata_buf;
reg valid_reg;
reg pending;

wire ren_fifo_fwft;

assign ren_fifo_fwft = (!valid_reg && !REMPTY && !pending) || ( valid_reg && REN && !REMPTY && !pending);
assign ren_fifo = FWFT_enable ? ren_fifo_fwft : (REN && !REMPTY);


always @(posedge RCLK or posedge RST)

begin

if (RST)
begin
rdata_buf <= 0;
valid_reg <= 1'b0;
pending <= 1'b0;
end

else

begin

if (FWFT_enable)
begin

if (pending)
begin
rdata_buf <= mem_rdata;
valid_reg <= 1'b1;
pending <= 1'b0;
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
pending <= 1'b0;
end



end
end

assign rdata = FWFT_enable ? rdata_buf : 0;

assign valid = FWFT_enable ? valid_reg :
(REN && !REMPTY);

endmodule