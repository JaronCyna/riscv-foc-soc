module Fwd_Unit_tb;

    logic [4:0] rs1_EX;
    logic [4:0] rs2_EX;
    logic [4:0] rw_MEM;
    logic [4:0] rw_WB;
    logic [1:0] control_bits_WB;
    logic [1:0] control_bits_MEM;

    logic [1:0] fwd1;
    logic [1:0] fwd2;

    class forward_class;
        rand logic [4:0] rs1_val;
        rand logic [4:0] rs2_val;
        rand logic [4:0] rw_mem_val;
        rand logic [4:0] rw_wb_val;
        rand logic [1:0] ctrl_mem_val;
        rand logic [1:0] ctrl_wb_val;

        constraint register_lim {
            rs1_val    inside {[1:5]}; 
            rs2_val    inside {[1:5]};
            rw_mem_val inside {[1:5]};
            rw_wb_val  inside {[1:5]};           
        }

        constraint Ctrl_lim {
            ctrl_mem_val inside {[0:1]};
            ctrl_wb_val  inside {[0:1]};
        }

    endclass

    Fwd_Unit Forward_Unit(
        .rs1_EX(rs1_EX),
        .rs2_EX(rs2_EX),
        .rw_MEM(rw_MEM),
        .rw_WB(rw_WB),
        .control_bits_WB(control_bits_WB),
        .control_bits_MEM(control_bits_MEM),
        
        .fwd1(fwd1),
        .fwd2(fwd2)
    );

    initial begin
        $dumpfile("Fwd_Unit.vcd");
        $dumpvars(0, Fwd_Unit_tb);

        forward_class tx;
        tx = new();

        repeat (1000) begin

            if (!tx.randomize()) $fatal("Randomization failed");

            rs1_EX           = tx.rs1_val;
            rs2_EX           = tx.rs2_val;
            rw_MEM           = tx.rw_mem_val;
            rw_WB            = tx.rw_wb_val;
            control_bits_MEM = tx.ctrl_mem_val;
            control_bits_WB  = tx.ctrl_wb_val;

            #10; 

        end
        
        $display("Simulation complete. 1000 randomized cycles executed.");
        $finish;
    end

endmodule