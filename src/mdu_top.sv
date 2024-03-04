module mdu_top(
  /* input */
  input logic clk,
  input logic rst,
  input logic mdu_in_valid,
  input logic [2:0] funct3,
  input logic [31:0] mdu_in_1, // x[rs1]: multiplicand or dividend
  input logic [31:0] mdu_in_2, // x[rs2]: multiplier or divisor
  input logic cpu_busy,
  /* output */
  output logic [31:0] mdu_out,
  output logic mdu_out_valid,
  output logic mdu_busy,
  output logic exception
);

  logic funct3_2_r;

  logic mul_in_valid;
  logic [31:0] mul_out;
  logic mul_out_valid;
  logic mul_busy;

  logic div_in_valid;
  logic [31:0] div_out;
  logic div_out_valid;
  logic div_busy;

  assign mdu_busy = mul_busy || div_busy;
  assign mdu_out_valid = mul_out_valid || div_out_valid;
  assign mdu_out = funct3_2_r ? div_out : mul_out;

  assign mul_in_valid = mdu_in_valid && ~funct3[2];
  assign div_in_valid = mdu_in_valid && funct3[2];

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      funct3_2_r <= 1'b0;
    end
    else if (mdu_in_valid) begin
      funct3_2_r <= funct3[2];
    end
  end

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

  // divider
  divider divider_0 (
    /* input */
    .clk(clk),
    .rst(rst),
    .divisor(mdu_in_2),
    .dividend(mdu_in_1),
    .div_in_valid(div_in_valid),
    .div_type(funct3[1:0]),
    .cpu_busy(cpu_busy),
    /* output */
    .div_out(div_out),
    .div_out_valid(div_out_valid),
    .div_busy(div_busy),
    .exception(exception)
  );

endmodule