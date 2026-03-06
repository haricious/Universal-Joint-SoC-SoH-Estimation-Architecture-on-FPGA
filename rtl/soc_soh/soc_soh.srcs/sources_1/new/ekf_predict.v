module ekf_update(

    input signed [15:0] innovation,
    input signed [15:0] dOCV_dSOC,

    input signed [15:0] P11,
    input signed [15:0] P12,
    input signed [15:0] P21,
    input signed [15:0] P22,

    input signed [15:0] R_meas,

    output signed [15:0] K1,
    output signed [15:0] K2
);

////////////////////////////////////////////////////////////
// DEBUG KALMAN GAINS
////////////////////////////////////////////////////////////

// Q8.8 format
// 32  -> 0.125
// 8   -> 0.03125

assign K1 = 16'sd32;
assign K2 = 16'sd8;

endmodule