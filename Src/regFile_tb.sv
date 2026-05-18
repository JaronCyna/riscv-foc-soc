    module regFile_tb;

        parameter CLK_PERIOD = 10;

        logic clk;
        logic [4:0] rs1;
        logic [4:0] rs2;
        logic [4:0] rw;
        logic [31:0] ww;
        logic we;

        logic [31:0] rd1;
        logic [31:0] rd2;


        regFile testReg (

            .clk(clk),
            .rs1(rs1),
            .rs2(rs2),
            .rw(rw),
            .ww(ww),
            .we(we),

            .rd1(rd1),
            .rd2(rd2)
        );

        initial clk = 0;
        always #(CLK_PERIOD/2) clk = ~clk;

        initial begin
            
            $dumpfile("regfile.vcd");
            $dumpvars(0, regFile_tb);

            // Test 1: writing when enabled to
            we = 1;
            rw = 5'd3;
            rs1 = 5'd3;
            ww = 32'd4;
            @(posedge clk); #1;
            if(rd1 == ww)
                $display("Success: rd1 = %d", rd1);
            else
                $error("Failure: Expected %d, got %d", ww, rd1);  

            rw = 5'd4;
            rs2 = 5'd4;
            ww = 32'd5;
            @(posedge clk); #1;
            if(rd2 == ww)
                $display("Success: rd1 = %d", rd1);
            else
                $error("Failure: Expected %d, got %d", ww, rd2);  

            
            // Test 2: writing when not enabled to
            we = 0;
            rw = 5'd3;
            rs1 = 5'd3;
            ww = 32'd9;
            @(posedge clk); #1;
            if(rd1 == 32'd4)
                $display("Success: rd1 = %d", rd1);
            else
                $error("Failure: Expected %d, got %d", 32'd4, rd1);  

            rw = 5'd4;
            rs2 = 5'd4;
            ww = 32'd9;
            @(posedge clk); #1;
            if(rd2 == 32'd5)
                $display("Success: rd1 = %d", rd2);
            else
                $error("Failure: Expected %d, got %d", 32'd5, rd1);


            // Test 3: writing to register 0
            we = 1;
            rw = 5'd0;
            rs1 = 5'd0;
            ww = 32'd9;
            @(posedge clk); #1;
            if(rd1 == 32'h0)
                $display("Success: rd1 = %d", rd1);
            else
                $error("Failure: Expected %d, got %d", 32'h0, rd1); 


            // Test 4: checking that both rs work at the same time
            we = 0;
            rs1 = 5'd3;
            rs2 = 5'd4;
            @(posedge clk); #1;
            if(rd1 == 32'd4 && rd2 == 32'd5)
                $display("Success: rd1 = %d, rd2 = %d", rd1, rd2);
            else
                $error("Failure: rd1: Expected %d, got %d, rd2: Expected %d, got %d", 32'd4, rd1, 32'd5, rd2);

            $finish;
        end


    endmodule