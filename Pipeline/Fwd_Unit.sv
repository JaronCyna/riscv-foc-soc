module Fwd_Unit(
    input logic [4:0] rs1_EX,
    input logic [4:0] rs2_EX,
    input logic [4:0] rw_MEM,
    input logic [4:0] rw_WB,
    input logic [1:0] control_bits_WB,
    input logic [1:0] control_bits_MEM,

    output logic [1:0] fwd1,
    output logic [1:0] fwd2
);

    always_comb begin
        if ((rw_MEM != 5'd0) && (rs1_EX == rw_MEM) && (control_bits_MEM[0] == 1)) begin
            fwd1 = 2'b10;
        end
        else if ((rw_WB != 5'd0) && (rs1_EX == rw_WB) && (control_bits_WB[0] == 1)) begin
            fwd1 = 2'b01;
        end
        else begin
            fwd1 = 2'b00;
        end
        
        if ((rw_MEM != 5'd0) && (rs2_EX == rw_MEM) && (control_bits_MEM[0] == 1)) begin
            fwd2 = 2'b10;
        end
        else if ((rw_WB != 5'd0) && (rs2_EX == rw_WB) && (control_bits_WB[0] == 1)) begin
            fwd2 = 2'b01;
        end
        else begin
            fwd2 = 2'b00;
        end
    end
endmodule