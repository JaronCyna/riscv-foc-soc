`timescale 1ns/1ps
module SoC_tb;

    logic        clk;
    logic        rst_n;

    logic [31:0] SoC_out
    logic        pwm_ah, pwm_al;
    logic        pwm_bh, pwm_bl;
    logic        pwm_ch, pwm_cl;
    logic        adc_trigger;

    SoC Top_SOC(
        .clk(clk),
        .rst_n(rst_n),

        .SoC_out(SoC_out),
        .pwm_ah(pwm_ah),
        .pwm_al(pwm_al),
        .pwm_bh(pwm_bh),
        .pwm_bl(pwm_bl),
        .pwm_ch(pwm_ch),
        .pwm_cl(pwm_cl),
        .adc_trigger(adc_trigger)
    );

    initial clk = 0;
    always #5 clk = ~clk;


endmodule