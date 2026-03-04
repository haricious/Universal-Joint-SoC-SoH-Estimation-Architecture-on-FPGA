module top_universal_soc_soh(

    input clk,
    input rst,
    input [1:0] chemistry_select,

    input signed [15:0] current,
    input signed [15:0] voltage_meas,
    input signed [15:0] dt,

    output signed [15:0] soc_est,
    output signed [15:0] voltage_est,
    output signed [15:0] innovation

);

wire signed [15:0] R0;
wire signed [15:0] C_eff;
wire signed [15:0] eta;
wire signed [15:0] a;
wire signed [15:0] b;

parameter_bank pb(
    chemistry_select,
    R0,
    C_eff,
    eta,
    a,
    b
);

reg signed [15:0] soc_reg;
reg signed [15:0] Vrc_reg;

assign soc_est = soc_reg;

wire signed [15:0] soc_cc;

coulomb_counter cc(
    soc_reg,
    current,
    dt,
    eta,
    C_eff,
    soc_cc
);

wire signed [15:0] Vrc_next;

battery_state_model rc(
    clk,
    rst,
    Vrc_reg,
    current,
    a,
    b,
    Vrc_next
);

wire [7:0] soc_index;
assign soc_index = soc_reg[15:8];

wire signed [15:0] ocv;

ocv_lut_manager lut(
    soc_index,
    chemistry_select,
    ocv
);

battery_voltage_model vm(
    ocv,
    current,
    R0,
    Vrc_reg,
    voltage_est
);

assign innovation = voltage_meas - voltage_est;

always @(posedge clk or posedge rst) begin

    if(rst) begin
        soc_reg <= 16'sd20480;
        Vrc_reg <= 0;
    end

    else begin
        soc_reg <= soc_cc;
        Vrc_reg <= Vrc_next;
    end

end

endmodule