`timescale 1ns / 1ps

// EXPLANATION: Main top-level module unifying all 7 processing stages of the FIFO architecture.
// Integrates Sync/Async mode, Data Width Converters, SECDED ECC, Dual-Port RAM, FWFT, and Status Flags.

module FIFOsyncasync_top #(
// Configurable System Parameters

parameter WRITE_DATA_WIDTH  = 8,  // Input write bus width
parameter READ_DATA_WIDTH   = 8,  // Output read bus width
parameter MEM_DATA_WIDTH    = 8,  // Internal memory RAM word width
parameter ADDR_WIDTH        = 4,  // RAM depth exponent (Depth = 2^ADDR_WIDTH)
parameter PROG_FULL_THRESH  = 3,  // Free space threshold for prog_full flag
parameter PROG_EMPTY_THRESH = 3,  // Word level threshold for prog_empty flag
parameter FIFO_MODE         = 0,  // 0 = Synchronous Mode, 1 = Asynchronous Mode
parameter ENABLE_FWFT       = 0,  // 0 = Standard Mode, 1 = FWFT Show-Ahead Mode
parameter ENABLE_ECC        = 0,  // 0 = ECC Disabled, 1 = SECDED ECC Enabled

// Legacy parameter aliases (kept for backward compatibility with old testbenches)
parameter datasize          = WRITE_DATA_WIDTH,
parameter addressize        = ADDR_WIDTH,
parameter prog_full_thresh  = PROG_FULL_THRESH,
parameter prog_empty_thresh = PROG_EMPTY_THRESH,
parameter FIFO_mode         = FIFO_MODE
)(
// Clock and Reset Signals
input  wire                         wclk,     // Write clock
input  wire                         rclk,     // Read clock
input  wire                         rst,      // Reset signal

// User Request Controls
input  wire                         winc,     // Write request enable
input  wire                         rinc,     // Read request enable

// Data Buses
input  wire [WRITE_DATA_WIDTH-1:0]  wdata,    // Input write data
output wire [READ_DATA_WIDTH-1:0]   rdata,    // Output read data

// Status Flags
output wire                         wfull,          // Full flag (1 = Full)
output wire                         rempty,         // Empty flag (1 = Empty)
output wire                         almost_full,    // Almost full flag (<=2 free spaces)
output wire                         almost_empty,   // Almost empty flag (<=2 words left)
output wire                         prog_full,      // Programmable full flag
output wire                         prog_empty,     // Programmable empty flag
output wire                         valid,          // Data valid flag for FWFT/read

// ECC Error Flags
output wire                         ecc_single_err, // Flag set to 1 if 1-bit error auto-corrected
output wire                         ecc_double_err  // Flag set to 1 if uncorrectable 2-bit error detected
);

// Effective Internal Parameter Constants (prevents parameter name conflicts)
localparam EFF_WWIDTH = WRITE_DATA_WIDTH;
localparam EFF_RWIDTH = READ_DATA_WIDTH;
localparam EFF_MWIDTH = MEM_DATA_WIDTH;
localparam EFF_AWIDTH = ADDR_WIDTH;
localparam EFF_MODE   = FIFO_MODE;
localparam EFF_FWFT   = ENABLE_FWFT;
localparam EFF_ECC    = ENABLE_ECC;
localparam EFF_PFULL  = PROG_FULL_THRESH;
localparam EFF_PEMPTY = PROG_EMPTY_THRESH;

// STAGE 1: Write Data Width Converter
wire conv_mem_wen;
wire [EFF_MWIDTH-1:0] conv_mem_wdata;

fifo_write_width_converter #(
.WRITE_DATA_SIZE(EFF_WWIDTH),
.MEM_DATA_SIZE(EFF_MWIDTH)
) u_w_conv (
.wclk(wclk),
.rst(rst),
.wen(winc && !wfull),
.wdata(wdata),
.mem_wen(conv_mem_wen),
.mem_wdata(conv_mem_wdata)
);

// STAGE 2: SECDED ECC Encoder
localparam RAM_DATA_WIDTH = (EFF_ECC == 1) ? 13 : EFF_MWIDTH;
wire [12:0] ecc_encoded_word;
wire [RAM_DATA_WIDTH-1:0] ram_wdata;

generate
if (EFF_ECC == 1) begin : gen_ecc_enc
encoder u_ecc_enc (
.data_in(conv_mem_wdata[7:0]),
.ecc_out(ecc_encoded_word)
);
assign ram_wdata = ecc_encoded_word;
end else begin : gen_no_ecc_enc
assign ram_wdata = conv_mem_wdata;
end
endgenerate

// STAGE 3: Pointer Controllers and CDC Synchronizers
wire [EFF_AWIDTH:0] wbin;
wire [EFF_AWIDTH:0] rbin;
wire [EFF_AWIDTH:0] wgray;
wire [EFF_AWIDTH:0] rgray;
wire [EFF_AWIDTH:0] w_rptr2;
wire [EFF_AWIDTH:0] r_wptr2;

wire ram_ren;
wire ram_wen;

assign ram_wen = conv_mem_wen && !wfull;

generate
if (EFF_MODE == 0) begin : SYNC_MODE
sync_fifo_write_pointer #(
.addressize(EFF_AWIDTH),
.prog_full_thresh(EFF_PFULL)
) u_sync_wptr (
.clk(wclk),
.rst(rst),
.winc(ram_wen),
.rbin_sync(rbin),
.wfull(wfull),
.almost_full(almost_full),
.prog_full(prog_full),
.wbin(wbin)
);

sync_fifo_read_pointer #(
.addressize(EFF_AWIDTH),
.prog_empty_thresh(EFF_PEMPTY)
) u_sync_rptr (
.clk(rclk),
.rst(rst),
.rinc(ram_ren),
.wbin_sync(wbin),
.rempty(rempty),
.almost_empty(almost_empty),
.prog_empty(prog_empty),
.rbin(rbin)
);
end else begin : ASYNC_MODE
async_fifo_write_pointer #(
.addressize(EFF_AWIDTH),
.prog_full_thresh(EFF_PFULL)
) u_async_wptr (
.wclk(wclk),
.winc(ram_wen),
.rst(rst),
.w_rptr2(w_rptr2),
.wbin(wbin),
.wgray(wgray),
.wfull(wfull),
.almost_full(almost_full),
.prog_full(prog_full)
);

async_fifo_read_pointer #(
.addressize(EFF_AWIDTH),
.prog_empty_thresh(EFF_PEMPTY)
) u_async_rptr (
.rclk(rclk),
.rst(rst),
.rinc(ram_ren),
.r_wptr2(r_wptr2),
.rbin(rbin),
.rgray(rgray),
.rempty(rempty),
.almost_empty(almost_empty),
.prog_empty(prog_empty)
);

async_rptr_sync_wd #(
.addressize(EFF_AWIDTH)
) u_sync_r2w (
.wclk(wclk),
.rgray(rgray),
.rst(rst),
.w_rptr2(w_rptr2)
);

async_wptr_sync_rd #(
.addressize(EFF_AWIDTH)
) u_sync_w2r (
.rclk(rclk),
.wgray(wgray),
.rst(rst),
.r_wptr2(r_wptr2)
);
end
endgenerate

// STAGE 4: Dual-Port Memory RAM Block
wire [RAM_DATA_WIDTH-1:0] ram_rdata;

fifo_memory #(
.datasize(RAM_DATA_WIDTH),
.addressize(EFF_AWIDTH)
) u_memory (
.wclk(wclk),
.rclk(rclk),
.wen(ram_wen),
.ren(ram_ren),
.wdata(ram_wdata),
.waddr(wbin[EFF_AWIDTH-1:0]),
.raddr(rbin[EFF_AWIDTH-1:0]),
.rdata(ram_rdata)
);

// STAGE 5: SECDED ECC Decoder
wire [EFF_MWIDTH-1:0] ecc_rdata;

generate
if (EFF_ECC == 1) begin : gen_ecc_dec
decoder u_ecc_dec (
.ecc_in(ram_rdata[12:0]),
.data_out(ecc_rdata[7:0]),
.single_err(ecc_single_err),
.double_err(ecc_double_err)
);
if (EFF_MWIDTH > 8) begin : gen_pad
assign ecc_rdata[EFF_MWIDTH-1:8] = 0;
end
end else begin : gen_no_ecc_dec
assign ecc_rdata      = ram_rdata;
assign ecc_single_err = 1'b0;
assign ecc_double_err = 1'b0;
end
endgenerate

// STAGE 6: Read Data Width Converter
wire conv_mem_ren;
wire [EFF_RWIDTH-1:0] conv_rdata;
wire ren_from_fwft;

fifo_read_width_converter #(
.READ_DATA_SIZE(EFF_RWIDTH),
.MEM_DATA_SIZE(EFF_MWIDTH)
) u_r_conv (
.rclk(rclk),
.rst(rst),
.ren(ren_from_fwft),
.mem_rdata(ecc_rdata),
.mem_ren(conv_mem_ren),
.rdata(conv_rdata)
);

assign ram_ren = conv_mem_ren;

// STAGE 7: First-Word Fall-Through (FWFT) Buffer
fwft #(
.read_datasize(EFF_RWIDTH)
) u_fwft (
.RCLK(rclk),
.RST(rst),
.REN(rinc),
.REMPTY(rempty),
.FWFT_enable(EFF_FWFT[0]),
.mem_rdata(conv_rdata),
.rdata(rdata),
.valid(valid),
.ren_fifo(ren_from_fwft)
);

endmodule
