module qmult(
    input signed [15:0] a,
    input signed [15:0] b,
    output signed [15:0] result
);

    wire signed [31:0] mult_temp;
    assign mult_temp = a * b;
    assign result = mult_temp[23:8];  // shift back to Q8.8

endmodule