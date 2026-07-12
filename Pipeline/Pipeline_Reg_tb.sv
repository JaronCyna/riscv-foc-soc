module Pipeline_reg_tb;
    
    parameter Reg = 32;
    input logic clk, rst_n, en;
    input logic [Reg-1:0] data_in, data_out;

    Pipeline_reg Pipeline_register #(.Reg_size(Reg))(
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .data_in(data_in),
        .data_out(data_out)
    );

    parameter CLK_PERIOD = 10;
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $dumpfile("Pipeline_Reg.vcd");
        $dumpvars(0, Pipeline_reg_tb);

        rst_n = 1'b1;
        en = 1'b1;
        data_in = 32'hDD1B309D;

        // TEST 1: Test output of an input
        @(posedge clk); #1; // give time to settle after clk edge

        if (data_out == data_in) $display("Test 1 Passed");
        else $error("Test 1 Failed");

        data_in = 32'b0;
        // TEST 2: Check that the original output clears
        @(posedge clk); #1;

        if (data_out == data_in) $display("Test 2 Passed");
        else $error("Test 2 Failed");

        
        data_in = 32'hDD1B309D;
        en = 1'b0;
        // TEST 3: Not Enabled Check
        @(posedge clk); #1;
        
        if (data_out == 32'b0) $display("Test 3 Passed");
        else $error("Test 3 Failed");

        en = 1'b1;
        rst_n = 1'b0;
        // TEST 4: Reset Check
        @(posedge clk); #1;
        
        if (data_out == 32'b0) $display("Test 4 Passed");
        else $error("Test 4 Failed");

    end

endmodule



    
