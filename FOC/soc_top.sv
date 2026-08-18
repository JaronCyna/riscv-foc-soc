module SoC(
    input logic         clk,
    input logic         rst_n,

    output logic [31:0] SoC_out,
    output logic        pwm_ah, pwm_al,
    output logic        pwm_bh, pwm_bl,
    output logic        pwm_ch, pwm_cl,
    output logic        adc_trigger
);

    logic [31:0] read_MEM;

    logic [31:0] out;
    logic [31:0] addr;
    logic [31:0] rd_out_MEM;
    logic memWrite_MEM;
    logic memRead_MEM;
    
    rv32i_5stage_core _5_stage(
        .clk(clk),
        .rst_n(rst_n),
        .read_MEM(read_MEM),

        .out(out),
        .out_MEM(addr),
        .rd_out_MEM(rd_out_MEM),
        .memWrite_MEM(memWrite_MEM),
        .memRead_MEM(memRead_MEM)
    );

    assign SoC_out = out;

    logic        mem_write;
    logic        mem_read;

    logic [31:0] read_data;
  
    MMIO_FOC FOC(
        .clk(clk),
        .rst_n(rst_n),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .addr(addr),
        .write_data(rd_out_MEM),

        .read_data(read_data),
        .pwm_ah(pwm_ah),
        .pwm_al(pwm_al),
        .pwm_bh(pwm_bh),
        .pwm_bl(pwm_bl),
        .pwm_ch(pwm_ch),
        .pwm_cl(pwm_cl),
        .adc_trigger(adc_trigger)
    );

        logic data_memRead;
        logic data_memWrite;
        logic [31:0] dataMEM_read;

        DataMem datamem(
        .clk(clk),
        .memRead(data_memRead),
        .memWrite(data_memWrite),
        .addr(addr),
        .write(rd_out_MEM),

        .read(dataMEM_read)
    );


    always_comb begin
        if(addr[31]) begin
            data_memRead = 0;
            data_memWrite = 0;
            mem_read = memRead_MEM;
            mem_write = memWrite_MEM;
            read_MEM = read_data;

        end else begin
            data_memRead = memRead_MEM;
            data_memWrite = memWrite_MEM;
            mem_read = 0;
            mem_write = 0;
            read_MEM = dataMEM_read;

        end
    end

endmodule