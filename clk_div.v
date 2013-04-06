// converts a 50 MHz clock to a 4 MHz clock
module clk_div(clk, val, slowClk);
  input clk;
  input [31:0] val;
  output slowClk;
  
  reg [31:0] count;
  reg slowClk;
  
  initial begin
    slowClk = 0;
    count = 0;
  end
  
  always @(posedge clk) begin
    if(count == val) begin
      count <= 0;
      slowClk <= ~slowClk;
    end
    else begin
      count <= count + 1;
    end
  end
  
endmodule
