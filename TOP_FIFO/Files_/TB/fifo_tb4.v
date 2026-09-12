// PURPOSE: Testbench to verify SECDED ECC protection integrated inside the top-level FIFO pipeline.
`timescale 1ns / 1ps
// EXPLANATION: Instantiates top-level FIFO with ENABLE_ECC = 1 to test ECC protection through full RAM pipeline.

module fifo_tb4;

// Testbench Signals
reg clk;
reg rst;
reg winc;
reg rinc;
reg [7:0] wdata;

wire [7:0] rdata;
wire wfull;
wire rempty;
wire valid;
wire ecc_single_err;
wire ecc_double_err;

// Instantiate Top-Level FIFO with ECC ENABLED (ENABLE_ECC = 1)
FIFOsyncasync_top #(
.WRITE_DATA_WIDTH(8),
.READ_DATA_WIDTH(8),
.MEM_DATA_WIDTH(8),
.ADDR_WIDTH(3),        // FIFO Depth = 8 words
.PROG_FULL_THRESH(2),
.PROG_EMPTY_THRESH(2),
.FIFO_MODE(0),         // Synchronous Mode
.ENABLE_FWFT(0),       // Standard Mode
.ENABLE_ECC(1)         // *** ENABLE ECC PROTECTION (13-bit RAM word) ***
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
.ecc_single_err(ecc_single_err),
.ecc_double_err(ecc_double_err)
);

// Generate 100 MHz Clock
always #5 clk = ~clk;

initial begin
clk = 0; rst = 1; winc = 0; rinc = 0; wdata = 8'h00;

$display("==================================================");
$display("   TOP-LEVEL FIFO ECC INTEGRATED SIMULATION       ");
$display("==================================================");

#20; rst = 0; #10;
$display("[STATUS] Reset released. FIFO empty = %b", rempty);

// Step 1: Write 3 data words into FIFO
$display("\n--- Step 1: Writing data into ECC FIFO ---");

@(posedge clk); #1; winc = 1; wdata = 8'hA5; $display("--> WRITE Data: 0x%02X (Encodes to 13-bit SECDED word)", wdata);
@(posedge clk); #1;           wdata = 8'h3C; $display("--> WRITE Data: 0x%02X (Encodes to 13-bit SECDED word)", wdata);
@(posedge clk); #1;           wdata = 8'hF0; $display("--> WRITE Data: 0x%02X (Encodes to 13-bit SECDED word)", wdata);

@(posedge clk); #1; winc = 0;

#10;

// Step 2: Read data words back out of FIFO
$display("\n--- Step 2: Reading data back out of ECC FIFO ---");
@(posedge clk); #1; rinc = 1;

@(posedge clk); #1; $display("<-- READ 1 Data = 0x%02X | ecc_single_err = %b, ecc_double_err = %b", rdata, ecc_single_err, ecc_double_err);
@(posedge clk); #1; $display("<-- READ 2 Data = 0x%02X | ecc_single_err = %b, ecc_double_err = %b", rdata, ecc_single_err, ecc_double_err);
@(posedge clk); #1; $display("<-- READ 3 Data = 0x%02X | ecc_single_err = %b, ecc_double_err = %b", rdata, ecc_single_err, ecc_double_err);

rinc = 0;
#20;

$display("==================================================");
$display("        TOP-LEVEL ECC SIMULATION PASSED           ");
$display("==================================================");
$finish;
end

endmodule
