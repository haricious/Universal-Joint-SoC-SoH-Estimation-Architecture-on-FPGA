module top_universal_soc_soh(

    input clk,
    input rst,
    input [1:0] chemistry_select,

    input signed [15:0] current,
    input signed [15:0] voltage_meas,
    input signed [15:0] dt,

    output signed [15:0] soc_est,
    output signed [15:0] voltage_est,
    output signed [15:0] innovation,

    output signed [15:0] K1_debug,
    output signed [15:0] delta_soc_debug
);

////////////////////////////////////////////////////////////
// Parameter Bank
////////////////////////////////////////////////////////////

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
// RC Battery Model
////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////
// SOC Index
////////////////////////////////////////////////////////////

wire [7:0] soc_index;
assign soc_index = soc_reg[15:8];

wire [7:0] soc_index_next;
assign soc_index_next = (soc_index == 8'd255) ? 8'd255 : soc_index + 1;

////////////////////////////////////////////////////////////
// OCV LUT
////////////////////////////////////////////////////////////

wire signed [15:0] ocv;
wire signed [15:0] ocv_next;

ocv_lut_manager lut(
    soc_index,
    chemistry_select,
    ocv
);

ocv_lut_manager lut_next(
    soc_index_next,
    chemistry_select,
    ocv_next
);

////////////////////////////////////////////////////////////
// Voltage Model
////////////////////////////////////////////////////////////

wire signed [15:0] voltage_est_wire;

battery_voltage_model vm(
    ocv,
    current,
    R0,
    Vrc_reg,
    voltage_est_wire
);

assign voltage_est = voltage_est_wire;

////////////////////////////////////////////////////////////
// Innovation
////////////////////////////////////////////////////////////

wire signed [15:0] innovation_wire;
assign innovation_wire = voltage_meas - voltage_est_wire;
assign innovation = innovation_wire;

////////////////////////////////////////////////////////////
// OCV Derivative
////////////////////////////////////////////////////////////

wire signed [15:0] dOCV_dSOC_raw;
assign dOCV_dSOC_raw = ocv_next - ocv;

/* fallback slope if LUT derivative is zero */
wire signed [15:0] dOCV_dSOC;
assign dOCV_dSOC = (dOCV_dSOC_raw == 0) ? 16'sd30 : dOCV_dSOC_raw;

////////////////////////////////////////////////////////////
// EKF Covariance Registers
////////////////////////////////////////////////////////////

reg signed [15:0] P11;
reg signed [15:0] P12;
reg signed [15:0] P21;
reg signed [15:0] P22;

/* process noise */
wire signed [15:0] Q11 = 16'sd10;
wire signed [15:0] Q22 = 16'sd10;

/* measurement noise */
wire signed [15:0] R_meas = 16'sd6;

////////////////////////////////////////////////////////////
// EKF Predict
////////////////////////////////////////////////////////////

wire signed [15:0] P11_p;
wire signed [15:0] P12_p;
wire signed [15:0] P21_p;
wire signed [15:0] P22_p;

ekf_predict predict_block(

    clk,
    rst,

    soc_reg,
    Vrc_reg,

    a,

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

wire signed [15:0] K1;
wire signed [15:0] K2;

ekf_update update_block(

    innovation_wire,
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
// EKF Covariance Correction
////////////////////////////////////////////////////////////

wire signed [15:0] P11_new;
wire signed [15:0] P12_new;
wire signed [15:0] P21_new;
wire signed [15:0] P22_new;

ekf_covariance_update cov_update(

    P11_p,
    P12_p,
    P21_p,
    P22_p,

    K1,
    K2,

    dOCV_dSOC,

    P11_new,
    P12_new,
    P21_new,
    P22_new
);

////////////////////////////////////////////////////////////
// EKF State Correction
////////////////////////////////////////////////////////////

wire signed [15:0] delta_soc;
wire signed [15:0] delta_vrc;

qmult m_soc(K1, innovation_wire, delta_soc);
qmult m_vrc(K2, innovation_wire, delta_vrc);

////////////////////////////////////////////////////////////
// Debug
////////////////////////////////////////////////////////////

assign K1_debug = K1;
assign delta_soc_debug = delta_soc;

////////////////////////////////////////////////////////////
// State Update
////////////////////////////////////////////////////////////

wire signed [15:0] soc_update;
assign soc_update = soc_cc + delta_soc;

always @(posedge clk or posedge rst) begin

    if(rst) begin

        soc_reg <= 16'sd20480; // 80%
        Vrc_reg <= 0;

        /* initial covariance */
        P11 <= 16'sd1024;
        P12 <= 0;
        P21 <= 0;
        P22 <= 16'sd1024;

    end
    else begin

        if(soc_update < 0)
            soc_reg <= 0;
        else if(soc_update > 16'sd25600)
            soc_reg <= 16'sd25600;
        else
            soc_reg <= soc_update;

        Vrc_reg <= Vrc_next + delta_vrc;

        P11 <= P11_new;
        P12 <= P12_new;
        P21 <= P21_new;
        P22 <= P22_new;

    end

end

endmodule