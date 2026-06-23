module CPU_tb;

    logic clk;
    logic rst_n;
    logic [31:0] final_out;

    
    parameter CLK_PERIOD = 10;

    top_module CPU(
        .clk(clk),
        .rst_n(rst_n),
        .final_out(final_out)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $dumpfile("CPU.vcd");
        $dumpvars(0, CPU_tb);

        rst_n = 0;
        @(posedge clk); #1;

        if (final_out == 5) begin
            $display("the cpu works.");
        end



        $finish;
    end
    


endmodule