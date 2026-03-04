module battery_voltage_model(
    input signed [15:0] ocv,
    input signed [15:0] current,
    input signed [15:0] R0,
    input signed [15:0] Vrc,
    output signed [15:0] voltage_est
);

wire signed [15:0] iR;
wire signed [15:0] ocv_minus_iR;

qmult m1(current, R0, iR);

assign ocv_minus_iR = ocv - iR;
assign voltage_est  = ocv_minus_iR - Vrc;

endmodule