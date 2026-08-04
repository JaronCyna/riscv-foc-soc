module 5_stage_tb;

    logic clk, rst_n;
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
        $dumpvars(0, 5_stage_tb);

        rst_n = 0;
        #20;
        rst_n = 1;
        

    end



endmodule