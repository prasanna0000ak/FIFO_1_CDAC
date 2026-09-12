// PURPOSE: Testbench to verify Data Width Conversion (packing 8-bit writes into a 32-bit read).
`timescale 1ns / 1ps

// EXPLANATION: Verifies packing four 8-bit write words (0x11, 0x22, 0x33, 0x44) into one 32-bit read word (0x44332211).

module fifo_tb5;

// Signals
reg clk;
reg rst;
reg winc;
reg rinc;
reg [7:0] wdata;

wire [31:0] rdata;
wire wfull;
wire rempty;

// Instantiate FIFO with Width Conversion (Write 8-bit, Read 32-bit, Memory 32-bit)
FIFOsyncasync_top #(
.WRITE_DATA_WIDTH(8),  // 8-bit input bus
.READ_DATA_WIDTH(32),  // 32-bit output bus
.MEM_DATA_WIDTH(32),   // 32-bit RAM word
.ADDR_WIDTH(3),
.PROG_FULL_THRESH(2),
.PROG_EMPTY_THRESH(2),
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

initial begin
clk = 0; rst = 1; winc = 0; rinc = 0; wdata = 8'h00;

$display("==================================================");
$display("   TESTBENCH 5: DATA WIDTH CONVERSION (8->32 BIT)  ");
$display("==================================================");

#20; rst = 0; #10;

// Write 4 8-bit bytes
$display("\n--- Writing 4 8-bit bytes into FIFO ---");

@(posedge clk); #1; winc = 1; wdata = 8'h11; $display("  Write Byte 1: 0x%02X", wdata);
@(posedge clk); #1;           wdata = 8'h22; $display("  Write Byte 2: 0x%02X", wdata);
@(posedge clk); #1;           wdata = 8'h33; $display("  Write Byte 3: 0x%02X", wdata);
@(posedge clk); #1;           wdata = 8'h44; $display("  Write Byte 4: 0x%02X", wdata);

@(posedge clk); #1; winc = 0;

#20;

// Read 1 32-bit packed word
$display("\n--- Reading 1 32-bit word back from FIFO ---");
@(posedge clk); #1; rinc = 1;
@(posedge clk); #1;

$display("<-- READ 32-bit Word = 0x%08X (Expected: 0x44332211)", rdata);

if (rdata == 32'h44332211) begin
$display(">> SUCCESS: Width Converter successfully packed 4 bytes into 1 32-bit word!");
end else begin
$display(">> FAIL: Width conversion output mismatch!");
end

rinc = 0;
#20;

$display("==================================================");
$display("             TESTBENCH 5 COMPLETED                ");
$display("==================================================");
$finish;
end

endmodule
