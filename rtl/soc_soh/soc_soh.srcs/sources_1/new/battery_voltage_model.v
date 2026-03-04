module battery_voltage_model(

    input signed [15:0] ocv,
    input signed [15:0] current,
    input signed [15:0] R0,
    input signed [15:0] Vrc,

    output signed [15:0] voltage_est
);

wire signed [15:0] iR;

qmult m1(current,R0,iR);

assign voltage_est = ocv - iR - Vrc;

endmodule