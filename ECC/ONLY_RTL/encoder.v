`timescale 1ns / 1ps

module encoder(
    input  [7:0]  data_in,      // Raw user data
    output [12:0] ecc_out       // Encoded word for memory storage
);

    // Bit mapping:
    // [0]=P1, [1]=P2, [2]=D1, [3]=P4, [4]=D2, [5]=D3, [6]=D4, 
    // [7]=P8, [8]=D5, [9]=D6, [10]=D7, [11]=D8, [12]=Pall

    wire p1 = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[6];
    wire p2 = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6];
    wire p4 = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7];
    wire p8 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

    wire p_all = p1 ^ p2 ^ data_in[0] ^ p4 ^ data_in[1] ^ data_in[2] ^ 
                 data_in[3] ^ p8 ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

    assign ecc_out = {p_all, data_in[7:4], p8, data_in[3:1], p4, data_in[0], p2, p1};

endmodule