// Using Constrained Random Verification (CRV) to test multiple inputs and confirm functionality 
module ControlUnit_tb;

    logic [31:0] inst;
    logic [2:0]  ImmSel;
    logic        RegWrite;
    logic        ALUSrc;
    logic [1:0]  ALUop;
    logic        MemRead;
    logic        MemWrite;
    logic        MemtoReg;
    logic        Branch;
    logic [2:0]  funct3;
    logic        funct7_bit6;

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

    initial begin
        $dumpfile("CtrlUnit.vcd");
        $dumpvars(0, ControlUnit_tb);
       
        // Test 1 R-type
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'h33 }; 
            #1;
            if (ImmSel !== 3'd0 || RegWrite !== 1'd1 || ALUSrc !== 1'd0 || 
                ALUop !== 2'd2 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, R-Type Works");
        end

        // Test 2 I-type, 7'h13
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'h13 }; 
            #1;
            if (ImmSel !== 3'd1 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd3 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, I-Type Works: 7'h13");
        end

        // Test 3 I-type, 7'h67
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'h67 }; 
            #1;
            if (ImmSel !== 3'd1 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, I-Type Works: 7'h67");
        end

        // Test 4 I-type, 7'h03
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'h03 }; 
            #1;
            if (ImmSel !== 3'd1 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd1 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd1 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, I-Type Works: 7'h03");
        end

        // Test 5 S-type
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'h23 }; 
            #1;
            if (ImmSel !== 3'd2 || RegWrite !== 1'd0 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd1 || 
                Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, S-Type Works: 7'h23");
        end

        // Test 6 B-type
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'h63 }; 
            #1;
            if (ImmSel !== 3'd3 || RegWrite !== 1'd0 || ALUSrc !== 1'd0 || 
                ALUop !== 2'd1 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                Branch !== 1) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, S-Type Works: 7'h63");
        end

        // Test 7 U-type: 7'h37
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'h37 }; 
            #1;
            if (ImmSel !== 3'd4 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, S-Type Works: 7'h37");
        end

        // Test 8 U-type: 7'h17
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'h17 }; 
            #1;
            if (ImmSel !== 3'd4 || RegWrite !== 1'd1 || ALUSrc !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, S-Type Works: 7'h17");
        end

        // Test 9 J-type
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'h6F }; 
            #1;
            if (ImmSel !== 3'd5 || RegWrite !== 1'd1 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, S-Type Works: 7'h6F");
        end

        // Test 10 default
        repeat(5) begin
            inst = { $urandom() & 25'h1FFFFFF, 7'd0 }; 
            #1;
            if (ImmSel !== 3'd0 || RegWrite !== 1'd0 || ALUSrc !== 1'd0 || 
                ALUop !== 2'd0 || MemRead !== 1'd0 || MemWrite !== 1'd0 || 
                MemtoReg !== 1'd0 || Branch !== 0) begin
                $error("Mismatch: R-Type instruction failed. Inst: %h, RegWrite: %b, ALUSrc: %b ImmSel: %d, ALUop: %d, MemRead %d, MemWrite %d, MemtoReg %d, Branch %d", 
                        inst, RegWrite, ALUSrc, ImmSel, ALUop, MemRead,
                        MemWrite, MemtoReg, Branch);
            end else $display("Success, S-Type Works: 7'd0");
        end

        $finish;
    end

endmodule