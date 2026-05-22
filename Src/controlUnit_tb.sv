// Using Constrained Random Verification (CRV) to test multiple inputs and confirm functionality 
class InstRand;
    rand logic [31:0] full_inst; 
    logic [6:0] target_opcode;  

    constraint lock_opcode {
        full_inst[6:0] == target_opcode;
    }
endclass



module ControlUnit_tb;


    logic [31:0] inst;
    logic [2:0] ImmSel;
    logic       RegWrite;
    logic       ALUSrc;
    logic [1:0] ALUop;
    logic       MemRead;
    logic       MemWrite;
    logic       MemtoReg;
    logic       Branch;
    logic [2:0] funct3;
    logic       funct7_bit6;



    ControlUnit ctrl_test(
                            .inst(inst),

                            .ImmSel(ImmSel),
                            .RegWrite(RegWrite),
                            .ALUSrc(ALUSrc),
                            .ALUop(ALUop),
                            .MemRead(MemRead),
                            .MemWrite(MemWrite),
                            .MemtoReg(MemtoReg),
                            .Branch(Branch),
                            .funct3(funct3),
                            .funct7_bit6(funct7_bit6)
                            );

    InstRand instRandom;

    initial begin
        $dumpfile("CtrlUnit.vcd");
        $dumpvars(0, ControlUnit_tb);

        instRandom = new();
       
        // Test 1 R-type
        instRandom.target_opcode = 7'h33;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd0 || RegWrite !== 1'd1 || ALUSrc !== 1'd0 || 
                ALUop !== 2'd2 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, R-Type Works");
        end


        // Test 2 I-type, 7'h13
        instRandom.target_opcode = 7'h13;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd1 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd3 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, I-Type Works: 7'h13");
        end

        // Test 3 I-type, 7'h67
        instRandom.target_opcode = 7'h67;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd1 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, I-Type Works: 7'h67");
        end

        // Test 4 I-type, 7'h03
        instRandom.target_opcode = 7'h03;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd1 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd1 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd1 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, I-Type Works: 7'h03");
        end


        // Test 5 S-type
        instRandom.target_opcode = 7'h23;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd2 || RegWrite !== 1'd0 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd1 || 
                MemtoReg !== 1'dx || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, S-Type Works: 7'h23");
        end


        // Test 6 B-type
        instRandom.target_opcode = 7'h63;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd3 || RegWrite !== 1'd0 || ALUSrc !== 1'd0 || 
                ALUop !== 2'd1 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'dx || Branch !== 1) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, S-Type Works: 7'h63");
        end


        // Test 7 U-type: 7'h37
        instRandom.target_opcode = 7'h37;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd4 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, S-Type Works: 7'h37");
        end

        // Test 8 U-type: 7'h17
        instRandom.target_opcode = 7'h17;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd4 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, S-Type Works: 7'h17");
        end


        // Test 9 J-type
        instRandom.target_opcode = 7'h6F;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd5 || RegWrite !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, S-Type Works: 7'h6F");
        end

        // Test 10 default
        instRandom.target_opcode = 7'd0;
        repeat(5) begin
            instRandom.randomize() with { full_inst[6:0] == target_opcode; };
            inst = instRandom.full_inst;
            #1;
            if (ImmSel !== 3'd0 || RegWrite !== 1'd0 || ALUSrc !== 1'd0 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
                end 
            else $display("Success, S-Type Works: 7'd0");
        end

        $finish;

    end

endmodule


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