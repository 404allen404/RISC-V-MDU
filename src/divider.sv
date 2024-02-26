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
  output logic div_busy
);

  enum bit [2:0] {DIV_WAIT_VALID, DIV_DETECT_EXCEPTION} div_state;

  assign div_out = 32'd0;
  assign div_out_valid = 1'b0;
  assign div_busy = 1'b0;

  always @(posedge clk or posedge rst) begin 
    if (rst) begin
      div_state <= DIV_WAIT_VALID;
    end
    else begin
      case (div_state)
        DIV_WAIT_VALID:       div_state <= div_in_valid ? DIV_DETECT_EXCEPTION : DIV_WAIT_VALID;
        DIV_DETECT_EXCEPTION: div_state <= DIV_DETECT_EXCEPTION;
      endcase
    end
  end



endmodule