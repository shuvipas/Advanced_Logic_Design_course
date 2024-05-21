`timescale 1ns / 10ps

module power_on_tb ();
  logic resetb;
  logic clk;
  logic power_good;
  logic enable;

  initial begin
    clk = 1'b0;
    resetb = 1'b0;
    power_good = 1'b0;
  end

  always begin
    #5ns;
    clk = ~clk;
  end

  power_on power_on (
      .resetb(resetb),
      .clk(clk),
      .power_good(power_good),
      .enable(enable)
  );


  //driver

  initial begin
    #10ns;
    resetb = 1'b1;

    drive_inputs();
    drive_rand_inputs();
  end

  task automatic drive_inputs();
    #3ns;
    resetb = 1;
    #10ns;
    power_good = 1;
    #350ns;
    power_good = 0;
    #15ns;
    power_good = 1;
    #250ns;
    resetb = 0;
    #5ns;
    resetb = 1;
    #100ns;
    power_good = 0;
    #50ns;
    power_good = 1;
    #40ns;
    power_good = 0;
    #40ns;
    power_good = 1;
    #350ns;
    resetb = 0;
    #5ns;
    resetb = 1;

  endtask




  task automatic rand_power_good_dealy();
    int random_time = random_time_delay();

    #random_time;
    power_good = ~power_good;
  endtask  //rand_power_good_dealy

  task automatic rand_resetb_dealy();

    int random_time = random_time_delay() * 3;

    #random_time;
    resetb = 1'b0;
    #50ns;
    resetb = 1'b1;

  endtask  //rand_resatb_dealy

  task automatic drive_rand_inputs();
    repeat (100) begin
      rand_power_good_dealy();
      rand_resetb_dealy();
    end
  endtask  //drive_rand_inputs

  function int random_time_delay();
    random_time_delay = $urandom % 1000;
  endfunction  //random_time_delay



  //monitor
  time start_t;
  // if we had a reset we will start the clock after the reset goes 
  //up and we continue to run as normal. so we check the time 
  //at posedge of rst and if power_good is up we start counting. 
  always @(posedge power_good or posedge resetb) begin
    if (power_good) start_t = $time;
  end

  always @(posedge enable)
    $display(
        "the delay between power_good and enable is: %t \n", $time - start_t
    );


  //checker
  initial
    forever begin
      @(posedge power_good);
      fork : DELAY_CHECKER
        #300ns;
        @(negedge power_good);
        @(posedge enable)
          $error(
              "the delay between power_good and enable is less then requierd! \n"
          );
      join_any
      disable DELAY_CHECKER;
    end

endmodule
