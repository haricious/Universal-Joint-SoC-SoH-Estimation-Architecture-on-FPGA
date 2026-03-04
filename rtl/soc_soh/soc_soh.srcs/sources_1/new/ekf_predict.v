module ekf_predict(
    input  clk,
    input  rst,
    input  signed [15:0] soc_in,
    input  signed [15:0] vrc_in,
    input  signed [15:0] a_coeff,
    input  signed [15:0] Q11,
    input  signed [15:0] Q22,
    input  signed [15:0] P11_in,
    input  signed [15:0] P12_in,
    input  signed [15:0] P21_in,
    input  signed [15:0] P22_in,
    output reg signed [15:0] P11_out,
    output reg signed [15:0] P12_out,
    output reg signed [15:0] P21_out,
    output reg signed [15:0] P22_out
);

// Since A = [[1,0],[0,a]]

wire signed [15:0] a2;
qmult m1(a_coeff, a_coeff, a2);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        P11_out <= 16'sd50;
        P12_out <= 0;
        P21_out <= 0;
        P22_out <= 16'sd50;
    end else begin
        P11_out <= P11_in + Q11;
        P12_out <= P12_in;
        P21_out <= P21_in;
        P22_out <= (a2 * P22_in >>> 8) + Q22;
    end
end

endmodule