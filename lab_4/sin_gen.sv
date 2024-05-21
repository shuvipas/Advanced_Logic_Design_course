module sin_gen (
    input logic clk,
    input logic resetb,
    input logic en,
    input logic [7:0] period_sel,
    output logic [8:0] sin_out
);



  logic keep_counting;
  logic sign;
  logic count_down;  //down = 1, up = 0
  logic en_adrr_count;  // enable for the address counter
  logic cycle_done;
  logic [7:0] address;
  logic [7:0] dout;
  logic [7:0] curr_period;
  logic [7:0] period_count;
  logic count_up_end;
  logic count_down_end;

  //-------------------------
  // sinus quadrant fsm
  //-------------------------

  typedef enum logic [2:0] {
    IDLE = 3'b0,
    Q1   = 3'b001,
    Q2   = 3'b010,
    Q3   = 3'b011,
    Q4   = 3'b100
  } quadrant_type;


  quadrant_type quadrant_cs;
  quadrant_type quadrant_ns;
  always_ff @(posedge clk or negedge resetb) begin
    if (~resetb) quadrant_cs <= IDLE;
    else quadrant_cs <= quadrant_ns;
  end

  // next state logic
  assign en_adrr_count  = curr_period == period_count;
  assign count_up_end   = (address == 8'hff) & en_adrr_count;
  assign count_down_end = (address == 8'b0) & en_adrr_count;
  always_comb begin
    case (quadrant_cs)
      IDLE: quadrant_ns = en ? Q1 : IDLE;
      Q1: quadrant_ns = count_up_end ? Q2 : Q1;
      Q2: quadrant_ns = count_down_end ? Q3 : Q2;
      Q3: quadrant_ns = count_up_end ? Q4 : Q3;
      Q4: begin
        if (count_down_end) quadrant_ns = en ? Q1 : IDLE;
        else quadrant_ns = Q4;
      end
      default: quadrant_ns = IDLE;
    endcase
  end

  //output logic
  assign sign = (quadrant_cs == Q3) | (quadrant_cs == Q4);  // 0 for +, 1 for -
  assign count_down = (quadrant_cs == Q2) | (quadrant_cs == Q4);


  //-------------------------
  // period register
  //-------------------------
  assign cycle_done = (quadrant_cs == Q4) & count_down_end;
  always_ff @(posedge clk or negedge resetb) begin
    if (~resetb) curr_period <= 8'b0;
    else if (cycle_done | quadrant_cs == IDLE) curr_period <= period_sel;
  end

  //-------------------------
  // period_conter
  //-------------------------

  always_ff @(posedge clk or negedge resetb) begin
    if (~resetb) period_count <= 8'b0;
    else if (quadrant_cs == IDLE | en_adrr_count) period_count <= 8'b0;
    else period_count <= period_count + 1'b1;

  end
  //-------------------------
  // address_conter
  //-------------------------
  assign keep_counting = quadrant_cs == quadrant_ns;
  always_ff @(posedge clk or negedge resetb) begin
    if (~resetb) address <= 8'b0;
    else if (quadrant_cs == IDLE) address <= 8'b0;
    else if (en_adrr_count & keep_counting) begin
      if (count_down) address <= address - 1'b1;
      else address <= address + 1'b1;
    end
  end

  //-------------------------
  // lut ant output
  //-------------------------


  sin_lut lut1 (
      .address(address),
      .dout(dout)
  );
  assign sin_out = sign ? {1'b1, ~dout} + 1'b1 : {1'b0, dout};

endmodule
