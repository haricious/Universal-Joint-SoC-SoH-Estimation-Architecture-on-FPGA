module soh_adaptation(
    input clk,
    input rst,
    input signed [15:0] R0_in,
    input signed [15:0] Ceff_in,
    input signed [15:0] innovation,
    input signed [15:0] soc_error,
    input signed [15:0] alpha,
    input signed [15:0] beta,
    output reg signed [15:0] R0_out,
    output reg signed [15:0] Ceff_out
);

wire signed [15:0] dR,dC;

qmult m1(innovation,alpha,dR);
qmult m2(soc_error,beta,dC);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        R0_out<=R0_in;
        Ceff_out<=Ceff_in;
    end else begin
        R0_out<=R0_in+dR;
        Ceff_out<=Ceff_in+dC;
    end
end

endmodule