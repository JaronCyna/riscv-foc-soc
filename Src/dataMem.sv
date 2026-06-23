module DataMem(
    input logic        clk,
    input logic        memRead,
    input logic        memWrite,
    input logic [31:0] addr,
    input logic [31:0] write,

    output logic [31:0] read
);

    // 128 rows of 32-bit memory
    logic [31:0] RAM [0:127];

    // Safe Power-up/Simulation Initialization (Maps perfectly to BRAM config)
    initial begin
        for (int i = 0; i < 128; i++) begin
            RAM[i] = 32'd0;
        end
    end

    // Word indexing calculation 
    logic [6:0] word_index;
    assign word_index = addr[8:2];

    // Synchronous Write Path: No global reset loop to save hardware resources
    always_ff @(posedge clk) begin
        if (memWrite == 1'b1) begin
            RAM[word_index] <= write; 
        end
    end
    
    // Combinational Read Path
    always_comb begin
        if (memRead == 1'b1) begin
            read = RAM[word_index];
        end else begin
            read = 32'd0; 
        end
    end

endmodule