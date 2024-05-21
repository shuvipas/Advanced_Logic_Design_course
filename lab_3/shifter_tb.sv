`timescale 1ps / 1ps

module shifter_tb ();
  logic [3:0] a;
  logic [1:0] b;
  logic [6:0] y;

  shifter shifter_dut (
      .a(a),
      .b(b),
      .y(y)
  );
  ///driver///
  //generate random inputs
  function void randomizes_inputs();
    a = $random();
    b = $random();
  endfunction  //randomizes_inputs

  //drive inputs and add delay
  task automatic drive_inputs();
    repeat (100) begin
      randomizes_inputs();
      #200ps;
    end
  endtask
  initial begin
    {a, b} = 0;
    #1ns;
    drive_inputs();

  end
  ///checker///
  function void alu_checker(logic [3:0] a, logic [1:0] b, logic [6:0] y);
    logic [7:0] exp_result;
    exp_result = a << b;
    $display("a=%b (%d)  b=%b (%d) y=%b (%d) \n", a,a,b, b, y,y);

    if (exp_result != y) $error("checker failed:  exp_result=%b (%d) ", exp_result, exp_result);

  endfunction
  // moniter
  initial begin
    forever begin
      @(a, b, y);
      #0;
      alu_checker(a, b, y);
    end
  end

endmodule
