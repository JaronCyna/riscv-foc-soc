module alu_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0] sel;

    logic [31:0] out;
    logic zero;

    ALU ArithmaticLU(
            .a(a), 
            .b(b), 
            .sel(sel), 
            .out(out),
            .zero(zero)
            );

    
    initial begin


        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);

        //Testing all cases:

        //Test 1: Addition
        a = 32'd4;
        b = 32'd9;
        sel = 4'd0;
        #1;

        if (out == a+b && zero == 0) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out, a+b);
        end

        //Test 2: Subtraction
        sel = 4'd1;
        #1;

        if (out == a-b && zero == 0) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out, a-b);
        end

        //Test 3: AND
        sel = 4'd2;
        #1;

        if (out == (a&b) && zero == 1) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out, a&b);
        end
        
        //Test 4: OR
        sel = 4'd3;
        #1;

        if (out == a|b && zero == 0) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out, a|b);
        end

        //Test 5: XOR
        sel = 4'd4;
        #1;

        if (out == a^b && zero == 0) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out, a^b);
        end

        //Test 6: shift left
        sel = 4'd5;
        #1;

        if (out == a<<b[4:0] && zero == 0) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out, a<<b[4:0]);
        end

        //Test 7: shift right
        sel = 4'd6;
        a = 32'd5;
        b = 32'd2;
        #1;

        if (out == a>>b[4:0] && zero == 0) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out, a>>b[4:0]);
        end

        //Test 8: shift right (signed)
        sel = 4'd7;
        a = -32'd5;
        #1;

        if ($signed(out) == ($signed(a) >>> b[4:0]) && zero == 0) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out,  $signed(a) >>> b[4:0]);
        end

        //Test 9: signed compare
        sel = 4'd8;
        #1;

        if (out == {31'b0, ($signed(a) < $signed(b))} && zero == 0) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out,  $signed(a) < $signed(b));
        end

        // Test 10: compare
        sel = 4'd9;
        a = 32'd5;
        #1;

        if (out == a<b && zero == 1) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out, a<b);
        end

        //Test 11: zero
        sel = 4'd1;
        a = 32'd1;
        b = 32'd1;
        #1;

        if (out == a-b && zero == 1) begin
            $display("Success: out = %d", out);
        end
        else begin
            $display("Fail: out = %d, should be %d", out,  a-b);
        end
        
        
        $finish;       


    end

endmodule