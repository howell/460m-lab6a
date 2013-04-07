module button_top(iClk, iBtns, oAN, oC, oCtrlSt);
    input iClk;
    input [3:0] iBtns;

    output [3:0] oAN;
	 output [4:0] oCtrlSt;
    output [7:0] oC;

    wire wClk_1ms, wClk_10ms;
    wire [4:0] wStOut;
	 
	 reg [4:0] oCtrlSt;
	 
	 initial begin
		oCtrlSt = 1;
	 end

//    clk_div clk_seven_seg(iClk, 25000, wClk_1ms);
//    clk_div clk_seven_seg(iClk, 250000, wClk_10ms);
	 
    button_fsm fsm(iClk, iBtns, wStOut);
	 
	 always @(wStOut) begin
		if(wStOut != 5'd0) begin
			oCtrlSt <= wStOut;
		end
		else begin
			oCtrlSt <= 5'h1F;
		end
	 end //always
//    sevenseg_controller sseg(4'b1100, wClk_1ms, 4'h0, 4'h0, {3'd0, wStOut[4]},
//                             wStOut[3:0], oAN, oC); 
endmodule   // button_top
