`timescale 1ns / 1ps


module tb_fifo_width_converters;

localparam WRITE_DATA_SIZE = 8;
localparam MEM_DATA_SIZE   = 32;
localparam READ_DATA_SIZE  = 8;

reg clk;
reg rst;
reg wen;
reg [WRITE_DATA_SIZE-1:0]wdata;

wire mem_wen;
wire [MEM_DATA_SIZE-1:0]mem_wdata;

reg ren;
reg [MEM_DATA_SIZE-1:0]mem_rdata;

wire mem_ren;
wire [READ_DATA_SIZE-1:0]rdata;
	
	
fifo_write_width_converter #( .WRITE_DATA_SIZE(WRITE_DATA_SIZE) , .MEM_DATA_SIZE(MEM_DATA_SIZE) ) 

u_write_conv(
.wclk(clk),
.rst(rst),
.wen(wen),
.wdata(wdata),
.mem_wen(mem_wen),
.mem_wdata(mem_wdata)
);
	
	
fifo_read_width_converter #(.READ_DATA_SIZE(READ_DATA_SIZE),.MEM_DATA_SIZE (MEM_DATA_SIZE)) 

u_read_conv(
.rclk(clk),
.rst(rst),
.ren(ren),
.mem_rdata(mem_rdata),
.mem_ren(mem_ren),
.rdata(rdata)
);
	
	
always #5 clk = ~clk;

initial begin

clk       = 0;
rst       = 1;
wen       = 0;
wdata     = 8'h00;
ren       = 0;
mem_rdata = 32'h00000000;

#20;


@(posedge clk);

rst = 0;
#10;

$display("\n--- Starting Write Converter Test (Packing) ---");

@(posedge clk);
wen = 1; wdata = 8'h11;

@(posedge clk);
wen = 1; wdata = 8'h22;

@(posedge clk);
wen = 1; wdata = 8'h33;

@(posedge clk);
 wen = 1; wdata = 8'h44;
 
@(posedge clk);
wen = 0;
wdata = 8'h00;
$display("\n--- Starting Read Converter Test (Unpacking) ---");

mem_rdata = 32'hAABBCCDD; 



@(posedge clk);
ren = 1;
@(posedge clk);
ren = 1;
@(posedge clk);
ren = 1;
@(posedge clk);
ren = 1;
@(posedge clk);

ren = 0;
#30;

$display("\n--- Test Complete ---");
$finish;

end



always @(posedge clk) begin
if (mem_wen) begin
$display("[WRITE CONV] Packed 32-bit output mem_wdata = 0x%08X (mem_wen = %b)", mem_wdata, mem_wen);
end
if (ren) begin
$display("[READ CONV]  Unpacked 8-bit output rdata = 0x%02X (mem_ren = %b)", rdata, mem_ren);
end
end
endmodule

