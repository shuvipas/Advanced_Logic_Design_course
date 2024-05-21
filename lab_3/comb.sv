
module comb (
    input logic [1:0] a,
    input logic [1:0] b,
    output logic out
);

  logic a_or, bor;

  assign a_or = a[0] | a[1];
  assign b_or = b[0] | b[1];
  assign out  = a_or & b_or;

endmodule
