module button_top(iClk, iBtns, oAN, oC);
    input iClk;
    input [3:0] iBtns;

    output [3:0] oAN;
    output [7:0] oC;

    wire wClk_1ms;
    wire [4:0] wStOut;

    clk_div clk_seven_seg(iClk, 25000, wClk_1ms);
    
    button_fsm fsm(iClk, iBtns, wStOut);
    sevenseg_controller sseg(4'b1100, wClk_1ms, 4'h0, 4'h0, {3'd0, wStOut[4]},
                             wStOut[3:0], oAN, oC); 
endmodule   // button_top
