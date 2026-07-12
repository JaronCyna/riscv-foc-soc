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

            // Rule for Operand A
            if (control_bits_MEM[0] && (rw_MEM != 5'd0) && (rw_MEM == rs1_EX)) begin
                assert (fwd1 == 2'b10) 
                    else $error("Failed: Failed to forward rs1 from MEM stage! Expected 2'b10, got %b", fwd1);
            end

            // Rule for Operand B
            if (control_bits_MEM[0] && (rw_MEM != 5'd0) && (rw_MEM == rs2_EX)) begin
                assert (fwd2 == 2'b10) 
                    else $error("Failed: Failed to forward rs2 from MEM stage! Expected 2'b10, got %b", fwd2);
            end

            // Rule for Operand A
            if (control_bits_WB[0] && (rw_WB != 5'd0) && (rw_WB == rs1_EX) && 
                !(control_bits_MEM[0] && (rw_MEM != 5'd0) && (rw_MEM == rs1_EX))) begin
                assert (fwd1 == 2'b01) 
                    else $error("Failed: Failed to forward rs1 from WB stage! Expected 2'b01, got %b", fwd1);
            end

            if (rw_MEM == 5'd0 || rw_WB == 5'd0) begin
            if (rs1_EX == 5'd0) assert (fwd1 == 2'b00) else $error("Failed: Accidentally forwarded a value to rs1 from x0!");
            if (rs2_EX == 5'd0) assert (fwd2 == 2'b00) else $error("Failed: Accidentally forwarded a value to rs2 from x0!");
            end

            if (!control_bits_MEM[0] && !control_bits_WB[0]) begin
                assert (fwd1 == 2'b00) else $error("Failed: Forwarded rs1 when RegWrite was disabled!");
                assert (fwd2 == 2'b00) else $error("Failed: Forwarded rs2 when RegWrite was disabled!");
            end

        end
        
        $display("Simulation complete. 1000 randomized cycles executed.");
        $finish;
    end

endmodule