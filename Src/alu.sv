module ALU(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] sel,

    output logic [31:0] out,
    output logic zero
);

    logic [4:0] shift;
    assign shift = b[4:0];

    always_comb begin
        case(sel)

            4'd00: out = a+b;                           //add
            4'd01: out = a-b;                           //sub
            4'd02: out = a&b;                           //and
            4'd03: out = a|b;                           //or
            4'd04: out = a^b;                           //xor
            4'd05: out = a << shift;                    //shift left
            4'd06: out = a >> shift;                    //shift right
            4'd07: out = $signed(a) >>> shift;          //shift right signed
            4'd08: out = $signed(a) < $signed(b);       //compare signed
            4'd09: out = a < b;                         //compare

            default: out = 32'h0;

            
        endcase

        if(out == 32'h0)
            zero = 1;
        else
            zero = 0;
            
    end




endmodule