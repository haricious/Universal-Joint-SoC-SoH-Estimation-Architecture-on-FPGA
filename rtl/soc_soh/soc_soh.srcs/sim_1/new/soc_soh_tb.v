`timescale 1ns/1ps

module soc_soh_tb;

////////////////////////////////////////////////////////////
// Clock
////////////////////////////////////////////////////////////

reg clk = 0;
always #5 clk = ~clk;   // 100 MHz

////////////////////////////////////////////////////////////
// Inputs
////////////////////////////////////////////////////////////

reg rst;
reg [1:0] chemistry_select;

reg signed [15:0] current;
reg signed [15:0] dt;

////////////////////////////////////////////////////////////
// Outputs
////////////////////////////////////////////////////////////

wire signed [15:0] soc_est;
wire signed [15:0] voltage_est;
wire signed [15:0] innovation;

// Debug outputs
wire signed [15:0] K1_debug;
wire signed [15:0] delta_soc_debug;

////////////////////////////////////////////////////////////
// Measured voltage (plant + noise)
////////////////////////////////////////////////////////////

wire signed [15:0] voltage_meas;

assign voltage_meas = voltage_est + 16'sd40;   // ≈0.156 V offset

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
    .innovation(innovation),

    // Debug connections
    .K1_debug(K1_debug),
    .delta_soc_debug(delta_soc_debug)
);

////////////////////////////////////////////////////////////
// Stimulus
////////////////////////////////////////////////////////////

initial begin

    $display("---- EKF SOC Simulation Started ----");

    rst = 1;

    chemistry_select = 2'b00;   // Li-ion

    current = 16'sd128;         // ~0.5A discharge
    dt      = 16'sh0100;        // 1 second step

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

        $display(
        "Time=%0t | SOC=%.2f | V_est=%.3f | V_meas=%.3f | Innov=%.4f | K1=%.4f | dSOC=%.6f",
            $time,
            soc_est/256.0,
            voltage_est/256.0,
            voltage_meas/256.0,
            innovation/256.0,
            K1_debug/256.0,
            delta_soc_debug/256.0
        );

    end

end

endmodule