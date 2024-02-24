module mdu_controller (
  /* input */
  input logic clk,
  input logic rst,
  input logic [2:0] funct3,
  input logic mdu_in_valid,
  /* output */
  output logic [1:0] md_alu_op;
);

  enum bit [1:0] {INIT, WAIT_VALID, COMPUTE, DONE} state;
  logic [4:0] cnt;

  // cnt
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cnt <= 5'd0;
    end
  end





endmodule