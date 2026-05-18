module instructionMem_tb;


    logic [31:0] pc_out;
    logic [31:0] instruct;

    instructionMem memTest(
        .pc_out(pc_out),
        .instruct(instruct)
    );

    initial begin
        
        $dumpfile("imem.vcd");
        $dumpvars(0, instructionMem_tb);

        //Test 1: pc_out = 0
        
        pc_out = 32'h0;
        #1;

        if(instruct == 32'h00500093)
            $display("Success: instruct = 32'h00500093");
        else 
            $error("Failure: Expected 32'h00500093, got %h", instruct);

        //Test 2: pc_out = 4
        
        pc_out = 32'd4;
        #1;

        if(instruct == 32'h00A00113)
            $display("Success: instruct = 32'h00A00113");
        else 
            $error("Failure: Expected 32'h00A00113, got %h", instruct);

        //Test 3: pc_out = 8
        
        pc_out = 32'd8;
        #1;
        
        if(instruct == 32'h002081B3)
            $display("Success: instruct = 32'h002081B3");
        else 
            $error("Failure: Expected 32'h002081B3, got %h", instruct);

        $finish;


    end
 
endmodule