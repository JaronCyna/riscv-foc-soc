`timescale 1ns/1ps

module pwm_3phase(
    input  logic        clk,
    input  logic        rst_n,
    input  logic [15:0] dead_time_cycles,
    input  logic [15:0] period_max,
    input  logic [15:0] duty_a, duty_b, duty_c,

    output logic        pwm_ah, pwm_al, pwm_bh, pwm_bl, pwm_ch, pwm_cl,
    output logic        adc_trigger
);

    logic [15:0] counter;
    logic        down;

    // 1-bit raw PWM signals
    logic raw_pwm_ah, raw_pwm_al;
    logic raw_pwm_bh, raw_pwm_bl;
    logic raw_pwm_ch, raw_pwm_cl;

    // High and Low side delay counters per phase
    logic [15:0] delay_ah, delay_al;
    logic [15:0] delay_bh, delay_bl;
    logic [15:0] delay_ch, delay_cl;

    assign adc_trigger = (counter == period_max);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 16'b0;
            down    <= 1'b0;
        end else begin
            if (down) begin
                if (counter == 16'b0) begin
                    down    <= 1'b0;
                    counter <= counter + 1'b1;
                end else begin
                    counter <= counter - 1'b1;
                end
            end else begin
                if (counter >= period_max) begin
                    down    <= 1'b1;
                    counter <= counter - 1'b1;
                end else begin
                    counter <= counter + 1'b1;
                end
            end
        end
    end

    assign raw_pwm_ah = (counter <= duty_a);
    assign raw_pwm_al = !raw_pwm_ah;

    assign raw_pwm_bh = (counter <= duty_b);
    assign raw_pwm_bl = !raw_pwm_bh;

    assign raw_pwm_ch = (counter <= duty_c);
    assign raw_pwm_cl = !raw_pwm_ch;


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_ah   <= 1'b0;
            delay_ah <= 16'b0;
            pwm_al   <= 1'b0;
            delay_al <= 16'b0;
        end else begin
            // High-Side
            if (!raw_pwm_ah) begin
                pwm_ah   <= 1'b0; 
                delay_ah <= 16'b0;
            end else if (delay_ah >= dead_time_cycles) begin
                pwm_ah   <= 1'b1;
            end else begin
                delay_ah <= delay_ah + 1'b1;
            end

            // Low-Side
            if (!raw_pwm_al) begin
                pwm_al   <= 1'b0; 
                delay_al <= 16'b0;
            end else if (delay_al >= dead_time_cycles) begin
                pwm_al   <= 1'b1; 
            end else begin
                delay_al <= delay_al + 1'b1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_bh   <= 1'b0;
            delay_bh <= 16'b0;
            pwm_bl   <= 1'b0;
            delay_bl <= 16'b0;
        end else begin
            // High-Side
            if (!raw_pwm_bh) begin
                pwm_bh   <= 1'b0;
                delay_bh <= 16'b0;
            end else if (delay_bh >= dead_time_cycles) begin
                pwm_bh   <= 1'b1;
            end else begin
                delay_bh <= delay_bh + 1'b1;
            end

            // Low-Side
            if (!raw_pwm_bl) begin
                pwm_bl   <= 1'b0;
                delay_bl <= 16'b0;
            end else if (delay_bl >= dead_time_cycles) begin
                pwm_bl   <= 1'b1;
            end else begin
                delay_bl <= delay_bl + 1'b1;
            end
        end
    end


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_ch   <= 1'b0;
            delay_ch <= 16'b0;
            pwm_cl   <= 1'b0;
            delay_cl <= 16'b0;
        end else begin
            // High-Side
            if (!raw_pwm_ch) begin
                pwm_ch   <= 1'b0;
                delay_ch <= 16'b0;
            end else if (delay_ch >= dead_time_cycles) begin
                pwm_ch   <= 1'b1;
            end else begin
                delay_ch <= delay_ch + 1'b1;
            end

            // Low-Side
            if (!raw_pwm_cl) begin
                pwm_cl   <= 1'b0;
                delay_cl <= 16'b0;
            end else if (delay_cl >= dead_time_cycles) begin
                pwm_cl   <= 1'b1;
            end else begin
                delay_cl <= delay_cl + 1'b1;
            end
        end
    end

endmodule