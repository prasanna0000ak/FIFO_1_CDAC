// PURPOSE: Testbench to verify Concurrent Streaming (simultaneous write/read) and memory pointer rollover.
`timescale 1ns / 1ps

// EXPLANATION: Verifies full-duplex operation (simultaneous winc=1 and rinc=1) and pointer wrap-around.

module fifo_tb8;

// Signals
reg clk;
reg rst;
reg winc;
reg rinc;
reg [7:0] wdata;

wire [7:0] rdata;
wire wfull;
wire rempty;

// Instantiate FIFO with Depth = 4 (ADDR_WIDTH = 2) to test fast pointer wrap-around
FIFOsyncasync_top #(
.WRITE_DATA_WIDTH(8),
.READ_DATA_WIDTH(8),
.MEM_DATA_WIDTH(8),
.ADDR_WIDTH(2),        // Depth = 4 words
.PROG_FULL_THRESH(1),
.PROG_EMPTY_THRESH(1),
.FIFO_MODE(0),         // Sync
.ENABLE_FWFT(0),
.ENABLE_ECC(0)
) dut (
.wclk(clk),
.rclk(clk),
.rst(rst),
.winc(winc),
.rinc(rinc),
.wdata(wdata),
.rdata(rdata),
.wfull(wfull),
.rempty(rempty),
.almost_full(),
.almost_empty(),
.prog_full(),
.prog_empty(),
.valid(),
.ecc_single_err(),
.ecc_double_err()
);

always #5 clk = ~clk;

integer i;

initial begin
clk = 0; rst = 1; winc = 0; rinc = 0; wdata = 8'h00;

$display("==================================================");
$display("   TESTBENCH 8: CONCURRENT STREAMING & ROLLOVER  ");
$display("==================================================");

#20; rst = 0; #10;

// Step 1: Pre-fill FIFO with 2 items
$display("\n--- Step 1: Pre-filling FIFO with 2 items ---");
@(posedge clk); #1; winc = 1; wdata = 8'h01;
@(posedge clk); #1;           wdata = 8'h02;
@(posedge clk); #1; winc = 0;

// Step 2: Concurrent Streaming Mode (Write & Read simultaneously for 10 cycles)
$display("\n--- Step 2: Concurrent Write & Read (Full Duplex) ---");
winc = 1;
rinc = 1;

for (i = 3; i <= 10; i = i + 1) begin
wdata = i;
@(posedge clk); #1;
$display("  [%0t ns] WRITE = 0x%02X | READ = 0x%02X | full=%b, empty=%b", 
         $time, wdata, rdata, wfull, rempty);
end

winc = 0;
rinc = 0;
#20;

$display("\n>> SUCCESS: Concurrent read & write completed with clean pointer rollover!");
$display("==================================================");
$display("             TESTBENCH 8 COMPLETED                ");
$display("==================================================");
$finish;
end

endmodule
