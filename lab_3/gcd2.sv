
module gcd2 (
    input logic clk,
    input logic resetb,
    input logic ld,
    input logic [7:0] u,
    input logic [7:0] v,
    output logic [7:0] res,
    output logic done
);

  logic [7:0] u_reg;
  logic [7:0] v_reg;

  logic [7:0] next_u;
  logic [7:0] next_v;

  logic [7:0] n;
  
  logic en_count;  // enable the counter n

  //counter for n
  always_ff @(posedge clk or negedge resetb) begin
    if (~resetb) n <= 8'b0;
    else if (ld) n <= 8'b0;
    else if (en_count) n <= n + 8'b1;

  end

  //store the new u and v
  always_ff @(posedge clk or negedge resetb) begin
    if (~resetb) begin
      u_reg <= 8'b0;
      v_reg <= 8'b0;
    end else if (ld) begin
      u_reg <= u;
      v_reg <= v;
    end 
    else if(~done) begin
      u_reg <= next_u;
      v_reg <= next_v;
    end
  end



  // find what operation is needed
  // (assert op)
 

  assign en_count = (~u_reg[0]) &(~v_reg[0]);//(op == 2'b01) ? 1'b1 : 1'b0;

  //the main loop of the gcd algorithm
  always_comb begin
    case ({u_reg[0] ,v_reg[0]})
      2'b00: begin  
       next_u = u_reg >> 1'b1;
        next_v = v_reg >> 1'b1;
      end
      2'b01: begin  
        next_u = u_reg >> 1'b1;
        next_v = v_reg;
      end
      2'b10: begin
        next_v = v_reg >> 1'b1;
          next_u = u_reg;
        
        
        
      end
      2'b11: begin  //one odd other even
        if (u_reg > v_reg) begin
          next_u = u_reg - v_reg;
          next_v = v_reg;
        end else begin
          next_v = v_reg - u_reg;
          next_u = u_reg;

        end
      end
      default: begin  // do nothing
        next_u = u_reg;
        next_v = v_reg;
      end

    endcase
  end

  // check if algo is done
  assign done = (u_reg == v_reg) ? 1'b1 : 1'b0;
  assign res  = done ? u_reg << n : 8'b0;


endmodule
