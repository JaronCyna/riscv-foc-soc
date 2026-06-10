module Top_Module(
    input logic clk,
    input logic rst_n,

    output logic [31:0] smth
);

    // Instruction Memory

    logic [31:0] pc_out, instruct;

    instructionMem instructionmem(
        .pc_out(pc_out),

        .instruct(instruct)
    );

    // Control Unit

    logic [2:0] ImmSel;
    logic RegWrite;
    logic ALUSrc;
    logic [1:0] ALUop;
    logic MemRead;
    logic MemWrite;
    logic MemtoReg;
    logic Branch;
    logic [2:0] funct3;
    logic funct7_bit6;

    logic [31:0] ww, rd1, rd2;
        
    logic [31:0] out, in2;
    logic [31:0] read;

    logic zero;

    ControlUnit controlunit(
        .inst(instruct),

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

    // ALU select decoder
    
    logic [3:0] ALU_sel;

    ALU_Sel_Decoder alu_sel_decoder(
        .ALUop(ALUop),
        .funct3(funct3),
        .funct7_bit6(funct7_bit6),

        .ALU_sel(ALU_sel)
    );


    // PC register
    logic [31:0] branch_target;

    logic branch_taken;
    assign branch_taken = Branch & zero;
    assign branch_target = pc_out + imm_ext;

    PC_reg pc_reg(
        .clk(clk),
        .rst_n(rst_n),
        .branch_taken(branch_taken),
        .branch_target(branch_target),

        .pc_out(pc_out)
    );

    // Register File


    assign ww = MemtoReg ? read : out;

    regFile regfile(
        .clk(clk),
        .rst(!rst_n),
        .rs1(instruct[19:15]),
        .rs2(instruct[24:20]),
        .rw(instruct[11:7]),
        .ww(ww),
        .we(RegWrite),

        .rd1(rd1),
        .rd2(rd2)
    );

    //  Immediate generator
    logic [31:0] imm_ext;

    ImmGen immgen(
        .inst(instruct),
        .sel(ImmSel),

        .imm_ext(imm_ext)
    );

    // ALU

    assign in2 = ALUSrc ? imm_ext : rd2;

    ALU alu(
        .a(rd1),
        .b(in2),
        .sel(ALU_sel),

        .out(out),
        .zero(zero)
    );


    // Data memory

    DataMem datamem(
        .clk(clk),
        .memRead(MemRead),
        .memWrite(MemWrite),
        .addr(out),
        .write(rd2),

        .read(read)
    );
    

    assign smth = out;


endmodule