module cordic_tb;

    logic               clk;
    logic               rst_n;
    logic               in_valid;
    logic signed [31:0] angle_in;

    logic               out_valid;
    logic signed [31:0] sin_out, cos_out;

    // Instantiate CORDIC module
    cordic sincos (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .angle_in(angle_in),
        .out_valid(out_valid),
        .sin_out(sin_out),
        .cos_out(cos_out)
    );

    // 100 MHz Clock (10ns period)
    parameter CLK_PERIOD = 10;
    initial clk = 0; 
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        $dumpfile("cordic.vcd");
        $dumpvars(0, cordic_tb);

        rst_n    = 0;
        in_valid = 0;
        angle_in = 0;

        #20;
        rst_n = 1;
        #10;

        for (int i = -2; i < 3; i++) begin
            @(posedge clk);
            in_valid <= 1'b1;
            // i * 45 degrees (45 deg = 0.7854 rad = 32'h0000_C90F in Q16.16)
            angle_in <= 32'sh0000_C90F * i; 
        end

        @(posedge clk);
        in_valid <= 1'b0;

        repeat (20) @(posedge clk);

        $display("\nSimulation finished!");
        $finish;
    end

    always @(posedge clk) begin
        if (out_valid) begin
            $display("[t=%0t ns] OUTPUT VALID | Sin: %8.4f (0x%08h) | Cos: %8.4f (0x%08h)", 
                     $time, 
                     $itor(sin_out) / 65536.0, sin_out,
                     $itor(cos_out) / 65536.0, cos_out);
        end
    end

endmodule