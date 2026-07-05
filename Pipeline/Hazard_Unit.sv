module Hazard_Unit(
    input logic [4:0] rw_EX,
    input logic [4:0] rs1_ID,
    input logic [4:0] rs2_ID,
    input logic MemRead_EX,
    
    output logic PCWrite,
    output logic IF_IDWrite,
    output logic bubble
);

    always_comb begin
        
        if((MemRead_EX == 1)  && (rw_EX !=0) && ((rw_EX == rs1_ID) || (rw_EX == rs2_ID))) begin
            PCWrite = 0;
            IF_IDWrite = 0;
            bubble = 1;
        end
        else begin
            PCWrite = 1;
            IF_IDWrite = 1;
            bubble = 0;
        end

    end


endmodule