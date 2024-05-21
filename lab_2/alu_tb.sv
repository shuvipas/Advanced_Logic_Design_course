/* lab 2
shuvi pasko 
  id 204812192
*/

`timescale 1ps / 1ps
module alu_tb ();
  logic [7:0] a;
  logic [7:0] b;
  logic [7:0] result;
  logic [3:0] op;



  alu alu_dut (
      .a(a),
      .b(b),
      .op(op),
      .result(result)
  );


  ///driver///
  //generate random inputs
  function void randomizes_inputs();
    a  = $random();
    b  = $random();
    op = $random();
  endfunction  //randomizes_inputs

  //drive inputs and add delay
  task automatic drive_inputs();
    randomizes_inputs();
    #200ps;
  endtask

  initial begin
    {a, b, op} = 0;
    #1ns;
    repeat (100) drive_inputs();
  end

  // Golden model
  function logic [7:0] expected_result(logic [7:0] a, logic [7:0] b, logic [3:0] op);
    case (op)
      4'b0001: expected_result = a & b;  //Bitwise AND
      4'b0010: expected_result = a | b;  // Bitwise OR
      4'b0011: expected_result = a || b;  // Logical OR
      4'b1001: expected_result = 9'h100 - a;  // Twos complement of a
      4'b1011: expected_result = {1'b0, a[7:1]};  //Logical shift 1-bit right of a
      4'b1100: begin  // Arithmetic shift 1-bit right of a
        expected_result = a >> 1;
        expected_result[7] = expected_result[6];
      end
      4'b1101: begin  // Rotate 1-bit left of b
        logic b7_bit;
        b7_bit = b[7];
        expected_result = b << 1;
        expected_result[0] = b7_bit;
      end
      default: expected_result = 8'b0;  // non defined operation NOP
    endcase
  endfunction

  ///checker///
  function void alu_checker(logic [7:0] a, logic [7:0] b, logic [3:0] op, logic [7:0] result);
    logic [7:0] exp_result;
    exp_result = expected_result(a, b, op);
    $display("a=%b  b=%b op=%b result=%b \n", a, b, op, result);

    if (exp_result != result) $error("checker failed: exp_result=%b ", exp_result);

  endfunction

  // moniter
  initial begin
    forever begin
      @(a, b, op, result);
      #0;
      alu_checker(a, b, op, result);
    end
  end

endmodule
