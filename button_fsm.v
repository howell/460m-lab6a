module button_fsm(iClk, iBtns, oCtrlState);
    input iClk;
    input [3:0] iBtns;
    output [4:0] oCtrlState;

    // ucode states for each command
    `define ST_IDLE 0
    `define ST_PSH 1
    `define ST_POP 2
    `define ST_ADD 3
    `define ST_SUB 4
    `define ST_TOP 5
    `define ST_RST 6
    `define ST_INC 7
    `define ST_DEC 8

    wire wClk_10ms;
    wire [3:0] wBtns;

    reg [3:0] rState, rNextState;
    reg [4:0] oCtrlState;

    initial begin
        rState = 0;
        rNextState = 0;
        oCtrlState = `ST_IDLE;
    end

    clk_div debounce_clk(iClk, 25000, wClk_10ms);

    debouncer d0(wClk_10ms, iBtns[0], wBtns[0]);
    debouncer d1(wClk_10ms, iBtns[1], wBtns[1]);
    debouncer d2(wClk_10ms, iBtns[2], wBtns[2]);
    debouncer d3(wClk_10ms, iBtns[3], wBtns[3]);

    always @(posedge iClk) begin
        rState <= rNextState;
    end // always

    always @(rState, wBtns) begin
        rNextState = wBtns;
        case (rState)
            0: begin
                oCtrlState = `ST_IDLE;
            end

            1: begin
                oCtrlState = (wBtns == 4'h0) ? `ST_PSH : `ST_IDLE;
            end

            2: begin
                oCtrlState = (wBtns == 4'h0) ? `ST_POP : `ST_IDLE;
            end

            5: begin
                oCtrlState = ((wBtns == 4'h4) | (wBtns == 4'h0)) ? `ST_ADD : `ST_IDLE;
            end

            6: begin
                oCtrlState = ((wBtns == 4'h4) | (wBtns == 4'h0)) ? `ST_SUB : `ST_IDLE;
            end

            9: begin
                oCtrlState = ((wBtns == 4'h8) | (wBtns == 4'h0)) ? `ST_TOP: `ST_IDLE;
            end

            10: begin
                oCtrlState = ((wBtns == 4'h8) | (wBtns == 4'h0)) ? `ST_RST : `ST_IDLE;
            end

            13: begin
                oCtrlState = ((wBtns == 4'hC) | (wBtns == 4'h0)) ? `ST_INC : `ST_IDLE;
            end

            14: begin
                oCtrlState = ((wBtns == 4'hC) | (wBtns == 4'h0)) ? `ST_DEC : `ST_IDLE;
            end

            default: begin
                oCtrlState = `ST_IDLE;
            end

        endcase
    end // always


endmodule   // button_fsm 
