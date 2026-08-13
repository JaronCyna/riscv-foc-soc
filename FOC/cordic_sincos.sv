module cordic(
    input logic clk,
    input logic rst_n,
    input logic in_valid,
    input logic signed [31:0] angle_in,

    output logic out_valid,
    output logic signed [31:0] sin_out, cos_out
);


    logic signed [31:0] x_middle [0:16];
    logic signed [31:0] y_middle [0:16];
    logic signed [31:0] z_middle [0:16];

    logic signed [31:0] folded_angle;
    logic flip;

    always_comb begin
        if(angle_in > 32'sh0001921F) begin
            flip = 1'b1;
            folded_angle = angle_in - 32'sh0003_243F;
        end else if (angle_in < -32'sh0001921F) begin
            flip = 1'b1;
            folded_angle = angle_in + 32'sh0003_243F;
        end else begin
            flip = 1'b0;
            folded_angle = angle_in;
        end
    end


    assign x_middle[0] = 32'h00009B6F;
    assign y_middle[0] = 32'b0;
    assign z_middle[0] = folded_angle;


logic signed [31:0] ARCTAN_LUT [0:15];

assign ARCTAN_LUT[0]  = 32'h0000_C90F; // atan(2^-0)  = 0.785398 rad
assign ARCTAN_LUT[1]  = 32'h0000_76B1; // atan(2^-1)  = 0.463648 rad
assign ARCTAN_LUT[2]  = 32'h0000_3EB6; // atan(2^-2)  = 0.244979 rad
assign ARCTAN_LUT[3]  = 32'h0000_1FD5; // atan(2^-3)  = 0.124355 rad
assign ARCTAN_LUT[4]  = 32'h0000_0FEA; // atan(2^-4)  = 0.062419 rad
assign ARCTAN_LUT[5]  = 32'h0000_07F5; // atan(2^-5)  = 0.031240 rad
assign ARCTAN_LUT[6]  = 32'h0000_03FB; // atan(2^-6)  = 0.015624 rad
assign ARCTAN_LUT[7]  = 32'h0000_01FD; // atan(2^-7)  = 0.007812 rad
assign ARCTAN_LUT[8]  = 32'h0000_00FE; // atan(2^-8)  = 0.003906 rad
assign ARCTAN_LUT[9]  = 32'h0000_007F; // atan(2^-9)  = 0.001953 rad
assign ARCTAN_LUT[10] = 32'h0000_003F; // atan(2^-10) = 0.000977 rad
assign ARCTAN_LUT[11] = 32'h0000_001F; // atan(2^-11) = 0.000488 rad
assign ARCTAN_LUT[12] = 32'h0000_000F; // atan(2^-12) = 0.000244 rad
assign ARCTAN_LUT[13] = 32'h0000_0007; // atan(2^-13) = 0.000122 rad
assign ARCTAN_LUT[14] = 32'h0000_0003; // atan(2^-14) = 0.000061 rad
assign ARCTAN_LUT[15] = 32'h0000_0001; // atan(2^-15) = 0.000030 rad

    genvar i; 
    logic [15:0] valid_pipeline;
    logic [15:0] flip_pipeline;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_pipeline <= 16'b0;
            flip_pipeline  <= 16'b0;
        end else begin
            // Shift in_valid and flip into bit 0, shift everything left
            valid_pipeline <= {valid_pipeline[14:0], in_valid};
            flip_pipeline  <= {flip_pipeline[14:0], flip};
        end
    end

    generate
        for (i = 0; i < 16; i++) begin : gen_buffers
            cordic_stage #(.STEP(i)) u_stage
            (
                .clk(clk),
                .rst_n(rst_n),
                .LUT_angle(ARCTAN_LUT[i]),
                .xin(x_middle[i]), 
                .yin(y_middle[i]), 
                .zin(z_middle[i]),

                .xout(x_middle[i+1]),
                .yout(y_middle[i+1]), 
                .zout(z_middle[i+1])
            );
        end
    endgenerate

    assign sin_out = (flip_pipeline[15]) ? -y_middle[16] : y_middle[16];
    assign cos_out = (flip_pipeline[15]) ? -x_middle[16] : x_middle[16];
    assign out_valid = valid_pipeline[15];


endmodule