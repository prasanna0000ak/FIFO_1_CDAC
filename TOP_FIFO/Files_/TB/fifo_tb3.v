// PURPOSE: Testbench to verify First-Word Fall-Through (FWFT) 0-cycle show-ahead mode.
`timescale 1ns / 1ps

// EXPLANATION: Verifies 0-cycle latency show-ahead mode where rdata updates immediately with valid=1 without rinc.

module fifo_tb3;

// Signals
reg clk;
reg rst;
reg winc;
reg rinc;
reg [7:0] wdata;

wire [7:0] rdata;
wire wfull;
wire rempty;
wire valid;

// Instantiate FIFO with FWFT Mode ENABLED (ENABLE_FWFT = 1)
FIFOsyncasync_top #(
.WRITE_DATA_WIDTH(8),
.READ_DATA_WIDTH(8),
.MEM_DATA_WIDTH(8),
.ADDR_WIDTH(3),
.PROG_FULL_THRESH(2),
.PROG_EMPTY_THRESH(2),
.FIFO_MODE(0),         // Sync
.ENABLE_FWFT(1),       // FWFT MODE ENABLED
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
.valid(valid),
.ecc_single_err(),
.ecc_double_err()
);

always #5 clk = ~clk;

initial begin
clk = 0; rst = 1; winc = 0; rinc = 0; wdata = 8'h00;

$display("==================================================");
$display("   TESTBENCH 3: FIRST-WORD FALL-THROUGH (FWFT)    ");
$display("==================================================");

#20; rst = 0; #10;

// Write 1st word: 0xA1
@(posedge clk); #1;
winc = 1; wdata = 8'hA1;
$display("--> WRITE Data: 0x%02X", wdata);

// Write 2nd word: 0xB2
@(posedge clk); #1;
wdata = 8'hB2;
$display("--> WRITE Data: 0x%02X", wdata);

@(posedge clk); #1;
winc = 0;

// Wait 2 clock cycles for FWFT pre-fetch
repeat(2) @(posedge clk); #1;

// FWFT Check: rdata should show 0xA1 WITHOUT driving rinc=1!
$display("\n--- Checking FWFT Show-Ahead Behavior ---");
$display("<-- SHOW-AHEAD DATA = 0x%02X (valid = %b, rinc = %b)", rdata, valid, rinc);

if (rdata == 8'hA1 && valid == 1'b1) begin
$display(">> SUCCESS: FWFT mode presented 0xA1 immediately without requiring rinc!");
end else begin
$display(">> FAIL: FWFT failed to present first word.");
end

// Pop 1st word by driving rinc=1 for 1 cycle
$display("\n--- Popping 1st word ---");
@(posedge clk); #1; rinc = 1;
@(posedge clk); #1; rinc = 0;

repeat(2) @(posedge clk); #1;
$display("<-- NEXT SHOW-AHEAD DATA = 0x%02X (valid = %b)", rdata, valid);

if (rdata == 8'hB2) begin
$display(">> SUCCESS: FWFT updated to 2nd word (0xB2)!");
end

#20;
$display("==================================================");
$display("             TESTBENCH 3 COMPLETED                ");
$display("==================================================");
$finish;
end

endmodule
