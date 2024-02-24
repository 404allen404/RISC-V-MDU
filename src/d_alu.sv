module d_alu (
  /* input */
  input logic        d_alu_op,
  input logic [31:0] d_alu_in_1,
  input logic [31:0] d_alu_in_2,
  /* output */
  output logic [31:0] d_alu_out
);

  always_comb begin
    case (d_alu_op)
      1'b0:    d_alu_out = md_alu_in_1 - md_alu_in_2;
      default: d_alu_out = 32'd0;
    endcase
  end

endmodule