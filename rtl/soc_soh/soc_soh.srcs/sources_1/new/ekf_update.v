module ekf_update(
    input  signed [15:0] innovation,
    input  signed [15:0] dOCV_dSOC,   // H1
    input  signed [15:0] P11,
    input  signed [15:0] P12,
    input  signed [15:0] P21,
    input  signed [15:0] P22,
    input  signed [15:0] R_meas,
    output signed [15:0] K1,
    output signed [15:0] K2
);

// =======================================================
// H components
// =======================================================
wire signed [15:0] H1 = dOCV_dSOC;
wire signed [15:0] H2 = -16'sd256;   // -1 in Q8.8

// =======================================================
// Compute S = HPH' + R
// =======================================================

// H1^2 * P11
wire signed [15:0] H1_sq;
wire signed [15:0] term1;
qmult m1(H1, H1, H1_sq);
qmult m2(H1_sq, P11, term1);

// -H1*P12
wire signed [15:0] term2;
wire signed [15:0] H1P12;
qmult m3(H1, P12, H1P12);
assign term2 = -H1P12;

// -H1*P21
wire signed [15:0] term3;
wire signed [15:0] H1P21;
qmult m4(H1, P21, H1P21);
assign term3 = -H1P21;

// H2^2 * P22 = 1 * P22
wire signed [15:0] term4 = P22;

wire signed [15:0] S;
assign S = term1 + term2 + term3 + term4 + R_meas;

// =======================================================
// Inverse of S
// =======================================================
wire signed [15:0] invS;
qdiv d1(16'sd256, S, invS);   // 1/S in Q8.8

// =======================================================
// Compute Gain Numerators
// =======================================================

// K1 numerator = P11*H1 - P12
wire signed [15:0] P11H1;
wire signed [15:0] num1;
qmult m5(P11, H1, P11H1);
assign num1 = P11H1 - P12;

// K2 numerator = P21*H1 - P22
wire signed [15:0] P21H1;
wire signed [15:0] num2;
qmult m6(P21, H1, P21H1);
assign num2 = P21H1 - P22;

// =======================================================
// Final Gain
// =======================================================
qmult m7(num1, invS, K1);
qmult m8(num2, invS, K2);

endmodule