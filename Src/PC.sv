module PC_reg(
    input  logic clk, rst_n, branch_taken, en,
    input  logic [31:0] branch_target,
    output logic [31:0] pc_out
);

always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
        pc_out <= 32'h0;
    end else begin
        if (branch_taken && en) begin
            pc_out <= branch_target;

        end else if (en) begin
            pc_out <= pc_out + 32'd4;

        end
        
    end


end

endmodule