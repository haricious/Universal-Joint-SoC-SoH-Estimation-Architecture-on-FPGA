module ocv_lut_manager(
    input  [7:0] soc_index,   // 0-100
    input  [1:0] chemistry_select,
    output signed [15:0] ocv_out
);

// Convert SOC% to Q8.8 (0-1 range)
wire signed [15:0] soc_q;
assign soc_q = {soc_index, 8'b0};  // percentage * 256

// Convert to 0-1 range
wire signed [15:0] soc_norm;
assign soc_norm = soc_q / 100;

// Compute quadratic OCV model
// OCV = 3.0 + 1.2*s - 0.3*s^2

wire signed [15:0] term1;
wire signed [15:0] term2;
wire signed [15:0] soc_sq;

qmult m1(soc_norm, soc_norm, soc_sq);
qmult m2(16'sd307, soc_norm, term1);   // 1.2*256 ≈ 307
qmult m3(16'sd77, soc_sq, term2);      // 0.3*256 ≈ 77

assign ocv_out = 16'sd768 + term1 - term2;  // 3.0V base

endmodule