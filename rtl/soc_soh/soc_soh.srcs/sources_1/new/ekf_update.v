module ekf_predict(

    input clk,
    input rst,

    input signed [15:0] soc,
    input signed [15:0] Vrc,

    input signed [15:0] a,

    input signed [15:0] Q11,
    input signed [15:0] Q22,

    input signed [15:0] P11,
    input signed [15:0] P12,
    input signed [15:0] P21,
    input signed [15:0] P22,

    output signed [15:0] P11_p,
    output signed [15:0] P12_p,
    output signed [15:0] P21_p,
    output signed [15:0] P22_p
);

////////////////////////////////////////////////////////////
// Multipliers
////////////////////////////////////////////////////////////

wire signed [15:0] aP12;
wire signed [15:0] aP21;
wire signed [15:0] aP22;
wire signed [15:0] aaP22;

qmult m1(a, P12, aP12);
qmult m2(a, P21, aP21);
qmult m3(a, P22, aP22);
qmult m4(a, aP22, aaP22);

////////////////////////////////////////////////////////////
// Predicted Covariance
////////////////////////////////////////////////////////////

// P11 = P11 + Q11
assign P11_p = P11 + Q11;

// P12 = a * P12
assign P12_p = aP12;

// P21 = a * P21
assign P21_p = aP21;

// P22 = a² * P22 + Q22
assign P22_p = aaP22 + Q22;

endmodule