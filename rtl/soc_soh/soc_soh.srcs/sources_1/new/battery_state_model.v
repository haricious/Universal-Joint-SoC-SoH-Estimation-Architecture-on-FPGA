module battery_state_model(
    input clk,
    input rst,
    input signed [15:0] Vrc_in,
    input signed [15:0] current,
    input signed [15:0] a,
    input signed [15:0] b,
    output reg signed [15:0] Vrc_out
);

wire signed [15:0] p1, p2;

qmult m1(Vrc_in, a, p1);
qmult m2(current, b, p2);

always @(posedge clk or posedge rst) begin
    if (rst)
        Vrc_out <= 0;
    else
        Vrc_out <= p1 + p2;
end

endmodule