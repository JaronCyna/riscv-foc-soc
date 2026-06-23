module sw_imem(
    input logic [9:0] sw,
    
    output logic [31:0] inst
);

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] funct7;

    always_comb begin
        // Set up the blueprint for R-type register math
        opcode = 7'b0110011;  // Opcode for standard R-type ALU math
        funct3 = 3'b000;      // Both ADD and SUB use 3'b000
        rd     = 5'd16;       // Hardcode answer destination to x16    

        rs1 = {1'b0, sw[7:4]};
        rs2 = {1'b0, sw[3:0]};
        
        if (sw[8] == 1'b1) begin
            funct7 = 7'b0100000; // Switch up = SUBTRACT
        end else begin
            funct7 = 7'b0000000; // Switch down = ADD
        end

        inst = {funct7, rs2, rs1, funct3, rd, opcode};
    end
    

endmodule