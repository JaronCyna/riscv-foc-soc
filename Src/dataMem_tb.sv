module datamem_tb;

    logic clk;
    logic memRead;
    logic memWrite;
    logic [31:0] addr;
    logic [31:0] write;
    logic [31:0] read;

    parameter CLK_PERIOD = 10;

    DataMem testRAM(
        .clk(clk),
        .memRead(memRead),
        .memWrite(memWrite),
        .addr(addr),
        .write(write),
        .read(read)
    );


    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin

        $dumpfile("dataMem.vcd");
        $dumpvars(0, datamem_tb);

        memRead = 1'b1;
        memWrite = 1'b0;
        addr = 32'd17;
        write = 32'd14;

        // TEST 1: Read from an empty address (Should return 0)
        @(posedge clk); #1;

            if(read == 32'd0) 
                $display("read = 0");
            else
                $error("Failure: Expected 0, got %d", read);
        
        memWrite = 1'b1;

        // TEST 2: Write 14 into Address 17
        @(posedge clk); #1;

        if(read == 32'd14) 
            $display("read = 14");
        else
            $error("Failure: Expected 14, got %d", read);

        // TEST 3: Write 16 into Address 19

        memRead = 1'b0;
        memWrite = 1'b1;
        addr = 32'd19;
        write = 32'd16;

        @(posedge clk); #1;

        if(read == 32'd0) 
            $display("read = 0");
        else
            $error("Failure: Expected 0, got %d", read);
        
        memRead = 1'b1;
        
        memWrite = 1'b0; 
        memRead = 1'b1;  
        
        #1; 
        
        if(read == 32'd16) 
            $display("read = 16");
        else
            $error("Failure: Expected 16, got %d", read);
        
        $finish;
    end
        

endmodule