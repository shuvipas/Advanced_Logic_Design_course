`timescale 1ns / 1ps
module gcd_tb ();

  logic clk;
  logic resetb;
  logic ld;
  logic [7:0] u;
  logic [7:0] v;

  logic [7:0] res;
  logic done;

  initial begin
    clk = 1'b0;
    resetb = 1'b0;
    ld = 1'b0;
    u = 8'b0;
    v = 8'b0;
  end

  always begin
    #5ns;
    clk = ~clk;
  end

  gcd gcd_dut (
      .clk(clk),
      .resetb(resetb),
      .ld(ld),
      .u(u),
      .v(v),
      .res(res),
      .done(done)
  );


  //driver

  initial begin
    #5ns;
    resetb = 1'b1;

    repeat (100) drive_inputs();
  end
  function void randomizes_inputs();
    u = $urandom();
    v = $urandom();
  endfunction  //randomizes_inputs

  task automatic drive_inputs();

    randomizes_inputs();
    ld = 1'b1;
    #10ns;
    ld = 1'b0;
    @(posedge done);
    #40ns;
  endtask



  // checker

  function logic [7:0] exp_gcd(logic [7:0] u, logic [7:0] v);

    logic [7:0] u_reg, v_reg;
    u_reg = u;
    v_reg = v;

    while (u_reg != 0 && v_reg != 0) begin
      if (u_reg > v_reg) u_reg = u_reg - v_reg;

      else v_reg = v_reg - u_reg;
    end
    exp_gcd = (u_reg == 0) ? v_reg : u_reg;

  endfunction


  function void gcd_checker(logic [7:0] u, logic [7:0] v, logic [7:0] res);
    logic [7:0] exp_res;

    exp_res = exp_gcd(u, v);

    $display("GCD(%d, %d) = %d\n", u, v, res);

    if (exp_res != res) $error("checker failed:  exp_result=%d", exp_res);

  endfunction


  // moniter
  initial begin
    forever begin
      @(posedge done);
      #0;
      gcd_checker(u, v, res);
    end
  end

endmodule
