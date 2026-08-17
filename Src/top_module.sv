module top_module(
    input logic clk,
    input logic rst_n,
    input logic btn_clk,
    input logic [9:0] sw,

    output logic [6:0] HEX0,
    output logic [6:0] HEX1

);
    
    logic clean_cpu_clk;

    assign clean_cpu_clk = clk;

//     debouncer btn_filter (
//     .clk(clk),              
//     .rst_n(rst_n),
//     .raw_btn(btn_clk),      
//     .clean_btn(clean_cpu_clk) 
// );

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
    logic branch_taken;
    logic [31:0] branch_target;
    logic jump_taken;
    logic [31:0] jump_target;
    logic [31:0] pc_next_target;
    logic redirect_pc;

    assign branch_target = pc_out + imm_ext;
    assign jump_target = (instruct[6:0] == 7'h67) ? ((rd1 + imm_ext) & ~32'h1) : (pc_out + imm_ext);
    assign jump_taken = (instruct[6:0] == 7'h6F || instruct[6:0] == 7'h67);
    assign redirect_pc = branch_taken || jump_taken;
    assign pc_next_target = jump_taken ? jump_target : branch_target;

    always_comb begin
        branch_taken = 1'b0;
        if (Branch) begin
            case (funct3)
                3'b000:  branch_taken = (rd1 == rd2);                       // BEQ
                3'b001:  branch_taken = (rd1 != rd2);                       // BNE
                3'b100:  branch_taken = ($signed(rd1) < $signed(rd2));      // BLT
                3'b101:  branch_taken = ($signed(rd1) >= $signed(rd2));     // BGE
                3'b110:  branch_taken = (rd1 < rd2);                        // BLTU
                3'b111:  branch_taken = (rd1 >= rd2);                       // BGEU
                default: branch_taken = 1'b0;
            endcase
        end
    end

    PC_reg pc_reg(
        .clk(clean_cpu_clk),
        .rst_n(rst_n),
        .branch_taken(redirect_pc),
        .branch_target(pc_next_target),
        .en(1'b1),

        .pc_out(pc_out)
    );

    // Register File


    assign ww = MemtoReg ? read : out;

    regFile #(.WRITE_THROUGH(0)) regfile(
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
    logic [31:0] alu_a_src;
    assign alu_a_src = (instruct[6:0] == 7'h37) ? 32'd0 :
                       (instruct[6:0] == 7'h17 || instruct[6:0] == 7'h6F || instruct[6:0] == 7'h67) ? pc_out : rd1;
    assign final_alu_a = (sw[9]) ? {28'd0, sw[7:4]} : alu_a_src;

    // First, handle the normal ALUSrc routing (Immediate vs Register 2)
    logic [31:0] normal_in2;
    logic [31:0] alu_b_src;
    assign alu_b_src = (instruct[6:0] == 7'h6F || instruct[6:0] == 7'h67) ? 32'd4 :
                       (ALUSrc ? imm_ext : rd2);
    assign normal_in2 = alu_b_src;

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