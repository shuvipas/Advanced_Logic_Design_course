`timescale 1ns / 1ps

module sin_gen_tb ();
  logic clk;
  logic resetb;
  logic en;
  logic [7:0] period_sel;
  logic [8:0] sin_out;





  initial begin
    clk = 1'b0;
    resetb = 1'b0;
    en = 1'b0;
    period_sel = 8'b0;

  end

  always begin
    #1ns;
    clk = ~clk;
  end

  sin_gen sin_dut (
      .clk(clk),
      .resetb(resetb),
      .en(en),
      .period_sel(period_sel),
      .sin_out(sin_out)
  );

  //driver
  initial begin
    #10ns;
    resetb = 1'b1;

    drive_sin_dut();
  end

  task automatic drive_sin_dut ();
    
    #10ns;
    //reguler oparation
    en = 1'b1;
    period_sel =8'b0;
    #5000ns
    //change in the middle
    period_sel = 8'b1;
    #7000ns;
    period_sel =8'b0;
    
    #5000ns
    //stop in the middle
    en = 1'b0;
    //start with diffrent period
    #5000ns;
    en =1'b1;
    period_sel =8'b11;
    #5000ns;
    //toggle resetb
    resetb = 1'b0;
    #200ns;
     resetb = 1'b1;
    
  endtask






  //checker
  //moniter




endmodule
