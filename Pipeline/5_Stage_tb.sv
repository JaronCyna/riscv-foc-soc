module _5_stage_tb;

    logic clk = 0;
    logic rst_n;
    logic [31:0] out;

    rv32i_5stage_core CPU(
        .clk(clk),
        .rst_n(rst_n),

        .out(out)
    );
    
    parameter CLK_PERIOD = 3;


    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $dumpfile("5_stage_CPU.vcd");
        $dumpvars(0, _5_stage_tb);

        rst_n = 0;
        #20;
        rst_n = 1;
        
        for(int i = 1; i<2500; i++) begin
            @(posedge clk); #1;

        //CRT From Python

            $display("WB Stage: PC = %0d | Instruction = 0x%08X | ALU_in1 = %0d | ALUin2 = %0d", CPU.pc_WB/4, CPU.inst_WB, CPU.final_alu_a, CPU.in2);
            $display("\n  x0: Hardware = %0d ",  CPU.regfile.mainReg[0]);
            $display("  x1: Hardware = %0d ", CPU.regfile.mainReg[1]);
            $display("  x2: Hardware = %0d ", CPU.regfile.mainReg[2]);
            $display("  x3: Hardware = %0d ",  CPU.regfile.mainReg[3]);
            $display("  x4: Hardware = %0d ", CPU.regfile.mainReg[4]);
            $display("  x5: Hardware = %0d ", CPU.regfile.mainReg[5]);        
            $display("\n");

        end
        
        if (CPU.regfile.mainReg[0] == 0  &&
            CPU.regfile.mainReg[1] == 35  && 
            CPU.regfile.mainReg[2] == 5  && 
            CPU.regfile.mainReg[3] == 0  && 
            CPU.regfile.mainReg[4] == 29  && 
            CPU.regfile.mainReg[5] == 0) begin
            $display(">> [SUCCESS] CPU Forwarding, Hazards, and CRT 100%% VERIFIED!\n");
        end else begin
            $display(">> [FAIL] Hardware state mismatch detected!\n");
        end

        $finish;

    end



endmodule