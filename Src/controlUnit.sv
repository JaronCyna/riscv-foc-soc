module ControlUnit(
    input logic [31:0] inst,
    
    output logic [2:0] ImmSel,
    output logic RegWrite,
    output logic ALUSrc,
    output logic [1:0] ALUop,
    output logic MemRead,
    output logic MemWrite,
    output logic MemtoReg,
    output logic Branch,
    output logic [2:0] funct3,
    output logic       funct7_bit6
);

    logic [6:0] opcode;

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


module ALU_Sel_Decoder(
    input logic [1:0] ALUop,
    input logic [2:0] funct3,
    input logic       funct7_bit6,

    output logic [3:0] ALU_sel
);


    always @(*) begin
        case(ALUop)
          
            2'd0: ALU_sel = 4'd0;
            2'd1: ALU_sel = 4'd1;
            2'd2, 2'd3: begin
                
                case(funct3)
                    
                    3'b000: begin
                            if(funct7_bit6 == 1'd1 && ALUop == 2'd2) ALU_sel = 4'd1; //Ensure It is R-Type to prevent I type subtraction
                            else ALU_sel = 4'd0;
                            end
                    3'b111: ALU_sel = 4'd2;
                    3'b110: ALU_sel = 4'd3;
                    3'b100: ALU_sel = 4'd4;
                    3'b001: ALU_sel = 4'd5;
                    3'b101: begin   
                            if(funct7_bit6 == 1'd1) ALU_sel = 4'd7;
                            else ALU_sel = 4'd6;
                            end
                    3'b010: ALU_sel = 4'd8;
                    3'b011: ALU_sel = 4'd9;

                    default: ALU_sel = 4'd0;
                endcase

            end
            
            default: ALU_sel = 4'd0;

        endcase

    end

endmodule