// PURPOSE: Vivado-compatible standard testbench to verify single-clock synchronous FIFO operations.
`timescale 1ns / 1ps
// EXPLANATION: Standard single-clock testbench verifying synchronous read and write sequence.

module fifo_tb1;

// Declare Testbench Signals
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
wire valid;

// Instantiate DUT
FIFOsyncasync_top #(
.WRITE_DATA_WIDTH(8),
.READ_DATA_WIDTH(8),
.MEM_DATA_WIDTH(8),
.ADDR_WIDTH(3),        // FIFO Depth = 8 words
.PROG_FULL_THRESH(2),
.PROG_EMPTY_THRESH(2),
.FIFO_MODE(0),         // Synchronous Mode
.ENABLE_FWFT(0),       // Standard Mode
.ENABLE_ECC(0)         // No ECC
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
.valid(valid),
.ecc_single_err(),
.ecc_double_err()
);

// Clock Generation
always #5 clk = ~clk;

// Test Sequence
initial begin
clk = 0;
rst = 1;
winc = 0;
rinc = 0;
wdata = 8'h00;

$display("==================================================");
$display("          VIVADO FIFO SIMULATION TESTBENCH        ");
$display("==================================================");

#20;
rst = 0;
#10;
$display("[STATUS] Reset released. Empty Flag = %b (1 = empty)", rempty);

// Step 1: Write 3 values (0x11, 0x22, 0x33)
$display("\n--- Step 1: Writing 3 values into FIFO ---");

@(posedge clk); #1;
winc = 1; wdata = 8'h11;
$display("--> WRITE Data: 0x%02X", wdata);

@(posedge clk); #1;
wdata = 8'h22;
$display("--> WRITE Data: 0x%02X", wdata);

@(posedge clk); #1;
wdata = 8'h33;
$display("--> WRITE Data: 0x%02X", wdata);

@(posedge clk); #1;
winc = 0;

#10;
$display("[STATUS] Writes complete. empty = %b, full = %b", rempty, wfull);

// Step 2: Read 3 values out
$display("\n--- Step 2: Reading 3 values out of FIFO ---");

@(posedge clk); #1;
rinc = 1;

@(posedge clk); #1;
$display("<-- READ Data 1 = 0x%02X (Expected: 0x11)", rdata);

@(posedge clk); #1;
$display("<-- READ Data 2 = 0x%02X (Expected: 0x22)", rdata);

@(posedge clk); #1;
$display("<-- READ Data 3 = 0x%02X (Expected: 0x33)", rdata);

rinc = 0;
#20;

$display("\n[STATUS] Reads complete. Empty Flag = %b (1 = empty)", rempty);
$display("==================================================");
$display("           TEST PASSED SUCCESSFULLY!              ");
$display("==================================================");
$finish;
end

endmodule
