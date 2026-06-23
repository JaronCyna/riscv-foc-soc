module top_module(
    input logic clk,
    input logic rst_n,
    input logic btn_clk,
    input logic [9:0] sw,

    output logic [6:0] HEX0,
    output logic [6:0] HEX1

);
    
    logic clean_cpu_clk;

    debouncer btn_filter (
    .clk(clk),              
    .rst_n(rst_n),
    .raw_btn(btn_clk),      
    .clean_btn(clean_cpu_clk) 
);

    // Instruction Memory

    logic [31:0] pc_out, instruct;

    logic [31:0] normal_instruct;
    logic [31:0] switch_instruct;

    sw_imem SW_IMEM (
        .sw(sw),
        .inst(switch_instruct)
    );

    instructionMem instructionmem(
        .pc_out(pc_out),
        .instruct(normal_instruct)
    );

    assign instruct = (sw[9]) ? switch_instruct : normal_instruct;

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

    logic [31:0] imm_ext;


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
        .clk(clean_cpu_clk),
        .rst_n(rst_n),
        .branch_taken(branch_taken),
        .branch_target(branch_target),

        .pc_out(pc_out)
    );

    // Register File


    assign ww = MemtoReg ? read : out;

    regFile regfile(
        .clk(clean_cpu_clk),
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

    ImmGen immgen(
        .inst(instruct),
        .sel(ImmSel),

        .imm_ext(imm_ext)
    );

    // ALU

    logic [31:0] final_alu_a;
    assign final_alu_a = (sw[9]) ? {28'd0, sw[7:4]} : rd1;

    // First, handle the normal ALUSrc routing (Immediate vs Register 2)
    logic [31:0] normal_in2;
    assign normal_in2 = ALUSrc ? imm_ext : rd2;

    // Then, if in Test Mode, force Input B to be the 4-bit NumB switch value 
    assign in2 = (sw[9]) ? {28'd0, sw[3:0]} : normal_in2;

    ALU alu(
        .a(final_alu_a),
        .b(in2),
        .sel(ALU_sel),
        .out(out),
        .zero(zero)
    );

    // Data memory

    DataMem datamem(
        .clk(clean_cpu_clk),
        .memRead(MemRead),
        .memWrite(MemWrite),
        .addr(out),
        .write(rd2),

        .read(read)
    );
    

    // Digit 0 handles the lower 4 bits of the calculation result
    sevenSegDecoder display_digit_0 (
        .bin_in(out[3:0]),
        .seg_out(HEX0)
    );

    // Digit 1 handles the upper 4 bits of the calculation result
    sevenSegDecoder display_digit_1 (
        .bin_in(out[7:4]),
        .seg_out(HEX1)
    );


endmodule