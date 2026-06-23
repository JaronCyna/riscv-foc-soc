module debouncer(
    input logic raw_btn,
    input logic clk,
    input logic rst_n,

    output logic clean_btn
);

    logic [19:0] counter;
    logic        last_btn;


    always_ff @(posedge clk) begin
        
        if(rst_n == 1'b0) begin
            clean_btn <= 1'b0;
            last_btn  <= 1'b0;
            counter   <= 20'd0;
        end else begin

            if(last_btn != raw_btn) begin
                counter <= counter + 20'd1;
            end else begin
                counter <= 20'd0;
            end

            if (counter == (2**20-1))begin
                last_btn <= raw_btn;
                clean_btn <= raw_btn;
                counter <=  1'b0;
                
            end
        end
    end

endmodule