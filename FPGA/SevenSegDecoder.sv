module sevenSegDecoder(
    input  logic [3:0] bin_in,   // 4-bit binary number (0 to 15)
    output logic [6:0] seg_out   // 7-bit output mapping to {g,f,e,d,c,b,a}
);

    always_comb begin
        case(bin_in)
            // 0 = ON, 1 = OFF (Assuming Active-Low Display)
            4'h0: seg_out = 7'b100_0000; // Displays 0
            4'h1: seg_out = 7'b111_1001; // Displays 1
            4'h2: seg_out = 7'b010_0100; // Displays 2
            4'h3: seg_out = 7'b011_0000; // Displays 3
            4'h4: seg_out = 7'b001_1001; // Displays 4
            4'h5: seg_out = 7'b001_0010; // Displays 5
            4'h6: seg_out = 7'b000_0010; // Displays 6
            4'h7: seg_out = 7'b111_1000; // Displays 7
            4'h8: seg_out = 7'b000_0000; // Displays 8
            4'h9: seg_out = 7'b001_0000; // Displays 9
            4'hA: seg_out = 7'b000_1000; // Displays A
            4'hB: seg_out = 7'b000_0011; // Displays b
            4'hC: seg_out = 7'b100_0110; // Displays C
            4'hD: seg_out = 7'b010_0001; // Displays d
            4'hE: seg_out = 7'b000_0110; // Displays E
            4'hF: seg_out = 7'b000_1110; // Displays F
            default: seg_out = 7'b111_1111; // All segments OFF
        endcase
    end

endmodule