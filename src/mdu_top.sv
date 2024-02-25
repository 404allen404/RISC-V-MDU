module mdu_top(
  /* input */
  input logic clk,
  input logic rst,
  input logic mdu_in_valid,
  input logic [2:0] funct3,
  input logic [31:0] mdu_in_1, // multiplicand
  input logic [31:0] mdu_in_2, // multiplier
  input logic cpu_busy,
  /* output */
  output logic [31:0] mdu_out,
  output logic mdu_out_valid,
  output logic mdu_busy
);

  logic mul_in_valid;
  logic [31:0] mul_out;
  logic mul_out_valid;
  logic mul_busy;

  assign mul_in_valid = mdu_in_valid && ~funct3[2];
  assign mdu_busy = mul_busy;
  assign mdu_out_valid = mul_out_valid;
  assign mdu_out = mul_out;

  // radix_4_mul
  radix_4_mul radix_4_mul_0 (
    /* input */
    .clk(clk),
    .rst(rst),
    .multiplier(mdu_in_2),
    .multiplicand(mdu_in_1),
    .mul_in_valid(mul_in_valid),
    .mul_type(funct3[1:0]),
    .cpu_busy(cpu_busy),
    /* output */
    .mul_out(mul_out),
    .mul_out_valid(mul_out_valid),
    .mul_busy(mul_busy)
  );

endmodule