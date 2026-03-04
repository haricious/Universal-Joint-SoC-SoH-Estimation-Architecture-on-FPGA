module coulomb_counter(

    input  signed [15:0] soc_in,
    input  signed [15:0] current,
    input  signed [15:0] dt,
    input  signed [15:0] eta,
    input  signed [15:0] C_eff,

    output signed [15:0] soc_out
);

wire signed [15:0] i_dt;
wire signed [15:0] charge;

qmult m1(
    .a(current),
    .b(dt),
    .result(i_dt)
);

qmult m2(
    .a(i_dt),
    .b(eta),
    .result(charge)
);

wire signed [31:0] scaled_charge;
assign scaled_charge = charge <<< 8;

wire signed [15:0] delta_soc;
assign delta_soc = scaled_charge / C_eff;

wire signed [15:0] soc_next;
assign soc_next = soc_in - delta_soc;

assign soc_out =
    (soc_next > 16'sd25600) ? 16'sd25600 :
    (soc_next < 0) ? 0 :
    soc_next;

endmodule