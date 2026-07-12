module Hazard_Unit_tb;

    logic [4:0] rw_EX;
    logic [4:0] rs1_ID;
    logic [4:0] rs2_ID;
    logic MemRead_EX;
    
    logic PCWrite;
    logic IF_IDWrite;
    logic bubble;

    class forward_class;
        rand logic [4:0] rw_EX_val;
        rand logic [4:0] rs1_ID_val;
        rand logic [4:0] rs2_ID_val;
        rand logic       MemRead_EX_val;

        constraint register_lim {
            rw_EX_val  inside {[0:5]}; 
            rs1_ID_val inside {[1:5]};
            rs2_ID_val inside {[1:5]};
        }

        constraint hazard_distribution {
            MemRead_EX_val dist {1'b1 := 50, 1'b0 := 50};

            rs1_ID_val dist {rw_EX_val := 20, [1:5] := 80};
            rs2_ID_val dist {rw_EX_val := 20, [1:5] := 80};
        }

    endclass

    Hazard_Unit Haz_Unit(
        .rw_EX(rw_EX),
        .rs1_ID(rs1_ID),
        .rs2_ID(rs2_ID),
        .MemRead_EX(MemRead_EX),
        .PCWrite(PCWrite),
        .IF_IDWrite(IF_IDWrite),
        .bubble(bubble)
    );

    initial begin
        $dumpfile("Hazard_Unit.vcd");
        $dumpvars(0, Hazard_Unit_tb);

        forward_class tx;
        tx = new();

        repeat (1000) begin

            if (!tx.randomize()) $fatal("Randomization failed");

            rw_EX      = tx.rw_EX_val;
            rs1_ID     = tx.rs1_ID_val;
            rs2_ID     = tx.rs2_ID_val;
            MemRead_EX = tx.MemRead_EX_val;

            #10;
                
           if (bubble == 1'b1) begin
                assert (PCWrite == 1'b0) else $error("Failed: Bubble inserted but PC didn't freeze!");
                assert (IF_IDWrite == 1'b0) else $error("Failed: Bubble inserted but Decode didn't freeze!");
            end

            if (MemRead_EX == 1'b0) begin
                assert (bubble == 1'b0) else $error("Failed: Stalled the pipeline for a non-load instruction!");
            end

            if (rw_EX == 5'd0) begin
                assert (bubble == 1'b0) else $error("Failed: Stalled on a write to x0!");
            end

        end 
        
        $display("Simulation complete. 1000 randomized cycles executed.");
        $finish;
    end

endmodule