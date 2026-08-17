module MMIO_FOC(
    input logic         clk,
    input logic         rst_n,
    input logic         mem_write,
    input logic         mem_read,
    input logic [31:0]  addr, 
    input logic [31:0]  write_data, 

    output logic [31:0] read_data,
    output logic        pwm_ah, pwm_al,
    output logic        pwm_bh, pwm_bl,
    output logic        pwm_ch, pwm_cl,
    output logic        adc_trigger
);

    logic [31:0] FOC_Reg [5:0];

    logic in_valid;
    logic signed [31:0] angle_in;

    logic out_valid;
    logic signed [31:0] sin_out;
    logic signed [31:0] cos_out;

    assign in_valid = mem_write && (addr == 32'h8000_0000);

    cordic CORDIC(
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .angle_in(angle_in),

        .out_valid(out_valid),
        .sin_out(sin_out),
        .cos_out(cos_out)
    );

    logic [15:0] dead_time_cycles;
    logic [15:0] period_max;
    logic [15:0] duty_a; 
    logic [15:0] duty_b;
    logic [15:0] duty_c;

    pwm_3phase PWM(
        .clk(clk),
        .rst_n(rst_n),
        .dead_time_cycles(dead_time_cycles),
        .period_max(period_max),
        .duty_a(duty_a),
        .duty_b(duty_b),
        .duty_c(duty_c),

        .pwm_ah(pwm_ah),
        .pwm_al(pwm_al),
        .pwm_bh(pwm_bh),
        .pwm_bl(pwm_bl),
        .pwm_ch(pwm_ch),
        .pwm_cl(pwm_cl),
        .adc_trigger(adc_trigger)
    );

    assign angle_in         = FOC_Reg[0];
    assign dead_time_cycles = FOC_Reg[1][15:0];
    assign period_max       = FOC_Reg[2][15:0];
    assign duty_a           = FOC_Reg[3][15:0];
    assign duty_b           = FOC_Reg[4][15:0];
    assign duty_c           = FOC_Reg[5][15:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 6; i++) begin
                FOC_Reg[i] <= 32'd0;
            end
        end else begin
                if(mem_write) begin
                    case(addr)
                        32'h8000_0000: FOC_Reg[0] <= write_data;
                        32'h8000_0004: FOC_Reg[1] <= {16'b0, write_data[15:0]};
                        32'h8000_0008: FOC_Reg[2] <= {16'b0, write_data[15:0]};
                        32'h8000_000C: FOC_Reg[3] <= {16'b0, write_data[15:0]};
                        32'h8000_0010: FOC_Reg[4] <= {16'b0, write_data[15:0]};
                        32'h8000_0014: FOC_Reg[5] <= {16'b0, write_data[15:0]};
                        default: ;
                    endcase
            end 

        end

    end

    always_comb begin
        read_data = 32'd0;
        if (mem_read) begin
            case(addr)
                32'h8000_0000: read_data = FOC_Reg[0];
                32'h8000_0004: read_data = FOC_Reg[1];
                32'h8000_0008: read_data = FOC_Reg[2];
                32'h8000_000C: read_data = FOC_Reg[3];
                32'h8000_0010: read_data = FOC_Reg[4];
                32'h8000_0014: read_data = FOC_Reg[5];
                32'h8000_0018: read_data = sin_out;
                32'h8000_001C: read_data = cos_out;
                32'h8000_0020: read_data = {31'b0, out_valid};
                default:       read_data = 32'd0;
            endcase
        end
    end


endmodule