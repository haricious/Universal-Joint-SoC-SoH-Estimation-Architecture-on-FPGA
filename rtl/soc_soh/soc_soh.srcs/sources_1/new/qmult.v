module qmult (
    input  signed [15:0] a,
    input  signed [15:0] b,
    output signed [15:0] result
);
    wire signed [31:0] mult_full;
    assign mult_full = a * b;
    assign result = mult_full[23:8];   // Q8.8 scaling
endmodule