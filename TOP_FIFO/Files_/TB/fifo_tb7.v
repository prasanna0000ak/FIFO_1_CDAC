// PURPOSE: Testbench to verify Programmable Threshold Flags (almost_full, prog_full, almost_empty, prog_empty).
`timescale 1ns / 1ps

// EXPLANATION: Verifies status flags (almost_full, prog_full, almost_empty, prog_empty) as memory level changes.

module fifo_tb7;

// Signals
reg clk;
reg rst;
reg winc;
reg rinc;
reg [7:0] wdata;

wire [7:0] rdata;
wire wfull;
wire rempty;
wire almost_full;
wire almost_empty;
wire prog_full;
wire prog_empty;

// Instantiate FIFO with Depth = 8, PROG_FULL_THRESH = 3, PROG_EMPTY_THRESH = 3
FIFOsyncasync_top #(
.WRITE_DATA_WIDTH(8),
.READ_DATA_WIDTH(8),
.MEM_DATA_WIDTH(8),
.ADDR_WIDTH(3),        // Depth = 8 words
.PROG_FULL_THRESH(3),  // prog_full triggers when free space <= 3 (>= 5 words stored)
.PROG_EMPTY_THRESH(3), // prog_empty triggers when read level <= 3 items
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
.almost_full(almost_full),
.almost_empty(almost_empty),
.prog_full(prog_full),
.prog_empty(prog_empty),
.valid(),
.ecc_single_err(),
.ecc_double_err()
);

always #5 clk = ~clk;

initial begin
clk = 0; rst = 1; winc = 0; rinc = 0; wdata = 8'h00;

$display("==================================================");
$display("   TESTBENCH 7: PROGRAMMABLE THRESHOLD FLAGS     ");
$display("==================================================");

#20; rst = 0; #10;

$display("\n--- Step 1: Initial State (Empty FIFO) ---");
$display("  rempty=%b, almost_empty=%b, prog_empty=%b (All should be 1)", rempty, almost_empty, prog_empty);

// Fill FIFO word by word and observe flags
$display("\n--- Step 2: Filling FIFO Step-by-Step ---");

@(posedge clk); #1; winc = 1; wdata = 8'h10;
@(posedge clk); #1;           wdata = 8'h20;
@(posedge clk); #1;           wdata = 8'h30;
#1;
$display("  [3 Words Stored] prog_empty=%b (1 = <=3 words stored)", prog_empty);

@(posedge clk); #1;           wdata = 8'h40;
#1;
$display("  [4 Words Stored] prog_empty=%b (Deasserted to 0)", prog_empty);

@(posedge clk); #1;           wdata = 8'h50;
#1;
$display("  [5 Words Stored] prog_full=%b (1 = <=3 spaces left)", prog_full);

@(posedge clk); #1;           wdata = 8'h60;
#1;
$display("  [6 Words Stored] almost_full=%b (1 = <=2 spaces left)", almost_full);

@(posedge clk); #1;           wdata = 8'h70;
@(posedge clk); #1;           wdata = 8'h80;
@(posedge clk); #1; winc = 0;
#1;
$display("  [8 Words Stored] wfull=%b (1 = Full)", wfull);

$display("\n--- Step 3: Draining FIFO Step-by-Step ---");
@(posedge clk); #1; rinc = 1;

repeat(6) @(posedge clk);
#1;
$display("  [After Reads] rempty=%b, wfull=%b, prog_empty=%b", rempty, wfull, prog_empty);

rinc = 0;
#20;

$display("==================================================");
$display("             TESTBENCH 7 COMPLETED                ");
$display("==================================================");
$finish;
end

endmodule
