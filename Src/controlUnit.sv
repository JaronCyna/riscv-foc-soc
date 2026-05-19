module ControlUnit(
    input logic [31:0] inst,
    
    output logic [2:0] ImmSel,
    output logic RegWrite,
    output logic ALUSrc,
    output logic [1:0] ALUop,
    output logic MemRead,
    output logic MemWrite,
    output logic MemtoReg,
    output logic Branch

);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic       funct7_bit6;

    assign opcode = inst[6:0];
    assign funct3 = inst[14:12];
    assign funct7_bit6 = inst[30];


    always @(*) begin
        
        case (opcode)
            7'h33: begin // R type
                ImmSel      = 3'd0; 
                RegWrite    = 1'd1;
                ALUSrc      = 1'd0;
                ALUop       = 2'd2;
                MemRead     = 1'd0;
                MemWrite    = 1'd0;
                MemtoReg    = 1'd0;
                Branch      = 1'd0;

            end
            7'h13, 7'h03, 7'h67: begin //I Type
                ImmSel      = 3'd1; 
                RegWrite    = 1'd1;
                ALUSrc      = 1'd1;
                MemWrite    = 1'd0;
                Branch      = 1'd0;

                if(opcode == 7'h03) begin
                    MemRead  = 1'd1;
                    MemtoReg = 1'd1;
                    ALUop    = 2'd0;
                end else if(opcode == 7'h67) begin
                    MemRead  = 1'd0;
                    MemtoReg = 1'dx;
                    ALUop    = 2'd0;
                end else begin
                    MemRead  = 1'd0;
                    MemtoReg = 1'd0; 
                    ALUop    = 2'd2;       
                end
                
                
            end

            7'h23: begin //S Type
                ImmSel      = 3'd2; 
                RegWrite    = 1'd0;
                ALUSrc      = 1'd1;
                ALUop       = 2'd00;
                MemRead     = 1'd0;
                MemWrite    = 1'd1;
                MemtoReg    = 1'dx;
                Branch      = 1'd0;

                
            end

            7'h63: begin //B Type
                ImmSel      = 3'd3; 
                RegWrite    = 1'd0;
                ALUSrc      = 1'd0;
                ALUop       = 2'd01;
                MemRead     = 1'd0;
                MemWrite    = 1'd0;
                MemtoReg    = 1'dx;
                Branch      = 1'd1;

            end

            7'h37, 7'h17: begin //U Type
                ImmSel      = 3'd4; 
                RegWrite    = 1'd1;
                ALUSrc      = 1'd1;
                ALUop       = 2'd00;
                MemRead     = 1'd0;
                MemWrite    = 1'd0;
                MemtoReg    = 1'd0;
                Branch      = 1'd0;

            end

            7'h6F: begin //J Type
                ImmSel      = 3'd5; 
                RegWrite    = 1'd1;
                ALUSrc      = 1'dx;
                ALUop       = 2'd00;
                MemRead     = 1'd0;
                MemWrite    = 1'd0;
                MemtoReg    = 1'd0;
                Branch      = 1'd0;

            end

            default: begin 
                ImmSel      = 3'd0;
                RegWrite    = 1'd0;
                ALUSrc      = 1'd0;
                ALUop       = 2'd00;
                MemRead     = 1'd0;
                MemWrite    = 1'd0;
                MemtoReg    = 1'd0;
                Branch      = 1'd0;


            end

        endcase
    
    end

endmodule