module top_module(
    input logic clk,
    input logic rst_n,
    input logic btn_clk,
    input logic [9:0] sw,

    output logic [6:0] HEX0,
    output logic [6:0] HEX1

);



    logic clean_cpu_clk;
    logic clock;

    debouncer btn_filter (
    .clk(clk),              
    .rst_n(rst_n),
    .raw_btn(btn_clk),      
    .clean_btn(clean_cpu_clk) 
);

    assign clock = (sw[9]) ? clean_cpu_clk : clk;


    // Instruction Fetch

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

    logic [31:0] instruct_out;

    Pipeline_reg IF_ID_Reg(
        .clk(clock),
        .rst_n(rst_n),
        .data_in(instruct),
        .data_out(instruct_out)
    );

    //Instuction Decode

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
    logic [10:0] control_bits;


    ControlUnit controlunit(
        .inst(instrust_out),

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


    assign ww = MemtoReg ? read : out;

    //  Immediate generator
    ImmGen immgen(
        .inst(instrust_out),
        .sel(ImmSel),

        .imm_ext(imm_ext)
    );
    
    // Register File
    regFile regfile(
        .clk(clock),
        .rst(!rst_n),
        .rs1(instrust_out[19:15]),
        .rs2(instrust_out[24:20]),
        .rw(instrust_out[11:7]),
        .ww(ww), //Need to change these once mem stage is made
        .we(RegWrite),

        .rd1(rd1),
        .rd2(rd2)
    );

    assign control_bits = {
        ALUSrc, ALUop, funct3, 
        funct7_bit6, MemRead, MemWrite, 
        MemtoReg, RegWrite
    };

    logic [121:0] ID_EX_Out;
    logic [121:0] ID_EX_In;

    assign ID_EX_In = {control_bits, rd1, rd2, instrust_out[19:15], 
                       instrust_out[24:20], instrust_out[11:7], imm_ext
                      };

    Pipeline_reg #(.Reg_size(122)) ID_EX_Reg(
        .clk(clock),
        .rst_n(rst_n),
        .data_in(ID_EX_In),
        .data_out(ID_EX_Out)
    );

    // EX Stage

    logic [72:0] EX_MEM_IN;
    logic [72:0] EX_MEM_OUT;

    logic [10:0] control_bits_EX;
    logic [31:0] rd1_EX, rd2_EX, imm_ext_EX;
    logic [4:0]  rs1_EX, rs2_EX, rd_EX;

    assign {control_bits_EX, rd1_EX, rd2_EX, rs1_EX, rs2_EX, rd_EX, imm_ext_EX} = ID_EX_Out;

    // ALU select decoder
    
    logic [3:0] ALU_sel;

    ALU_Sel_Decoder alu_sel_decoder(
        .ALUop(control_bits_EX[9:8]),
        .funct3(control_bits_EX[7:5]),
        .funct7_bit6(control_bits_EX[4]),

        .ALU_sel(ALU_sel)
    );

   // ALU

    logic [31:0] final_alu_a;
    assign final_alu_a = (sw[9]) ? {28'd0, sw[7:4]} : rd1_EX;

    // First, handle the normal ALUSrc routing (Immediate vs Register 2)
    logic [31:0] normal_in2;
    assign normal_in2 = control_bits_EX[10] ? imm_ext_EX : rd2_EX; // control_bits_EX[10] is ALUSrc
    
    // Then, if in Test Mode, force Input B to be the 4-bit NumB switch value 
    assign in2 = (sw[9]) ? {28'd0, sw[3:0]} : normal_in2;

    ALU alu(
        .a(final_alu_a),
        .b(in2),
        .sel(ALU_sel),
        .out(out),
        .zero(zero)
    );
    
    assign EX_MEM_IN = {control_bits_EX[3:0], out, rd2_EX, rd_EX};
    Pipeline_reg #(.Reg_size(73)) EX_MEM_Reg(
        .clk(clock),
        .rst_n(rst_n),
        .data_in(EX_MEM_IN)
        .data_out(EX_MEM_OUT)
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