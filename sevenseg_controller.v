module sevenseg_controller(EN, CLK_1MS, D3, D2, D1, D0, AN, C);
  input CLK_1MS;  // CLK_1MS should be 1 ms period
  input [3:0] EN, D3, D2, D1, D0;
  output [3:0] AN;
  output [7:0] C;

  reg [1:0] State, NextState;
  reg [3:0] AN;
  reg [7:0] C;
  
  wire [7:0] d0_sevenseg, d1_sevenseg, d2_sevenseg, d3_sevenseg;

  initial begin
    State = 0;
    NextState = 0;
	AN = 0;
    C = 0;
  end

  always @(posedge CLK_1MS) begin
    State <= NextState;
  end

  always @(State, EN, d1_sevenseg, d0_sevenseg, d1_sevenseg, d2_sevenseg, d3_sevenseg) begin
    // signal that we are driving these signals
	NextState <= 0;
	AN <= 0;
	C <= 8'hFF;
//    if(EN == 1'b1) begin
      case (State)
        0: begin
          NextState <= State + 1;
          if(EN[0]) begin
            AN <= 4'b1110;
            C <= d0_sevenseg;
          end else begin
          end
        end
        
        1: begin
          NextState <= State + 1;
          if(EN[1]) begin
            AN <= 4'b1101;
            C <= d1_sevenseg;
          end else begin
          end
        end
        
        2: begin
          NextState <= State + 1;
          if(EN[2]) begin
            AN <= 4'b1011;
            C <= d2_sevenseg;
          end else begin
          end
        end
        
        3: begin
          NextState <= State + 1;
          if(EN[3]) begin
            AN <= 4'b0111;
            C <= d3_sevenseg;
          end else begin
          end
        end
        
        default: begin
        end
      endcase
//    end else begin
//    end
  end
  
  sevenseg_rom rom0(D0, d0_sevenseg);
  sevenseg_rom rom1(D1, d1_sevenseg);
  sevenseg_rom rom2(D2, d2_sevenseg);
  sevenseg_rom rom3(D3, d3_sevenseg);


endmodule // sevenseg controller
