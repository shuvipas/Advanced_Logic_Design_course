module shifter (
    input  logic [3:0] a,
    input  logic [1:0] b,
    output logic [6:0] y
);

  always_comb begin
    case (b)
      2'b00: y = {3'b0, a};
      2'b01: y = {2'b0, a, 1'b0};
      2'b10: y = {1'b0, a, 2'b0};
      2'b11: y = {a, 3'b0};
    endcase
  end
endmodule
