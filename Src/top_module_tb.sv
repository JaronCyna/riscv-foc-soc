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


        // This testing will be split into 2 primary parts, the first will be directed to check for data hazards
        // The second will use CRT to test for a bunch of random situations

        //PART 1 Data Hazard Checks

        //1.1 RAW (Read-After-Write) EX-to-EX Forwarding

        


        $finish;
    end
    


endmodule