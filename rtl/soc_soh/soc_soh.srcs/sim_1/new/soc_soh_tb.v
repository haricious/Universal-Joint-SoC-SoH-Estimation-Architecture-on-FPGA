`timescale 1ns/1ps

module soc_soh_tb;

reg clk = 0;
always #5 clk = ~clk;   // 10ns clock

reg rst;
reg [1:0] chemistry_select;
reg signed [15:0] current;
reg signed [15:0] dt;

wire signed [15:0] soc_est;
wire signed [15:0] voltage_est;
wire signed [15:0] innovation;

// Inject small measurement offset (~0.02V)
wire signed [15:0] voltage_meas;
assign voltage_meas = voltage_est + 16'sd5;

// DUT
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

initial begin

    $display("---- EKF Mid-SOC Test Started ----");

    rst = 1;
    chemistry_select = 2'b00;   // Li-ion
    current = 16'sd128;         // 0.5A discharge
    dt      = 16'sh0100;        // 1 second per clock

    #30 rst = 0;

    // Run only a few simulated seconds
    #100000;

    $display("---- Simulation Finished ----");
    $finish;
end


// Print useful debug info
always @(posedge clk) begin
    if (!rst) begin
        $display("Time=%0t | SOC=%.3f | V=%.3f | Innov=%.4f",
                 $time,
                 soc_est/256.0,
                 voltage_est/256.0,
                 innovation/256.0);
    end
end

endmodule