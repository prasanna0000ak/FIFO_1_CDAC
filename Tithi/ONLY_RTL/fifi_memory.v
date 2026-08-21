module fifi_memory #(
parameter datasize=8,
parameter addressize=4
)(input wclk,                                  // Write clock
 input  rclk,                                  // Read clock
 input  wen,                                   // Write enable
 input  ren,                                   // Read enable
 input [datasize-1:0]wdata,                   // Data to be written
 input [addressize-1:0] waddr,                // Write address
 input [addressize-1:0]raddr,                 // Read address
 output reg [datasize-1:0] rdata              // Data read from memory
 );
reg[datasize-1:0] mem[0:(2**addressize)-1]; // FIFO memory array
   
// Write data into memory when write enable is active
always @(posedge wclk)
begin
if(wen)
begin
mem[waddr] <= wdata;

end
end
    
// Read data from memory when read enable is active
    always@(posedge rclk)
    begin
    if(ren)
    begin
     rdata <= mem[raddr];
    end
    end
 
endmodule
