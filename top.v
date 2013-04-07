module top(clk, iBtns, iSwtchs, oLEDS, oSegs, oAN);
    input clk;
    input [3:0] iBtns;
    input [7:0] iSwtchs;
    output [7:0] oLEDS;
    output [7:0] oSegs;
    output [3:0] oAN;
//    output [7:0] oBus;

    wire wCS, wWE;
    wire [6:0] wAddr;
    wire [7:0] wData_Out_Mem, wData_Out_Ctrl, wData_Bus;
    
//    assign oBus = wData_Bus;

    // change these to two lines
    assign wData_Bus = (wWE == 1'b1) ? wData_Out_Ctrl : 8'bzzzzzzzz;

    assign wData_Bus = (wWE == 1'b0) ? wData_Out_Mem : 8'bzzzzzzzz;

    controller ctrl(clk, wCS, wWE, wAddr, wData_Bus, wData_Out_Ctrl,
                    iBtns, iSwtchs, oLEDS, oSegs, oAN);

    memory mem(clk, wCS, wWE, wAddr, wData_Bus, wData_Out_Mem);

endmodule   // top
