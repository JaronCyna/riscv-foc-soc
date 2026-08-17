module regFile #(parameter WRITE_THROUGH = 1)(
    input logic clk,
    input logic rst,        // Wire up to FPGA master reset button
    input logic [4:0] rs1,  // reading registers
    input logic [4:0] rs2,
    input logic [4:0] rw,   // register to write to
    input logic [31:0] ww,  // what you are writing to the register
    input logic we,         // enable writing

    output logic [31:0] rd1, // output what the registers read
    output logic [31:0] rd2
);

    logic [31:0] mainReg [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            mainReg[i] = 0; // x0=0, x1=1, x2=2, x3=3... x15=15
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
        for (i = 0; i < 32; i = i + 1) begin
            mainReg[i] = 0; // x0=0, x1=1, x2=2, x3=3... x15=15
        end
        end else if (we && (rw != 5'd0)) begin
            mainReg[rw] <= ww;
        end
    end

    
    always_comb begin
        if(WRITE_THROUGH == 1) begin
            rd1 = (rs1 == 5'd0) ? 32'd0 : (we && (rs1 == rw)) ? ww : mainReg[rs1];
            rd2 = (rs2 == 5'd0) ? 32'd0 : (we && (rs2 == rw)) ? ww : mainReg[rs2];
        end
        else begin
            rd1 = (rs1 == 5'd0) ? 32'd0 : mainReg[rs1];
            rd2 = (rs2 == 5'd0) ? 32'd0 : mainReg[rs2];
        end
    end

endmodule