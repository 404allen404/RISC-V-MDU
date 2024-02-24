module md_alu (
  /* input */
  input logic [1:0]  md_alu_op,
  input logic [31:0] md_alu_in_1,
  input logic [31:0] md_alu_in_2,
  /* output */
  output logic [31:0] md_alu_out
);

  always_comb begin
    unique case (md_alu_op)
      `MD_ALU_ADD: md_alu_out = md_alu_in_1 + md_alu_in_2;
      `MD_ALU_SUB: md_alu_out = md_alu_in_1 - md_alu_in_2;
      default: md_alu_out = 32'd0;
    endcase
  end

endmodule