module DataMem(
    input logic clk,
    input logic memRead,
    input logic memWrite,
    input logic [31:0] addr,
    input logic [31:0] write,

    output logic [31:0] read
);

    logic [31:0] RAM [0:127];

    initial begin
        for (int i = 0; i < 128; i++) begin
            RAM[i] = 32'd0;
        end
    end

    logic [6:0] word_index;
    assign word_index = addr[8:2];

    always_ff @(posedge clk) begin
        if (memWrite == 1'b1) begin
            RAM[word_index] <= write; 
        end
    end
    
    always_comb begin
        if (memRead == 1'b1) begin
            read = RAM[word_index];
        end else begin
            read = 32'd0; 
        end
    end

endmodule