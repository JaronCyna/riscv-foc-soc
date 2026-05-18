module ImmGen(
    input logic  [31:0] inst,
    input logic  [2:0]  sel,
    output logic [31:0] imm_ext
);


    always @(*) begin
        
        case(sel)
            3'd0: imm_ext = 32'd0; // R-type

            // I-Type: Sign-extend 12 bits to 32 bits
            3'd1: imm_ext = {{20{inst[31]}}, inst[31:20]}; 

            // S-Type: Combine split 12-bit fields and sign-extend
            3'd2: imm_ext = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            // B-Type: Reconstructed 13-bit offset, bit 0 is forced to 0
            3'd3: imm_ext = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'd0};

            // U-Type: Place 20 bits at the top, pad lower 12 bits with 0s
            3'd4: imm_ext = {inst[31:12], 12'd0};

            // J-Type: Reconstructed 21-bit offset, bit 0 is forced to 0
            3'd5: imm_ext = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'd0}; // J-Type

            default: imm_ext = 32'd0; // R-type

        endcase


    end


endmodule
