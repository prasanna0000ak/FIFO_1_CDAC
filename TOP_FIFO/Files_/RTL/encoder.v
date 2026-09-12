`timescale 1ns / 1ps

// EXPLANATION: Encodes an 8-bit input data byte into a 13-bit SECDED (Single Error Correction, Double Error Detection) Hamming codeword.
// Generates 4 Hamming parity bits (P1, P2, P4, P8) and 1 overall parity bit (P_all) to protect data stored in RAM.

module encoder(
input [7:0] data_in,      // 8-bit user input data byte
output [12:0] ecc_out     // 13-bit encoded word stored into memory RAM
);

// Bit mapping in 13-bit word:
// [0]=P1, [1]=P2, [2]=D1, [3]=P4, [4]=D2, [5]=D3, [6]=D4, 
// [7]=P8, [8]=D5, [9]=D6, [10]=D7, [11]=D8, [12]=P_all

// Compute parity bits using XOR logic across bit position sets
wire p1 = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[6];
wire p2 = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6];
wire p4 = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7];
wire p8 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

// Compute overall parity bit P_all over all data and parity bits
wire p_all = p1 ^ p2 ^ data_in[0] ^ p4 ^ data_in[1] ^ data_in[2] ^ 
             data_in[3] ^ p8 ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

// Concatenate parity bits and data bits into 13-bit output word
assign ecc_out = {p_all, data_in[7:4], p8, data_in[3:1], p4, data_in[0], p2, p1};

endmodule
