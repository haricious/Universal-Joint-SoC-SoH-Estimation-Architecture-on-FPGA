module parameter_bank (
    input  [1:0] chemistry_select,
    output reg signed [15:0] R0,
    output reg signed [15:0] C_eff,
    output reg signed [15:0] eta,
    output reg signed [15:0] a_coeff,
    output reg signed [15:0] b_coeff
);

always @(*) begin
    case (chemistry_select)

        // ---------------------------------------
        // 2'b00 : Lithium-Ion 3.7V (18650 type)
        // ---------------------------------------
        2'b00: begin // Li-ion
            R0      = 16'sh0010;     // ≈0.01
            C_eff   = 16'sd25600;    // 100% capacity
            eta     = 16'sh0100;     // 1.0
            a_coeff = 16'sh00F0;
            b_coeff = 16'sh0008;
        end

        // ---------------------------------------
        // 2'b01 : Lead Acid 12V (example)
        // ---------------------------------------
        2'b01: begin
            R0      = 16'sd25;     // ~0.1 ohm
            C_eff   = 16'sd5120;   // 20 Ah
            eta     = 16'sd240;    // ~0.94
            a_coeff = 16'sd230;    // slower RC decay
            b_coeff = 16'sd20;
        end

        // ---------------------------------------
        // Default Safe Values
        // ---------------------------------------
        default: begin
            R0      = 16'sd0;
            C_eff   = 16'sd0;
            eta     = 16'sd0;
            a_coeff = 16'sd0;
            b_coeff = 16'sd0;
        end
    endcase
end

endmodule