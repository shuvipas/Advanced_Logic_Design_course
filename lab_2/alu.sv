/* lab 2
shuvi pasko 
  id 204812192
*/
module alu (
    input logic [7:0] a,  //Signed Operand
    input logic [7:0] b,  //Signed Operand
    input logic [3:0] op,  // ALU Operation
    output logic [7:0] result
);
  always_comb begin
    case (op)
      4'b0001: result = a & b;  //Bitwise AND
      4'b0010: result = a | b;  // Bitwise OR
      4'b0011: result = |a | |b;  // Logical OR
      4'b1001: result = ~a + 1'b1;  // Twos complement of a
      4'b1011: result = a >> 1;  //Logical shift 1-bit right of a
      4'b1100: result = {a[7], a[7:1]};  // Arithmetic shift 1-bit right of a
      4'b1101: result = {b[6:0], b[7]};  // Rotate 1-bit left of b
      default: result = 8'b0;  // non defined operation  NOP
    endcase
  end

endmodule
