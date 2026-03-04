module matrix_math(
    input  signed [15:0] a11,a12,a21,a22,
    input  signed [15:0] b11,b12,b21,b22,
    output signed [15:0] c11,c12,c21,c22
);

wire signed [15:0] m1,m2,m3,m4,m5,m6,m7,m8;

qmult m_1(a11,b11,m1);
qmult m_2(a12,b21,m2);
assign c11 = m1 + m2;

qmult m_3(a11,b12,m3);
qmult m_4(a12,b22,m4);
assign c12 = m3 + m4;

qmult m_5(a21,b11,m5);
qmult m_6(a22,b21,m6);
assign c21 = m5 + m6;

qmult m_7(a21,b12,m7);
qmult m_8(a22,b22,m8);
assign c22 = m7 + m8;

endmodule