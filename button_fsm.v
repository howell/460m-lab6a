module button_fsm(iClk, iBtns, oCtrlState);
    input iClk;
    input [3:0] iBtns;
    output [4:0] oCtrlState;

//    // ucode states for each command
//    `define ST_IDLE 5'd0
//    `define ST_PSH 5'd1
//    `define ST_POP 5'd2
//    `define ST_ADD 5'd3
//    `define ST_SUB 5'd4
//    `define ST_TOP 5'd5
//    `define ST_RST 5'd6
//    `define ST_INC 5'd7
//    `define ST_DEC 5'd8

    `define ST_PUSH              5'd2
    `define ST_POP               5'd7
	 `define ST_ADD               `ST_ADD_SPR_ADD_ONE_B
	 `define ST_SUBTRACT          `ST_SUB_SPR_ADD_ONE_B
	 `define ST_CLEAR					`ST_RST
    `define ST_TOP               `ST_DAR_SPR_ADD_ONE
	 `define ST_DEC               `ST_DEC_DAR
	 `define ST_INC					`ST_ADD_DAR
	 
    `define ST_WAIT              5'd0
    `define ST_RST               5'd1
    `define ST_SPR_SPR_SUB_ONE   5'd3 
    `define ST_DAR_SPR_ADD_ONE   5'd4
    `define ST_REQUEST_DVR       5'd5
    `define ST_LOAD_DVR          5'd6
    `define ST_SUB_SPR_ADD_ONE_B 5'd8
    `define ST_SUB_REQUEST_B     5'd9
    `define ST_SUB_LOAD_B        5'd10
    `define ST_SUB_SPR_ADD_ONE_A 5'd11
    `define ST_SUB_REQUEST_A     5'd12
    `define ST_SUB_LOAD_A        5'd13
    `define ST_SUB_STORE         5'd14
    `define ST_ADD_SPR_ADD_ONE_B 5'd15
    `define ST_ADD_REQUEST_B     5'd16
    `define ST_ADD_LOAD_B        5'd17
    `define ST_ADD_SPR_ADD_ONE_A 5'd18
    `define ST_ADD_REQUEST_A     5'd19
    `define ST_ADD_LOAD_A        5'd20
    `define ST_ADD_STORE         5'd21
    `define ST_DEC_DAR           5'd22
    `define ST_ADD_DAR           5'd23
	 
    wire wClk_10ms;
    wire [3:0] wBtns;

    reg [3:0] rState, rNextState;
    reg [4:0] oCtrlState;

    initial begin
        rState = 0;
        rNextState = 0;
        oCtrlState = `ST_WAIT;
    end

//    clk_div debounce_clk(iClk, 0, wClk_10ms);

    clk_div debounce_clk(iClk, 25000, wClk_10ms);

    debouncer d0(wClk_10ms, iBtns[0], wBtns[0]);
    debouncer d1(wClk_10ms, iBtns[1], wBtns[1]);
    debouncer d2(wClk_10ms, iBtns[2], wBtns[2]);
    debouncer d3(wClk_10ms, iBtns[3], wBtns[3]);

    always @(posedge iClk) begin
        rState <= rNextState;
    end // always

    always @(rState, wBtns) begin
        rNextState <= wBtns;
        case (rState)
            0: begin
                oCtrlState <= `ST_WAIT;
            end

            1: begin
                oCtrlState <= (wBtns == 4'h0) ? `ST_PUSH : `ST_WAIT;
            end

            2: begin
                oCtrlState <= (wBtns == 4'h0) ? `ST_POP : `ST_WAIT;
            end

            5: begin
                oCtrlState <= ((wBtns == 4'h4) | (wBtns == 4'h0)) ? `ST_ADD : `ST_WAIT;
            end

            6: begin
                oCtrlState <= ((wBtns == 4'h4) | (wBtns == 4'h0)) ? `ST_SUBTRACT : `ST_WAIT;
            end

            9: begin
                oCtrlState <= ((wBtns == 4'h8) | (wBtns == 4'h0)) ? `ST_TOP: `ST_WAIT;
            end

            10: begin
                oCtrlState <= ((wBtns == 4'h8) | (wBtns == 4'h0)) ? `ST_CLEAR : `ST_WAIT;
            end

            13: begin
                oCtrlState <= ((wBtns == 4'hC) | (wBtns == 4'h0)) ? `ST_INC : `ST_WAIT;
            end

            14: begin
                oCtrlState <= ((wBtns == 4'hC) | (wBtns == 4'h0)) ? `ST_DEC : `ST_WAIT;
            end

            default: begin
                oCtrlState <= `ST_WAIT;
            end

        endcase
    end // always


endmodule   // button_fsm 
