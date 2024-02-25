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

  assign div_out = 32'd0;
  assign div_out_valid = 1'b0;
  assign div_busy = 1'b0;

endmodule