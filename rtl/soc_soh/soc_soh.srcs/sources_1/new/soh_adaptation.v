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

wire signed [15:0] dR;
wire signed [15:0] dC;

qmult m1(innovation,alpha,dR);
qmult m2(soc_error,beta,dC);

wire signed [15:0] R0_next;
wire signed [15:0] Ceff_next;

assign R0_next   = R0_in + dR;
assign Ceff_next = Ceff_in + dC;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        R0_out   <= R0_in;
        Ceff_out <= Ceff_in;
    end else begin

        // R0 bounds (0.001 - 0.2 Ω approx in Q8.8)
        if (R0_next < 16'sd10)
            R0_out <= 16'sd10;
        else if (R0_next > 16'sd500)
            R0_out <= 16'sd500;
        else
            R0_out <= R0_next;

        // Capacity bounds (20% - 120%)
        if (Ceff_next < 16'sd5000)
            Ceff_out <= 16'sd5000;
        else if (Ceff_next > 16'sd30000)
            Ceff_out <= 16'sd30000;
        else
            Ceff_out <= Ceff_next;

    end
end

endmodule