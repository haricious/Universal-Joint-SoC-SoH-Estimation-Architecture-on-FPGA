module ekf_covariance_update(

    input  signed [15:0] P11_p,
    input  signed [15:0] P12_p,
    input  signed [15:0] P21_p,
    input  signed [15:0] P22_p,

    input  signed [15:0] K1,
    input  signed [15:0] K2,

    input  signed [15:0] dOCV_dSOC,
    input  signed [15:0] R_meas,

    output signed [15:0] P11,
    output signed [15:0] P12,
    output signed [15:0] P21,
    output signed [15:0] P22
);

////////////////////////////////////////////////////////////
// KH
////////////////////////////////////////////////////////////

wire signed [15:0] KH11;
wire signed [15:0] KH12;
wire signed [15:0] KH21;
wire signed [15:0] KH22;

qmult m1(K1, dOCV_dSOC, KH11);
assign KH12 = -K1;

qmult m2(K2, dOCV_dSOC, KH21);
assign KH22 = -K2;

////////////////////////////////////////////////////////////
// I - KH
////////////////////////////////////////////////////////////

wire signed [15:0] A11;
wire signed [15:0] A12;
wire signed [15:0] A21;
wire signed [15:0] A22;

assign A11 = 16'sd256 - KH11;
assign A12 = -KH12;
assign A21 = -KH21;
assign A22 = 16'sd256 - KH22;

////////////////////////////////////////////////////////////
// First multiply: A * P
////////////////////////////////////////////////////////////

wire signed [15:0] AP11;
wire signed [15:0] AP12;
wire signed [15:0] AP21;
wire signed [15:0] AP22;

wire signed [15:0] t1;
wire signed [15:0] t2;

qmult q1(A11, P11_p, t1);
qmult q2(A12, P21_p, t2);
assign AP11 = t1 + t2;

qmult q3(A11, P12_p, t1);
qmult q4(A12, P22_p, t2);
assign AP12 = t1 + t2;

qmult q5(A21, P11_p, t1);
qmult q6(A22, P21_p, t2);
assign AP21 = t1 + t2;

qmult q7(A21, P12_p, t1);
qmult q8(A22, P22_p, t2);
assign AP22 = t1 + t2;

////////////////////////////////////////////////////////////
// Second multiply: (A P) Aᵀ
////////////////////////////////////////////////////////////

wire signed [15:0] APA11;
wire signed [15:0] APA12;
wire signed [15:0] APA21;
wire signed [15:0] APA22;

qmult q9(A11, AP11, t1);
qmult q10(A21, AP12, t2);
assign APA11 = t1 + t2;

qmult q11(A12, AP11, t1);
qmult q12(A22, AP12, t2);
assign APA12 = t1 + t2;

qmult q13(A11, AP21, t1);
qmult q14(A21, AP22, t2);
assign APA21 = t1 + t2;

qmult q15(A12, AP21, t1);
qmult q16(A22, AP22, t2);
assign APA22 = t1 + t2;

////////////////////////////////////////////////////////////
// K R Kᵀ term
////////////////////////////////////////////////////////////

wire signed [15:0] KRK11;
wire signed [15:0] KRK22;

wire signed [15:0] temp;

qmult q17(K1, R_meas, temp);
qmult q18(temp, K1, KRK11);

qmult q19(K2, R_meas, temp);
qmult q20(temp, K2, KRK22);

////////////////////////////////////////////////////////////
// Final covariance
////////////////////////////////////////////////////////////

assign P11 = APA11 + KRK11;
assign P12 = APA12;
assign P21 = APA21;
assign P22 = APA22 + KRK22;

endmodule