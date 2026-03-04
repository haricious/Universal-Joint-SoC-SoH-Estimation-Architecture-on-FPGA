`timescale 1ns/1ps

module soc_soh_tb;

////////////////////////////////////////////////////////////
// Clock
////////////////////////////////////////////////////////////

reg clk = 0;
always #5 clk = ~clk;   // 100 MHz clock

////////////////////////////////////////////////////////////
// Inputs
////////////////////////////////////////////////////////////

reg rst;
reg [1:0] chemistry_select;

reg signed [15:0] current;
reg signed [15:0] voltage_meas;
reg signed [15:0] dt;

////////////////////////////////////////////////////////////
// Outputs
////////////////////////////////////////////////////////////

wire signed [15:0] soc_est;
wire signed [15:0] voltage_est;
wire signed [15:0] innovation;

////////////////////////////////////////////////////////////
// DUT
////////////////////////////////////////////////////////////

top_universal_soc_soh DUT(

    .clk(clk),
    .rst(rst),
    .chemistry_select(chemistry_select),

    .current(current),
    .voltage_meas(voltage_meas),
    .dt(dt),

    .soc_est(soc_est),
    .voltage_est(voltage_est),
    .innovation(innovation)

);

////////////////////////////////////////////////////////////
// Stimulus
////////////////////////////////////////////////////////////

initial begin

    $display("---- SOC Baseline Simulation Started ----");

    rst = 1;

    chemistry_select = 2'b00;   // Li-ion

    current = 16'sd128;        // ~0.5A discharge
    voltage_meas = 16'sd960;   // ~3.75V
    dt = 16'sh0100;            // 1 second step

    #100;
    rst = 0;

    #200000;

    $display("---- Simulation Finished ----");

    $finish;

end

////////////////////////////////////////////////////////////
// Monitor
////////////////////////////////////////////////////////////

always @(posedge clk) begin

    if(!rst) begin

        $display("Time=%0t | SOC=%.2f | V_est=%.3f | Innov=%.4f",
            $time,
            soc_est/256.0,
            voltage_est/256.0,
            innovation/256.0
        );

    end

end

endmodule