module qmult(
    input  signed [15:0] a,
    input  signed [15:0] b,
    output signed [15:0] result
);

wire signed [31:0] mult;

assign mult = a * b;
assign result = mult >>> 8;

endmodule