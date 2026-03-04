module qdiv (
    input  signed [15:0] numerator,
    input  signed [15:0] denominator,
    output signed [15:0] result
);
    wire signed [31:0] shifted;
    assign shifted = numerator <<< 8;
    assign result = shifted / denominator;
endmodule