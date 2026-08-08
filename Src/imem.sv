module instructionMem #(parameter InsTot = 256000)
(
     input logic [31:0] pc_out,
    output logic [31:0] instruct
);

    logic [31:0] memory [0:InsTot-1];


    initial begin
        // Initialize memory with NOPs (0x00000013) to prevent 'X' states
        for (int i = 0; i < InsTot; i++) begin
            memory[i] = 32'h00000013;
        end
        $readmemh("Pipeline/program.hex", memory);
    end

    logic [31:0] word_addr;
    assign word_addr = pc_out/4; 

    assign instruct = (word_addr < InsTot) ? memory[word_addr] : 32'h00000013; // Default to NOP if out-of-bounds    

endmodule