module m_alu (
  /* input */
  input logic        m_alu_op,
  input logic [63:0] m_alu_in_1,
  input logic [63:0] m_alu_in_2,
  /* output */
  output logic [63:0] m_alu_out
);

  always_comb begin
    case (m_alu_op)
      1'b1:    m_alu_out = m_alu_in_1 + m_alu_in_2;
      default: m_alu_out = m_alu_in_1;
    endcase
  end

endmodule