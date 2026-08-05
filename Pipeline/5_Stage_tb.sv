module _5_stage_tb;

    logic clk = 0
    logic rst_n;
    logic [31:0] out;

    rv32i_5stage_core CPU(
        .clk(clk),
        .rst_n(rst_n),

        .out(out)
    );
    
    parameter CLK_PERIOD = 10;


    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $dumpfile("5_stage_CPU.vcd");
        $dumpvars(0, _5_stage_tb);

        rst_n = 0;
        #20;
        rst_n = 1;
        

        #(200*CLK_PERIOD);
        #1;

        //CRT From Python
        $display("\n HARDWARE REGISTERS vs PYTHON EXPECTED PART 2");
        $display("  x0: Hardware = %0d | Expected = 0",          CPU.regFile.mainReg[0]);
        $display("  x1: Hardware = %0d | Expected = 63",         CPU.regFile.mainReg[1]);
        $display("  x2: Hardware = %0d | Expected = 0",          CPU.regFile.mainReg[2]);
        $display("  x3: Hardware = %0d | Expected = 4294967253", CPU.regFile.mainReg[3]);
        $display("  x4: Hardware = %0d | Expected = 106",        CPU.regFile.mainReg[4]);
        $display("  x5: Hardware = %0d | Expected = 4294967253", CPU.regFile.mainReg[5]);
        $display("\n");
        
        if (CPU.regFile.mainReg[0] == 0  &&
            CPU.regFile.mainReg[1] == 63  && 
            CPU.regFile.mainReg[3] == 4294967253 && 
            CPU.regFile.mainReg[4] == 106 && 
            CPU.regFile.mainReg[5] == 4294967253) begin
            $display(">> [SUCCESS] CPU Forwarding, Hazards, and CRT 100%% VERIFIED!\n");
        end else begin
            $display(">> [FAIL] Hardware state mismatch detected!\n");
        end

        $finish;

    end



endmodule