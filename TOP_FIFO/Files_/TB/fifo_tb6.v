// PURPOSE: Testbench to verify Asynchronous Clock Domain Crossing (CDC) between 100MHz write and 71.4MHz read clocks.
`timescale 1ns / 1ps

// EXPLANATION: Verifies cross-domain data transfer between 100MHz Write Clock (wclk) and 71.4MHz Read Clock (rclk).

module fifo_tb6;

// Dual Clock Signals
reg wclk;
reg rclk;
reg rst;
reg winc;
reg rinc;
reg [7:0] wdata;

wire [7:0] rdata;
wire wfull;
wire rempty;

// Instantiate FIFO in Asynchronous Mode (FIFO_MODE = 1)
FIFOsyncasync_top #(
.WRITE_DATA_WIDTH(8),
.READ_DATA_WIDTH(8),
.MEM_DATA_WIDTH(8),
.ADDR_WIDTH(3),
.PROG_FULL_THRESH(2),
.PROG_EMPTY_THRESH(2),
.FIFO_MODE(1),         // ASYNCHRONOUS MODE ENABLED
.ENABLE_FWFT(0),
.ENABLE_ECC(0)
) dut (
.wclk(wclk),
.rclk(rclk),
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

// Write Clock Generator (100 MHz -> 10ns period)
initial begin
wclk = 0;
forever #5 wclk = ~wclk;
end

// Read Clock Generator (~71.4 MHz -> 14ns period)
initial begin
rclk = 0;
forever #7 rclk = ~rclk;
end

initial begin
rst = 1; winc = 0; rinc = 0; wdata = 8'h00;

$display("==================================================");
$display("   TESTBENCH 6: ASYNCHRONOUS CLOCK DOMAIN CROSS   ");
$display("==================================================");

#(10 * 3); rst = 0; #(10 * 2);

// Step 1: Write on wclk domain
$display("\n--- Step 1: Writing on 100MHz Write Clock ---");

@(posedge wclk); #1; winc = 1; wdata = 8'hD4; $display("[%0t ns] WRITE: 0x%02X", $time, wdata);
@(posedge wclk); #1;           wdata = 8'hE5; $display("[%0t ns] WRITE: 0x%02X", $time, wdata);

@(posedge wclk); #1; winc = 0;

// Step 2: Wait 4 rclk cycles for CDC Gray pointer synchronization
repeat(4) @(posedge rclk);

$display("\n--- Step 2: Reading on 71.4MHz Read Clock ---");

@(posedge rclk); #1; rinc = 1;
@(posedge rclk); #1; $display("[%0t ns] READ 1 = 0x%02X (Expected: 0xD4)", $time, rdata);
@(posedge rclk); #1; $display("[%0t ns] READ 2 = 0x%02X (Expected: 0xE5)", $time, rdata);

rinc = 0;
#(14 * 3);

$display("==================================================");
$display("             TESTBENCH 6 COMPLETED                ");
$display("==================================================");
$finish;
end

endmodule
