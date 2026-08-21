`timescale 1ns / 1ps

module decoder(
    input      [12:0] ecc_in,     
    output reg [7:0]  data_out,     
    output reg        single_err,    
    output reg        double_err     
);

    wire p1    = ecc_in[0];
    wire p2    = ecc_in[1];
    wire d1    = ecc_in[2];
    wire p4    = ecc_in[3];
    wire d2    = ecc_in[4];
    wire d3    = ecc_in[5];
    wire d4    = ecc_in[6];
    wire p8    = ecc_in[7];
    wire d5    = ecc_in[8];
    wire d6    = ecc_in[9];
    wire d7    = ecc_in[10];
    wire d8    = ecc_in[11];
    wire p_all = ecc_in[12];

    // Compute Syndrome Vector S = {s8, s4, s2, s1}
    wire s1 = p1 ^ d1 ^ d2 ^ d4 ^ d5 ^ d7;
    wire s2 = p2 ^ d1 ^ d3 ^ d4 ^ d6 ^ d7;
    wire s4 = p4 ^ d2 ^ d3 ^ d4 ^ d8;
    wire s8 = p8 ^ d5 ^ d6 ^ d7 ^ d8;
    wire [3:0] syndrome = {s8, s4, s2, s1};

    wire overall_parity = ^ecc_in;

    always @(*) begin
        // Default clean assignment
        data_out   = {d8, d7, d6, d5, d4, d3, d2, d1};
        single_err = 1'b0;
        double_err = 1'b0;

        if (syndrome == 4'b0000) begin
            if (overall_parity == 1'b1) begin
                single_err = 1'b1; 
            end
        end else begin
            if (overall_parity == 1'b1) begin
                single_err = 1'b1; 
                case (syndrome)
                    4'd3:  data_out[0] = ~d1;
                    4'd5:  data_out[1] = ~d2;
                    4'd6:  data_out[2] = ~d3;
                    4'd7:  data_out[3] = ~d4;
                    4'd9:  data_out[4] = ~d5;
                    4'd10: data_out[5] = ~d6;
                    4'd11: data_out[6] = ~d7;
                    4'd12: data_out[7] = ~d8;
                    default: data_out = {d8, d7, d6, d5, d4, d3, d2, d1};
                endcase
            end else begin
                double_err = 1'b1; 
            end
        end
    end

endmodule
