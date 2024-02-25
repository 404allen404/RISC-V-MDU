module radix_4_mul (
  /* input */
  input logic clk,
  input logic rst,
  input logic mul_in_valid,
  input logic [1:0] mul_type,
  input logic [31:0] multiplier,
  input logic [31:0] multiplicand,
  input logic cpu_busy,
  /* output */
  output logic [31:0] mul_out,
  output logic mul_out_valid,
  output logic mul_busy
);

  enum bit [1:0] {MUL_WAIT_VALID, MUL_PRE_COMPUTE, MUL_COMPUTE, MUL_DONE} mul_state;

  logic [34:0] neg_1_multiplicand_w;
  logic [5:0]  cnt;
  logic [34:0] op_vector;
  logic [33:0] real_multiplier;
  logic [33:0] real_multiplicand;
  logic [67:0] neg_1_multiplicand;
  logic [67:0] neg_2_multiplicand;
  logic [67:0] pos_1_multiplicand;
  logic [67:0] pos_2_multiplicand;
  logic [67:0] product;

  assign mul_busy = (mul_state != MUL_WAIT_VALID);
  assign mul_out_valid = (mul_state == MUL_DONE);
  assign mul_out = !mul_type ? product[31:0] : product[63:32];

  // mul_state
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      mul_state <= MUL_WAIT_VALID;
    end
    else begin
      case (mul_state)
        MUL_WAIT_VALID:  mul_state <= mul_in_valid ? MUL_PRE_COMPUTE : MUL_WAIT_VALID;
        MUL_PRE_COMPUTE: mul_state <= MUL_COMPUTE;
        MUL_COMPUTE:     mul_state <= (cnt == 5'd16) ? MUL_DONE : MUL_COMPUTE;
        MUL_DONE:        mul_state <= cpu_busy ? MUL_DONE : MUL_WAIT_VALID;
      endcase
    end
  end

  assign neg_1_multiplicand_w = ~{real_multiplicand[33], real_multiplicand} + 35'd1;
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      neg_1_multiplicand <= 68'd0;
      neg_2_multiplicand <= 68'd0;
      pos_1_multiplicand <= 68'd0;
      pos_2_multiplicand <= 68'd0;
      op_vector <= 35'd0;
      product <= 68'd0;
      cnt <= 6'd0;
    end
    else if (mul_state == MUL_PRE_COMPUTE) begin
      neg_1_multiplicand <= {{33{neg_1_multiplicand_w[33]}}, neg_1_multiplicand_w};
      neg_2_multiplicand <= {{33{neg_1_multiplicand_w[33]}}, neg_1_multiplicand_w} << 1;
      pos_1_multiplicand <= {{34{real_multiplicand[32]}}, real_multiplicand};
      pos_2_multiplicand <= {{34{real_multiplicand[32]}}, real_multiplicand} << 1;
      op_vector <= {real_multiplier, 1'b0};
      product <= 68'd0;
      cnt <= 6'd0;
    end
    else if (mul_state == MUL_COMPUTE) begin
      cnt <= cnt + 6'd1;
      op_vector <= op_vector >> 2;
      case (op_vector[2:0])
        3'b010, 3'b001: product <= product + ((pos_1_multiplicand) << (cnt << 1));
        3'b110, 3'b101: product <= product + ((neg_1_multiplicand) << (cnt << 1));
        3'b111, 3'b000: product <= product;
        3'b011:         product <= product + ((pos_2_multiplicand) << (cnt << 1));
        3'b100:         product <= product + ((neg_2_multiplicand) << (cnt << 1));
      endcase
    end
  end

  // real_multiplier
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      real_multiplier <= 34'd0;
    end
    else if(mul_state == MUL_WAIT_VALID && mul_in_valid) begin
      if (mul_type[1]) begin
        real_multiplier <= {2'd0, multiplier};
      end
      else begin
        real_multiplier <= {{2{multiplier[31]}}, multiplier};
      end
    end
  end

  // real_multiplicand
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      real_multiplicand <= 34'd0;
    end
    else if (mul_state == MUL_WAIT_VALID && mul_in_valid) begin
      if (mul_type == 2'b11) begin
        real_multiplicand <= {2'd0, multiplicand};
      end
      else begin
        real_multiplicand <= {{2{multiplicand[31]}}, multiplicand};
      end
    end
  end

endmodule