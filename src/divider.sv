module divider (
  /* input */
  input logic clk,
  input logic rst,
  input logic [31:0] divisor,
  input logic [31:0] dividend,
  input logic div_in_valid,
  input logic [1:0] div_type,
  input logic cpu_busy,
  /* output */
  output logic [31:0] div_out,
  output logic div_out_valid,
  output logic div_busy,
  output logic exception
);

  enum bit [2:0] {DIV_WAIT_VALID, DIV_DETECT_EXCEPTION, DIV_CONVERT_SIGN, DIV_COMPUTE, DIV_ADJUST, DIV_DONE} div_state;

  logic [31:0] divisor_r;
  logic [63:0] div_result;
  logic [4:0] cnt;
  logic divisor_sign;
  logic dividend_sign;
  logic [1:0] div_type_r;

  logic exception_w;
  logic exception_cond_1; 
  logic exception_cond_2;
  logic [31:0] alu_in_1;
  logic [31:0] alu_in_2;
  logic [31:0] alu_out;
  logic [63:0] div_result_1;
  logic [63:0] div_result_2;

  assign div_out_valid = (div_state == DIV_DONE);
  assign div_busy = (div_state != DIV_WAIT_VALID);
  assign div_out = !div_type_r[1] ? div_result[31:0] : div_result[63:32];
  assign exception_cond_1 = (divisor_r == 32'd0);
  assign exception_cond_2 = (!div_type_r[0] && div_result[31:0] == 32'h10000000 && divisor_r == 32'hffffffff);
  assign exception_w = (exception_cond_1 || exception_cond_2);

  assign div_result_1 = div_result << 1;
  assign div_result_2 = {alu_out[30:0], div_result[31:0], 1'b1};

  // div_type_r
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      div_type_r <= 2'd0;
    end
    else if (div_state == DIV_WAIT_VALID && div_in_valid) begin
      div_type_r <= div_type;
    end
  end

  always_ff @(posedge clk or posedge rst) begin 
    if (rst) begin
      div_state <= DIV_WAIT_VALID;
    end
    else begin
      case (div_state)
        DIV_WAIT_VALID:       div_state <= div_in_valid ? DIV_DETECT_EXCEPTION : DIV_WAIT_VALID;
        DIV_DETECT_EXCEPTION: div_state <= exception_w ? DIV_DONE : DIV_CONVERT_SIGN;
        DIV_CONVERT_SIGN:     div_state <= DIV_COMPUTE;
        DIV_COMPUTE:          div_state <= (cnt == 5'd31) ? DIV_ADJUST : DIV_COMPUTE;
        DIV_ADJUST:           div_state <= DIV_DONE;
        DIV_DONE:             div_state <= cpu_busy ? DIV_DONE : DIV_WAIT_VALID;
      endcase
    end
  end

  // divisor_r, divisor_sign
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      divisor_r <= 32'd0;
      divisor_sign <= 1'b0;
    end
    else if (div_state == DIV_WAIT_VALID && div_in_valid) begin
      divisor_r <= divisor;
      divisor_sign <= 1'b0;
    end
    else if (div_state == DIV_CONVERT_SIGN && !div_type_r[0] && divisor[31]) begin
      divisor_r <= ~divisor_r + 32'd1;
      divisor_sign <= 1'b1;
    end
  end

  // dividend_sign
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      dividend_sign <= 1'b0;
    end
    else if (div_state == DIV_WAIT_VALID && div_in_valid) begin
      dividend_sign <= 1'b0;
    end
    else if (div_state == DIV_CONVERT_SIGN && !div_type_r[0] && div_result[31]) begin
      dividend_sign <= 1'b1;
    end
  end

  // div_result
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      div_result <= 64'd0;
    end
    else if (div_state == DIV_WAIT_VALID && div_in_valid) begin
      div_result <= {32'd0, dividend};
    end
    else if (div_state == DIV_DETECT_EXCEPTION) begin
      if (exception_cond_1) begin
        div_result <= {div_result[31:0], 32'hffffffff};
      end
      else if (exception_cond_2) begin
        div_result <= {32'd0, div_result[31:0]};
      end
    end
    else if (div_state == DIV_CONVERT_SIGN) begin
      if (!div_type_r[0] && div_result[31]) begin
        div_result <= {31'd0, ~div_result[31:0] + 32'd1, 1'b0};
      end
      else begin
        div_result <= div_result << 1;
      end
    end
    else if (div_state == DIV_COMPUTE) begin
      if (alu_out[31]) begin
        div_result <= (cnt == 5'd31) ? {1'b0, div_result_1[31:1], div_result_1[31:0]} : div_result_1;
      end
      else begin
        div_result <= (cnt == 5'd31) ? {1'b0, div_result_2[31:1], div_result_2[31:0]} : div_result_2;
      end
    end
    else if (div_state == DIV_ADJUST && !div_type_r[0]) begin
        case ({dividend_sign, divisor_sign})
          2'b01: div_result <= {div_result[63:32], ~div_result[31:0] + 32'd1};
          2'b10: div_result <= {~div_result[63:32] + 32'd1, ~div_result[31:0] + 32'd1};
          2'b11: div_result <= {~div_result[63:32] + 32'd1, div_result[31:0]};
        endcase
    end
  end

  // exception
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      exception <= 1'b0;
    end
    else if (div_state == DIV_DETECT_EXCEPTION) begin
        exception <= exception_w;
    end
    else if (div_state == DIV_DONE && !cpu_busy) begin
      exception <= 1'b0;
    end
  end

  // cnt
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cnt <= 5'd0;
    end
    else if (div_state == DIV_COMPUTE) begin
      cnt <= cnt + 5'd1;
    end
    else if (div_state == DIV_DONE && !cpu_busy) begin
      cnt <= 5'd0;
    end
  end

  // alu
  assign alu_in_1 = div_result[63:32];
  assign alu_in_2 = divisor_r;
  assign alu_out = (alu_in_1 - alu_in_2);

endmodule