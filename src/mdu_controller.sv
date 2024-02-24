module mdu_controller (
  /* input */
  input logic clk,
  input logic rst,
  input logic [2:0] funct3,
  input logic mdu_in_valid,
  input logic cpu_busy,
  /* output */
  output logic m_wen,
  // output logic d_op,
  // output logic d_sr,
  // output logic d_sl,
  // output logic d_wen,
  output logic mdu_busy,
  output logic mdu_out_valid
);

  enum bit [1:0] {MUL_INIT, MUL_WAIT_VALID, MUL_COMPUTE, MUL_DONE} mul_state;
  // enum bit [1:0] {DIV_INIT, DIV_WAIT_VALID} div_state;
  // logic [4:0] div_cnt;
  logic [5:0] mul_cnt;

  assign mdu_busy = (mul_state != MUL_WAIT_VALID);
  assign m_wen = (mul_state == MUL_COMPUTE);
  assign mdu_out_valid = (mul_state == MUL_DONE);

  // mul_state
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      mul_state <= MUL_INIT;
    end
    else begin
      case (mul_state)
        MUL_INIT:       mul_state <= MUL_WAIT_VALID;
        MUL_WAIT_VALID: mul_state <= (mdu_in_valid && ~funct3[2]) ? MUL_COMPUTE : MUL_WAIT_VALID;
        MUL_COMPUTE:    mul_state <= (mul_cnt == 6'd63) ? MUL_DONE : MUL_COMPUTE;
        MUL_DONE:       mul_state <= cpu_busy ? MUL_DONE : MUL_WAIT_VALID;
      endcase
    end
  end

  // mul_cnt
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      mul_cnt <= 6'd0;
    end
    else if (mul_state == MUL_COMPUTE) begin
      mul_cnt <= mul + 6'd1;
    end
  end

endmodule