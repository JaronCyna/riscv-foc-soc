module instructionMem #(parameter InsTot = 256)
(
     input logic [31:0] pc_out,
    output logic [31:0] instruct
);

    logic [31:0] memory [0:InsTot-1];


    initial begin
        memory[0] = 32'h00500093;  // addi x1, x0, 5
        memory[1] = 32'h00A00113;  // addi x2, x0, 10
        memory[2] = 32'h002081B3;  // add  x3, x1, x2
    end

    // Will change to this when I have a compiled file to load from
    // initial $readmemh("program.hex", memory);

    //Pick the instruction defined by the program counter
    assign instruct = memory[pc_out/4];
    
endmodule