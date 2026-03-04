module coulomb_counter(
    input  signed [15:0] soc_in,
    input  signed [15:0] current,
    input  signed [15:0] dt,
    input  signed [15:0] eta,
    input  signed [15:0] C_eff,
    output signed [15:0] soc_out
);

wire signed [15:0] temp1;
wire signed [15:0] temp2;
wire signed [15:0] delta;

qmult m1(current, dt, temp1);
qmult m2(temp1, eta, temp2);
qdiv  d1(temp2, C_eff, delta);

assign soc_out = soc_in - delta;

endmodule