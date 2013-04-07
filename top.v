module top(iClk, iBtns, iSwtchs, oLEDS, oSegs, oAN);
    input iClk;
    input [3:0] iBtns;
    input [7:0] iSwtchs;
    output [7:0] oLEDS;
    output [6:0] oSegs;
    output [3:0] oAN;

    wire wCS, wWE;
    wire [6:0] wAddr;
    wire [7:0] wData_Out_Mem, wData_Out_Ctrl, wData_Bus;

    // change these to two lines
    assign wData_Bus = 1;

    assign wData_Bus = 1;

    controller ctrl(iClk, wCS, wWE, wAddr, wData_Bus, wData_Out_Ctrl,
                    iBtns, iSwtchs, oLEDS, oSegs, oAN);

    memory mem(iClk, wCS, wWE, wAddr, wData_Bus, wData_Out_Mem);

endmodule   // top
