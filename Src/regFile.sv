module regFile (
    input logic clk,
    input logic [4:0] rs1, //reading registers
    input logic [4:0] rs2,
    input logic [4:0] rw, //register to write to
    input logic [31:0] ww, //what you are writing to the register
    input logic we, // enable writing
    
    output logic [31:0] rd1, // output what the registers read
    output logic [31:0] rd2
);
        
    logic [31:0] mainReg [0:31];

    initial begin
        for(int i = 0; i<32; i++) begin
             mainReg[i] = 32'h0;
        end
    end


    assign rd1 = mainReg[rs1];
    assign rd2 = mainReg[rs2];

    always_ff @(posedge clk) begin
    
        if(we && (rw != 5'b0)) mainReg[rw] <= ww; 

    end


endmodule