`timescale 1ns / 1ps

module ecc_tb;

    // Testbench Signals
    reg  [7:0]  data_in;
    wire [12:0] ecc_encoded;
    
    reg  [12:0] ecc_corrupted;
    wire [7:0]  data_out;
    wire        single_err;
    wire        double_err;

    // Instantiate Encoder (Write Path)
    encoder u_encoder (
        .data_in (data_in),
        .ecc_out (ecc_encoded)
    );

    // Instantiate Decoder (Read Path)
    decoder u_decoder (
        .ecc_in     (ecc_corrupted),
        .data_out   (data_out),
        .single_err (single_err),
        .double_err (double_err)
    );

    initial begin
        $display("---------------------------------------------------------------");
        $display("          STARTING SECDED ECC VERIFICATION TESTBENCH          ");
        $display("---------------------------------------------------------------");

        // -------------------------------------------------------------
        // TEST 1: Clean Transmission (No Errors Injected)
        // -------------------------------------------------------------
        data_in = 8'hA5; // Original Data: 10100101
        #10;
        ecc_corrupted = ecc_encoded; // No corruption
        #10;
        $display("[TEST 1: NO ERROR]");
        $display("  Input Data     : 0x%02X", data_in);
        $display("  Encoded Codeword: %013b", ecc_encoded);
        $display("  Output Data    : 0x%02X", data_out);
        $display("  Flags          : single_err = %b, double_err = %b", single_err, double_err);
        if (data_out == data_in && !single_err && !double_err) 
            $display("  >> PASS: Clean data received perfectly.\n");
        else 
            $display("  >> FAIL: Unexpected error flag.\n");

        // -------------------------------------------------------------
        // TEST 2: Single-Bit Data Error (Should be detected & corrected)
        // -------------------------------------------------------------
        data_in = 8'h3C; // Original Data: 00111100
        #10;
        // Inject single-bit error by flipping bit position 5 (D2)
        ecc_corrupted = ecc_encoded ^ (13'b0000000010000);
        #10;
        $display("[TEST 2: SINGLE-BIT ERROR]");
        $display("  Input Data     : 0x%02X", data_in);
        $display("  Corrupted Word : %013b (Bit 4 flipped)", ecc_corrupted);
        $display("  Corrected Data : 0x%02X", data_out);
        $display("  Flags          : single_err = %b, double_err = %b", single_err, double_err);
        if (data_out == data_in && single_err && !double_err) 
            $display("  >> PASS: Single-bit error successfully fixed.\n");
        else 
            $display("  >> FAIL: Error not corrected properly.\n");

        // -------------------------------------------------------------
        // TEST 3: Double-Bit Error (Uncorrectable, must flag double_err)
        // -------------------------------------------------------------
        data_in = 8'hF0; // Original Data: 11110000
        #10;
        // Inject two-bit errors by flipping bit 2 (D1) and bit 8 (D5)
        ecc_corrupted = ecc_encoded ^ (13'b0000100000100);
        #10;
        $display("[TEST 3: DOUBLE-BIT ERROR]");
        $display("  Input Data     : 0x%02X", data_in);
        $display("  Corrupted Word : %013b (Two bits flipped)", ecc_corrupted);
        $display("  Flags          : single_err = %b, double_err = %b", single_err, double_err);
        if (double_err && !single_err) 
            $display("  >> PASS: Double-bit uncorrectable fault successfully flagged.\n");
        else 
            $display("  >> FAIL: Double-bit error detection missed.\n");

        $display("---------------------------------------------------------------");
        $display("                     ALL TESTS COMPLETED                      ");
        $display("---------------------------------------------------------------");
        $finish;
    end

endmodule