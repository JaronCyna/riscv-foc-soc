module ImmGen_tb;

    logic [31:0] inst;
    logic [2:0] sel;
    logic [31:0] imm_ext;

    ImmGen ImmGenTest(
        .inst(inst),
        .sel(sel),
        .imm_ext(imm_ext)
    );


    // All values for testing were gotten from https://venus.cs61c.org/
    // where I compiled assembly to get the inst values

    initial begin
            
        $dumpfile("ImmGen.vcd");
        $dumpvars(0, ImmGen_tb);

        //Test 1: R type
        sel = 0;
        inst = 32'h00c58533;
        #1;

        if(imm_ext === 32'd0)
            $display("Success: imm_ext = %d", imm_ext);
        else 
            $error("Failure: Expected 32'd0, got %h", imm_ext);

        //Test 2: I type
        sel = 1;
        inst = 32'h00c28513;
        #1;

        if(imm_ext === 32'd12)
            $display("Success: imm_ext = %d", imm_ext);
        else 
            $error("Failure: Expected %h, got %h", 32'd12, imm_ext);

        //Test 3: S type
        sel = 2;
        inst = 32'h00A22223;
        #1;

        if(imm_ext === 32'd4)
            $display("Success: imm_ext = %d", imm_ext);
        else 
            $error("Failure: Expected %h, got %h", 32'd4, imm_ext);

        //Test 4: B type
        sel = 3;
        inst = 32'h00730663;
        #1;

        if(imm_ext === 32'd12)
            $display("Success: imm_ext = %d", imm_ext);
        else 
            $error("Failure: Expected %h, got %h", 32'd12, imm_ext);

        //Test 5: U type
        sel = 4;
        inst = 32'h12345537;
        #1;

        if(imm_ext ===  32'h12345000)
            $display("Success: imm_ext = %d", imm_ext);
        else 
            $error("Failure: Expected %h, got %h", 32'h12345000, imm_ext);
        
        //Test 6: J type
        sel = 5;
        inst = 32'h001000EF;
        #1;

        if(imm_ext === 32'd2048)
            $display("Success: imm_ext = %d", imm_ext);
        else 
            $error("Failure: Expected %h, got %h", 32'd2048, imm_ext);

        $finish;

    end

endmodule

