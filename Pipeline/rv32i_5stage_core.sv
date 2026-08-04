module rv32i_5stage_core(
    input logic clk,
    input logic rst_n,

    output [31:0] out
);

    logic clock;

    assign clock = clk;


    // Instruction Fetch

    // PC register
    logic [31:0] imm_ext;
    logic [31:0] branch_target;
    logic [31:0] pc_out, instruct;
    logic IF_IDWrite;
    logic PCWrite;

    logic branch_taken;
    assign branch_target = pc_out + imm_ext;
    PC_reg pc_reg(
        .clk(clock),
        .rst_n(rst_n),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .en(PCWrite),

        .pc_out(pc_out)
    );



    logic [31:0] normal_instruct;
    

    instructionMem instructionmem(
        .pc_out(pc_out),
        .instruct(normal_instruct)
    );

    assign instruct = normal_instruct;

    logic [31:0] instruct_out;

    logic [31:0] if_id_in;

    // RISC-V NOP: 32'h00000013 when branch is 
    assign if_id_in = (branch_taken) ? 32'h00000013 : instruct;

    Pipeline_reg IF_ID_Reg(
        .clk(clock),
        .rst_n(rst_n),
        .data_in(if_id_in),
        .en(IF_IDWrite),
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
        
    logic [31:0] out, base_alu_b;
    logic [31:0] read;

    logic zero;

    logic [10:0] control_bits;


    ControlUnit controlunit(
        .inst(instruct_out),

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


    //  Immediate generator
    ImmGen immgen(
        .inst(instruct_out),
        .sel(ImmSel),

        .imm_ext(imm_ext)
    );
    
    // Register File
    regFile regfile(
        .clk(clock),
        .rst(!rst_n),
        .rs1(instruct_out[19:15]),
        .rs2(instruct_out[24:20]),
        .rw(rw_WB),
        .ww(ww),
        .we(control_bits_WB[0]),

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
    logic [10:0] Bubble_Mux, control_bits_EX;
    logic bubble;
    logic [4:0] rw_EX;
    

    Hazard_Unit hazard_unit(
        .rw_EX(rw_EX),
        .rs1_ID(instruct_out[19:15]),
        .rs2_ID(instruct_out[24:20]),
        .MemRead_EX(control_bits_EX[3]),

        .PCWrite(PCWrite),
        .IF_IDWrite(IF_IDWrite),
        .bubble(bubble)

    );

    logic [31:0] branch_rd1, branch_rd2, alu_result;
    logic [4:0]  rs1_ID, rs2_ID;

    assign rs1_ID = instruct_out[19:15];
    assign rs2_ID = instruct_out[24:20];

    // Priority-based forwarding to ID stage comparison
    assign branch_rd1 = ((rs1_ID != 0) && (rs1_ID == rw_EX)  && control_bits_EX[0])  ? alu_result :
                        ((rs1_ID != 0) && (rs1_ID == rw_MEM) && control_bits_MEM[0]) ? ALU_out_MEM :
                        ((rs1_ID != 0) && (rs1_ID == rw_WB)  && control_bits_WB[0])  ? ww : rd1;

    assign branch_rd2 = ((rs2_ID != 0) && (rs2_ID == rw_EX)  && control_bits_EX[0])  ? alu_result :
                        ((rs2_ID != 0) && (rs2_ID == rw_MEM) && control_bits_MEM[0]) ? ALU_out_MEM :
                        ((rs2_ID != 0) && (rs2_ID == rw_WB)  && control_bits_WB[0])  ? ww : rd2;

    always_comb begin
        // Default: branch is not taken unless proven otherwise
        branch_taken = 1'b0; 
        
        // Only evaluate comparisons if the Control Unit says this is a Branch instruction
        if (Branch) begin
            case (funct3)
                3'b000:  branch_taken = (branch_rd1 == branch_rd2); // BEQ (Branch Equal)
                3'b001:  branch_taken = (branch_rd1 != branch_rd2); // BNE (Branch Not Equal)
                3'b100:  branch_taken = ($signed(branch_rd1) < $signed(branch_rd2));  // BLT (Branch Less Than)
                3'b101:  branch_taken = ($signed(branch_rd1) >= $signed(branch_rd2)); // BGE (Branch Greater Than)
                3'b110:  branch_taken = (branch_rd1 < branch_rd2);  // BLTU (Branch Less Than, Unsigned)
                3'b111:  branch_taken = (branch_rd1 >= branch_rd2); // BGEU (Branch Greater Than, Unsigned)
                default: branch_taken = 1'b0;
            endcase
        end
    end

    assign Bubble_Mux = (bubble) ?  11'b0 : control_bits;
    assign ID_EX_In = {Bubble_Mux, rd1, rd2, instruct_out[19:15], 
                       instruct_out[24:20], instruct_out[11:7], imm_ext
                      };

    Pipeline_reg #(.Reg_size(122)) ID_EX_Reg(
        .clk(clock),
        .rst_n(rst_n),
        .data_in(ID_EX_In),
        .en(1'b1),
        .data_out(ID_EX_Out)
    );

    // EX Stage

    logic [72:0] EX_MEM_IN;
    logic [72:0] EX_MEM_OUT;
    logic [31:0] rd1_EX, rd2_EX, imm_ext_EX;
    logic [4:0]  rs1_EX, rs2_EX;

    assign {control_bits_EX, rd1_EX, rd2_EX, rs1_EX, rs2_EX, rw_EX, imm_ext_EX} = ID_EX_Out;

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
    logic [31:0] final_alu_b;
    logic [31:0] base_alu_a;
    logic [31:0] in2;
    logic [1:0]  fwd1, fwd2;
    logic [3:0] control_bits_MEM;
    logic [1:0] control_bits_WB;
    logic [4:0] rw_MEM;
    logic [4:0] rw_WB;
    logic [31:0] forwarded_rd2;


    Fwd_Unit fwd_unit(
        .rs1_EX(rs1_EX),
        .rs2_EX(rs2_EX),
        .rw_MEM(rw_MEM),
        .rw_WB(rw_WB),
        .control_bits_WB(control_bits_WB),
        .control_bits_MEM(control_bits_MEM),

        .fwd1(fwd1),
        .fwd2(fwd2)
    );



    assign base_alu_a = rd1_EX;

    assign final_alu_a = (fwd1 == 2'b00) ? base_alu_a  : // fwd1 does not exist yet
                         (fwd1 == 2'b01) ? ww          :
                         (fwd1 == 2'b10) ? ALU_out_MEM : 32'bx;

    assign forwarded_rd2 = (fwd2 == 2'b00) ? rd2_EX       : 
                           (fwd2 == 2'b01) ? ww           :
                           (fwd2 == 2'b10) ? ALU_out_MEM  : 32'bx;

    assign base_alu_b = forwarded_rd2;

    assign in2 = control_bits_EX[10] ? imm_ext_EX : base_alu_b; // control_bits_EX[10] is ALUSrc 

    
    ALU alu(
        .a(final_alu_a),
        .b(in2),
        .sel(ALU_sel),
        .out(alu_result),
        .zero(zero)
    );
    
    assign EX_MEM_IN = {control_bits_EX[3:0], alu_result, forwarded_rd2, rw_EX};
    Pipeline_reg #(.Reg_size(73)) EX_MEM_Reg(
        .clk(clock),
        .rst_n(rst_n),
        .data_in(EX_MEM_IN),
        .en(1'b1),
        .data_out(EX_MEM_OUT)
    );



    //MEM Stage

    // Data memory

    logic [70:0] MEM_WB_IN;
    logic [70:0] MEM_WB_OUT;

    logic [31:0] ALU_out_MEM, rd2_MEM;

    assign {control_bits_MEM, ALU_out_MEM, rd2_MEM, rw_MEM} = EX_MEM_OUT;

    DataMem datamem(
        .clk(clock),
        .memRead(control_bits_MEM[3]),
        .memWrite(control_bits_MEM[2]),
        .addr(ALU_out_MEM),
        .write(rd2_MEM),

        .read(read)
    );
    
    assign MEM_WB_IN = {control_bits_MEM[1:0], ALU_out_MEM, rw_MEM, read};

    Pipeline_reg #(.Reg_size(71)) MEM_WB_Reg(
        .clk(clock),
        .rst_n(rst_n),
        .data_in(MEM_WB_IN),
        .en(1'b1),
        .data_out(MEM_WB_OUT)
    );


    // Write Back Stage

    logic [31:0] ALU_out_WB, read_WB;

    assign {control_bits_WB, ALU_out_WB, rw_WB, read_WB} = MEM_WB_OUT;

    assign ww = control_bits_WB[1] ? read_WB : ALU_out_WB;

    assign out = ww;


endmodule