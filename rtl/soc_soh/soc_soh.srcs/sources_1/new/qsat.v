module qsat (
    input  signed [31:0] in,
    output signed [15:0] out
);
    assign out =
        (in > 32'sh00007FFF) ? 16'sh7FFF :
        (in < -32'sh00008000) ? -16'sh8000 :
        in[15:0];
endmodule