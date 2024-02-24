`include "m_alu.sv"
`include "d_alu.sv"
`include "mdu_controller.sv"

module (
  /* input */
  input logic clk,
  input logic rst,
  input logic mdu_in_valid,
  input logic [2:0] funct3,
  input logic [31:0] mdu_in_1,
  input logic [31:0] mdu_in_2,
  input logic cpu_busy,
  /* output */
  output logic [31:0] mdu_out,
  output logic mdu_out_valid,
  output logic mdu_busy
);

  logic funct3_r;
  logic m_wen;
  logic [63:0]  m_alu_out;
  logic [63:0]  multiplicand;
  logic [127:0] mul_res;
  // logic [31:0]  divisor;
  // logic [63:0]  div_res;

  // mdu_out
  always_comb begin
    if (~funct3_r[2]) begin
      mdu_out = (funct3_r[1:0] == 2'd0) ? mul_res[31:0] : mul_res[63:32];
    end
    else begin
      mdu_out = 32'd0;
    end
  end

  // funct3_r
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      funct3_r <= 3'd0;
    end
    else if (mdu_in_valid && ~mdu_busy) begin
      funct3_r <= funct3;
    end
  end

  // multiplicand
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      multiplicand <= 64'd0;
    end
    else if (mdu_in_valid && ~funct3[2] && ~mdu_busy) begin
      if (funct3[1:0] == 2'b11) begin // unsigned
        multiplicand <= {32'd0, mdu_in_1};
      end
      else begin // signed
        multiplicand <= {{32{mdu_in_2[31]}}, mdu_in_2};
      end
    end
  end

  // mul_res
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      mul_res <= 128'd0;
    end
    else if (mdu_in_valid && ~funct3[2] && ~mdu_busy) begin
      if (funct3[1]) begin // unsigned
        mul_res <= {64'd0, mdu_in_2};
      end
      else begin // signed
        mul_res <= {64'd0, {32{mdu_in_2[31]}}, mdu_in_2};
      end
    end
    else if (m_wen) begin
      mul_res <= {1'b0, m_alu_out, mul_res[63:1]};
    end
  end

  // controller
  mdu_controller mdu_controller_0 (
    /* input */
    .clk(clk),
    .rst(rst),
    .funct3(funct3),
    .mdu_in_valid(mdu_in_valid),
    .cpu_busy(cpu_busy),
    /* output */
    .m_wen(m_wen),
    .mdu_busy(mdu_busy)
  );

  // m_alu
  m_alu m_alu_0 (
    /* input */
    .m_alu_op(mul_res[0]),
    .m_alu_in_1(mul_res[127:64]),
    .m_alu_in_2(multiplicand),
    /* output */
    .m_alu_out(m_alu_out)
  );

endmodule