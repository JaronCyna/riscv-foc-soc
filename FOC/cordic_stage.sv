module cordic_stage#(
    parameter int STEP = 0  // Stage index (0 to 15)
)(
    input logic clk,
    input logic rst_n,
    input logic signed [31:0] LUT_angle,
    input logic signed [31:0] xin, yin, zin,
    

    output logic signed [31:0] xout, yout, zout
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            xout <= 32'b0;
            yout <= 32'b0;
            zout <= 32'b0;
        end else begin
            if (!zin[31]) begin
                xout <= xin - ($signed(yin) >>> STEP);
                yout <= yin + ($signed(xin) >>> STEP);
                zout <= zin - LUT_angle;          
            end
            else begin
                xout <= xin + ($signed(yin) >>> STEP);
                yout <= yin - ($signed(xin) >>> STEP);
                zout <= zin + LUT_angle;          
            end
        end

    end

endmodule