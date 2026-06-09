module ALU_Sel_Decoder_tb;

    logic [1:0] ALUop;
    logic [2:0] funct3;
    logic       funct7_bit6;
    logic [3:0] ALU_sel;

    // UUT Instance
    ALU_Sel_Decoder uut (
        .ALUop(ALUop),
        .funct3(funct3),
        .funct7_bit6(funct7_bit6),
        .ALU_sel(ALU_sel)
    );

    initial begin
        $dumpfile("ALU_decode.vcd");
        $dumpvars(0, ALU_Sel_Decoder_tb);

        // Loop through all 64 possible input combinations
        for (int i = 0; i < 64; i++) begin
            
            // Apply inputs by slicing the loop counter
            {ALUop, funct3, funct7_bit6} = i[5:0];
            #1; 

            case (ALUop)
                2'd0: begin // Force ADD path
                    assert(ALU_sel === 4'd0) else $error("Fail ALUop 0: Got %d", ALU_sel);
                end

                2'd1: begin // Force SUB path
                    assert(ALU_sel === 4'd1) else $error("Fail ALUop 1: Got %d", ALU_sel);
                end

                2'd2: begin // R-Type Math Path
                    case (funct3)
                        3'b000:  assert(ALU_sel === (funct7_bit6 ? 4'd1 : 4'd0)) else $error("Fail R-type ADD/SUB");
                        3'b111:  assert(ALU_sel === 4'd2) else $error("Fail R-type AND");
                        3'b110:  assert(ALU_sel === 4'd3) else $error("Fail R-type OR");
                        3'b100:  assert(ALU_sel === 4'd4) else $error("Fail R-type XOR");
                        3'b001:  assert(ALU_sel === 4'd5) else $error("Fail R-type SLL");
                        3'b101:  assert(ALU_sel === (funct7_bit6 ? 4'd7 : 4'd6)) else $error("Fail R-type SRL/SRA");
                        3'b010:  assert(ALU_sel === 4'd8) else $error("Fail R-type SLT");
                        3'b011:  assert(ALU_sel === 4'd9) else $error("Fail R-type SLTU");
                        default: assert(ALU_sel === 4'd0) else $error("Fail R-type Default Latch Protection");
                    endcase
                end

                2'd3: begin // I-Type Math Path
                    case (funct3)
                        3'b000:  assert(ALU_sel === 4'd0) else $error("Fail I-type addi (Bit 30 trap)");
                        3'b111:  assert(ALU_sel === 4'd2) else $error("Fail I-type ANDI");
                        3'b110:  assert(ALU_sel === 4'd3) else $error("Fail I-type ORI");
                        3'b100:  assert(ALU_sel === 4'd4) else $error("Fail I-type XORI");
                        3'b001:  assert(ALU_sel === 4'd5) else $error("Fail I-type SLLI");
                        3'b101:  assert(ALU_sel === (funct7_bit6 ? 4'd7 : 4'd6)) else $error("Fail I-type SRLI/SRAI");
                        3'b010:  assert(ALU_sel === 4'd8) else $error("Fail I-type SLTI");
                        3'b011:  assert(ALU_sel === 4'd9) else $error("Fail I-type SLTIU");
                        default: assert(ALU_sel === 4'd0) else $error("Fail I-type Default Latch Protection");
                    endcase
                end
            endcase
        end

        $display("ALU Decoder Test Complete. If no errors were printed, it works");
        $finish;
    end
endmodule