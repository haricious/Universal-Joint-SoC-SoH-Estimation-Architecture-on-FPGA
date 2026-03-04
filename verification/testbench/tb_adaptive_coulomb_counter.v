`timescale 1ns/1ps

module tb_adaptive_coulomb_counter;

    reg clk;
    reg rst_n;
    reg cc_en;
    reg signed [15:0] current_i;
    wire [15:0] soc_o;

    integer cur_file;
    integer soc_log;
    integer status;

    // ================= DUT =================
    adaptive_coulomb_counter dut (
        .clk(clk),
        .rst_n(rst_n),
        .cc_en(cc_en),
        .current_i(current_i),
        .soc_o(soc_o)
    );

    // ================= CLOCK =================
    initial clk = 0;
    always #5 clk = ~clk;   // 100 MHz

    // ================= WAVE DUMP =================
    initial begin
        $dumpfile("cc_wave.vcd");
        $dumpvars(0, tb_adaptive_coulomb_counter);
    end

    // ================= STIMULUS =================
    initial begin
        rst_n      = 0;
        cc_en     = 0;
        current_i = 0;

        // Open input vector
        cur_file = $fopen(
            "D:/Projects/Mark_I_BMS/mark_I_bms/matlab_model/vectors/stim_current.hex",
            "r"
        );

        if (cur_file == 0) begin
            $display("ERROR: Cannot open stim_current.hex");
            $finish;
        end

        // Open output log
        soc_log = $fopen("soc_rtl.txt", "w");
        if (soc_log == 0) begin
            $display("ERROR: Cannot open soc_rtl.txt");
            $finish;
        end

        // Release reset
        #20;
        rst_n = 1;
        cc_en = 1;

        // Main stimulus loop
        while (!$feof(cur_file)) begin
            status = $fscanf(cur_file, "%h\n", current_i);
            @(posedge clk);
            $display("I = %d | SoC = %d", current_i, soc_o);
            $fwrite(soc_log, "%0d\n", soc_o);
        end

        // Cleanup
        $fclose(cur_file);
        $fclose(soc_log);

        $display("Simulation finished.");
        #20;
        $finish;
    end

endmodule
