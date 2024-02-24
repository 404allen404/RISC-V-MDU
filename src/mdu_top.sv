`include "mdu_alu.sv"
`include "mdu_"

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










endmodule