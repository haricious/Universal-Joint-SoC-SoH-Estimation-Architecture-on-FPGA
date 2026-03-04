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

////////////////////////////////////////////////////////////
// Parameter Bank
////////////////////////////////////////////////////////////
wire signed [15:0] R0, C_eff, eta, a_coeff, b_coeff;

parameter_bank pb(
    chemistry_select,
    R0,
    C_eff,
    eta,
    a_coeff,
    b_coeff
);

////////////////////////////////////////////////////////////
// State Registers
////////////////////////////////////////////////////////////
reg signed [15:0] soc_reg;
reg signed [15:0] Vrc_reg;

assign soc_est = soc_reg;

////////////////////////////////////////////////////////////
// Coulomb Counter
////////////////////////////////////////////////////////////
wire signed [15:0] soc_cc;

coulomb_counter cc(
    soc_reg,
    current,
    dt,
    eta,
    C_eff,
    soc_cc
);

////////////////////////////////////////////////////////////
// RC Model
////////////////////////////////////////////////////////////
wire signed [15:0] Vrc_next;

battery_state_model rc_model(
    .clk(clk),
    .rst(rst),
    .Vrc_in(Vrc_reg),
    .current(current),
    .a(a_coeff),
    .b(b_coeff),
    .Vrc_out(Vrc_next)
);
////////////////////////////////////////////////////////////
// SOC Index
////////////////////////////////////////////////////////////
wire [7:0] soc_index;
assign soc_index = soc_reg[15:8];

////////////////////////////////////////////////////////////
// OCV LUT
////////////////////////////////////////////////////////////
wire signed [15:0] ocv;

ocv_lut_manager lut(
    soc_index,
    chemistry_select,
    ocv
);

////////////////////////////////////////////////////////////
// OCV derivative
////////////////////////////////////////////////////////////
wire signed [15:0] ocv_next;
wire signed [15:0] dOCV_dSOC;

ocv_lut_manager lut_next(
    soc_index + 8'd1,
    chemistry_select,
    ocv_next
);

assign dOCV_dSOC = ocv_next - ocv;

////////////////////////////////////////////////////////////
// Voltage Model
////////////////////////////////////////////////////////////
battery_voltage_model vm(
    .ocv(ocv),
    .current(current),
    .R0(R0),
    .Vrc(Vrc_reg),
    .voltage_est(voltage_est)
);

////////////////////////////////////////////////////////////
// Innovation
////////////////////////////////////////////////////////////
assign innovation = voltage_meas - voltage_est;

////////////////////////////////////////////////////////////
// EKF Covariance
////////////////////////////////////////////////////////////
reg signed [15:0] P11, P12, P21, P22;

wire signed [15:0] Q11 = 16'sd2;
wire signed [15:0] Q22 = 16'sd2;
wire signed [15:0] R_meas = 16'sd5;

////////////////////////////////////////////////////////////
// EKF Predict
////////////////////////////////////////////////////////////
wire signed [15:0] P11_p, P12_p, P21_p, P22_p;

ekf_predict predict_block(
    clk,
    rst,
    soc_reg,
    Vrc_reg,
    a_coeff,
    Q11,
    Q22,
    P11,
    P12,
    P21,
    P22,
    P11_p,
    P12_p,
    P21_p,
    P22_p
);

////////////////////////////////////////////////////////////
// EKF Gain
////////////////////////////////////////////////////////////
wire signed [15:0] K1, K2;

ekf_update update_block(
    innovation,
    dOCV_dSOC,
    P11_p,
    P12_p,
    P21_p,
    P22_p,
    R_meas,
    K1,
    K2
);

////////////////////////////////////////////////////////////
// EKF Correction
////////////////////////////////////////////////////////////
wire signed [15:0] delta_soc;
wire signed [15:0] delta_vrc;

qmult mult_soc(
    .a(K1),
    .b(innovation),
    .result(delta_soc)
);

qmult mult_vrc(
    .a(K2),
    .b(innovation),
    .result(delta_vrc)
);

////////////////////////////////////////////////////////////
// Next SOC
////////////////////////////////////////////////////////////
wire signed [15:0] soc_next;
assign soc_next = soc_cc + delta_soc;

////////////////////////////////////////////////////////////
// State Update
////////////////////////////////////////////////////////////
always @(posedge clk or posedge rst) begin

    if (rst) begin

        soc_reg <= 16'sd20480;   // 80%
        Vrc_reg <= 16'sd0;

        P11 <= 16'sd1000;
        P12 <= 0;
        P21 <= 0;
        P22 <= 16'sd500;

    end
    else begin

        if (soc_next > 16'sd25600)
            soc_reg <= 16'sd25600;
        else if (soc_next < 0)
            soc_reg <= 0;
        else
            soc_reg <= soc_next;

        Vrc_reg <= Vrc_next + delta_vrc;

        P11 <= P11_p;
        P12 <= P12_p;
        P21 <= P21_p;
        P22 <= P22_p;

    end

end

endmodule