module  cpu_compare_tb;


    logic clk = 0;
    logic rst_n;
    logic [9:0] sw = 10'b0;

    logic [6:0] HEX0;
    logic [6:0] HEX1;
    
    top_module Single_Cycle(
        .clk(clk),
        .rst_n(rst_n),
        .btn_clk(clk),
        .sw(sw),

        .HEX0(HEX0),
        .HEX1(HEX1)
    );

    logic [31:0] out;

    rv32i_5stage_core _5stage(
        .clk(clk),
        .rst_n(rst_n),

        .out(out)
    );

    parameter CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk = ~clk;

    logic single_val = 1;
    logic pipeline_val = 1;

    int single_count = 0;
    int pipeline_count = 0;
    initial begin

        rst_n = 0;
        @(posedge clk); #1;
        rst_n = 1;

        while(_5stage.regfile.mainReg[6] == 0) begin
            @(posedge clk); #1
            
            if(Single_Cycle.regfile.mainReg[6] != 0) single_val = 0;
            else single_val = 1;
            if(single_val == 1) single_count++;

            pipeline_count++;

        end

            $display("\n  x0: Hardware = %0d ",  _5stage.regfile.mainReg[0]);
            $display("  x1: Hardware = %0d ", _5stage.regfile.mainReg[1]);
            $display("  x2: Hardware = %0d ", _5stage.regfile.mainReg[2]);
            $display("  x3: Hardware = %0d ",  _5stage.regfile.mainReg[3]);
            $display("  x4: Hardware = %0d ", _5stage.regfile.mainReg[4]);
            $display("  x5: Hardware = %0d ", _5stage.regfile.mainReg[5]);   
            $display("  x6: Hardware = %0d ", _5stage.regfile.mainReg[6]);   
            $display("\n 5 stage cycle count = %0d", pipeline_count);
            $display("\n");


            $display("\n  x0: Hardware = %0d ",  Single_Cycle.regfile.mainReg[0]);
            $display("  x1: Hardware = %0d ", Single_Cycle.regfile.mainReg[1]);
            $display("  x2: Hardware = %0d ", Single_Cycle.regfile.mainReg[2]);
            $display("  x3: Hardware = %0d ",  Single_Cycle.regfile.mainReg[3]);
            $display("  x4: Hardware = %0d ", Single_Cycle.regfile.mainReg[4]);
            $display("  x5: Hardware = %0d ", Single_Cycle.regfile.mainReg[5]);  
            $display("  x6: Hardware = %0d ", Single_Cycle.regfile.mainReg[6]);  
            $display("\n single cycle cpu cycle count = %0d", single_count);      
            $display("\n");


            $display("\n CPI = %0f", (real'(pipeline_count) / single_count));


        $finish;

    end


endmodule