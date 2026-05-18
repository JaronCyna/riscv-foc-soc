module pc_tb;

    logic clk;
    logic rst_n;
    logic branch_taken;
    logic [31:0] branch_target;
    logic [31:0] pc_out;

    parameter CLK_PERIOD = 10;

    //Instantiate the PC module
    PC_reg regTest(
        .clk(clk),
        .rst_n(rst_n),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .pc_out(pc_out)
    );  

    //Clock generation separate from stimulus
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin

        $dumpfile("pc.vcd");
        $dumpvars(0, pc_tb);

        // initialize in reset state
        rst_n = 0;
        branch_taken = 0;
        branch_target = 32'h0;



        // Test 1: reset
        @(posedge clk); #1;
        if(pc_out == 0) 
            $display("branch_taken = 0: Success: pc_out = 0");
        else
            $error("Failure: Expected 0, got %d", pc_out);

        rst_n = 1;
        
        // Test 2: branch_taken = 0
        for(int i = 1; i<8; i++) begin
            @(posedge clk); #1;
            
            if(pc_out == 32'(i * 4)) 
                $display("branch_taken = 0: Success: pc_out = %d", (4*i));
            else 
                $error("Failure: Expected %d, got %d", (4*i), pc_out);
        end


        branch_taken = 1;

        // Test3: branch_taken = 1
        for (int i=0; i<31; i++) begin
        branch_target = i;

        @(posedge clk); #1;
        
        $display("Loop iteration: %d", i);
        if(pc_out == branch_target)
            $display("branch_taken = 0: Success: pc_out = %d", branch_target);
        else
            $error("Failure: Expected %d, got %d", branch_target, pc_out);

        end

        $finish;
    end

endmodule