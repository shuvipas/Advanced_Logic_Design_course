
/*
shuvi pasko
*/


module power_on (
    input  logic resetb,
    input  logic clk,
    input  logic power_good,
    output logic enable
);

  logic sig_stable;
  logic [4:0] count;
  logic count_en;

  assign sig_stable = (count == 5'd30);

  // ff to delay the eneable 
  always_ff @(posedge clk or negedge resetb) begin
    if (~resetb) enable <= 1'b0;
    else begin
      enable <= sig_stable;
    end
  end


  assign count_en = power_good ^ sig_stable;

  always_ff @(posedge clk or negedge resetb) begin
    if (~resetb) count <= 5'b0;
    else if (count_en) count <= count + 5'b1;
    else if (~power_good) count <= 1'b0;
    else count <= count;

  end


endmodule

