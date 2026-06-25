module Pipeline_reg(
    parameter Reg_size = 32;
)(
    input logic clk,
    input logic rst_n,
    input logic [Reg_size-1:0] data_in,

    output logic [Reg_size-1:0] data_out 
);


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) data_out <= Reg_size'd0;
        else data_out <= data_in;
    end

endmodule

