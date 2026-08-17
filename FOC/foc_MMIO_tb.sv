`timescale 1ns/1ps

module MMIO_tb;

    logic        clk;
    logic        rst_n;
    logic        mem_write;
    logic        mem_read;
    logic [31:0] addr; 
    logic [31:0] write_data; 

    logic [31:0] read_data;
    logic        pwm_ah, pwm_al;
    logic        pwm_bh, pwm_bl;
    logic        pwm_ch, pwm_cl;
    logic        adc_trigger;

    // Instantiate Unit Under Test (UUT)
    MMIO_FOC UUT (
        .clk(clk),
        .rst_n(rst_n),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data),
        .pwm_ah(pwm_ah),
        .pwm_al(pwm_al),
        .pwm_bh(pwm_bh),
        .pwm_bl(pwm_bl),
        .pwm_ch(pwm_ch),
        .pwm_cl(pwm_cl),
        .adc_trigger(adc_trigger)
    );

    // 100 MHz Clock Generation (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;

    // Helper task for MMIO Write
    task mmio_write(input [31:0] target_addr, input [31:0] data);
        @(posedge clk);
        addr       <= target_addr;
        write_data <= data;
        mem_write  <= 1'b1;
        mem_read   <= 1'b0;
        @(posedge clk);
        mem_write  <= 1'b0;
        addr       <= 32'd0;
        write_data <= 32'd0;
    endtask

    // Helper task for MMIO Read
    task mmio_read(input [31:0] target_addr);
        @(posedge clk);
        addr      <= target_addr;
        mem_read  <= 1'b1;
        mem_write <= 1'b0;
        @(posedge clk);
        #1; // Sample shortly after clock edge
        $display("[MMIO READ] Addr: 0x%08h | Data: 0x%08h (%0d)", target_addr, read_data, read_data);
        mem_read  <= 1'b0;
        addr      <= 32'd0;
    endtask

    initial begin
        $dumpfile("MMIO.vcd");
        $dumpvars(0, MMIO_tb);

        // Initialize inputs & assert reset
        rst_n      = 0;
        mem_write  = 0;
        mem_read   = 0;
        addr       = 0;
        write_data = 0;

        #20;
        rst_n = 1;
        #20;

        // Write angle to CORDIC (0x8000_0000)
        $display("\n--- Writing CORDIC Angle ---");
        mmio_write(32'h8000_0000, 32'd16384); // 16384 = ~45 deg in Q16
        $display("FOC_Reg[0] holds: %0d", UUT.FOC_Reg[0]);

        // Write PWM Parameters
        $display("\n--- Writing PWM Duty Cycles ---");
        mmio_write(32'h8000_0008, 32'd5000); // Period Max
        mmio_write(32'h8000_000C, 32'd2500); // Duty A
        mmio_write(32'h8000_0010, 32'd1500); // Duty B
        mmio_write(32'h8000_0014, 32'd3500); // Duty C

        // Read back PWM Duty A to verify MMIO Read Path
        $display("\n--- Reading Back Registers ---");
        mmio_read(32'h8000_000C);

        // Wait for CORDIC pipeline (16 cycles) and read Status/Results
        repeat (20) @(posedge clk);
        mmio_read(32'h8000_0020); // Status / out_valid
        mmio_read(32'h8000_0018); // sin_out
        mmio_read(32'h8000_001C); // cos_out

        #50;
        $display("\nTestbench finished successfully.");
        $finish;
    end

endmodule