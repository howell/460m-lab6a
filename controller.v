module controller (clk, oCs, oWe, oAddr, iData_Bus, oData_Out_Ctrl, iBtns, 
                    iSwtchs, oLeds, oSegs, oAn);
                                        				  //, rDVR, rSPR, rDAR, rCurrent_State, rInput_State,
                    //rOperand_A, rOperand_B);

    input clk;
    input [7:0] iData_Bus, iSwtchs;
    input [3:0] iBtns;  
//    output [7:0] rDVR;
//    output [6:0] rDAR, rSPR;
//    input [4:0] rInput_State;
//    output [4:0] rCurrent_State;
    output [3:0] oAn;
    output [6:0] oAddr;
    output [7:0] oData_Out_Ctrl, oSegs, oLeds;//, rOperand_A, rOperand_B;
    output oCs, oWe;

    wire wClk_1ms;
    wire [4:0] rInput_State;
    wire [6:0] wSPRp1, wSPRm1, wSPR_Mux_Out;
    wire [6:0] wDARp1, wDARm1, wDAR_Mux_Out;
    wire [7:0] wDVR_Mux_Out;
    wire [6:0] wAddr_Mux_Out;
    wire [7:0] wOperand_A_Mux_Out;
    wire [7:0] wOperand_B_Mux_Out;
    wire [7:0] wALU_Add, wALU_Sub, wALU_Out;
    wire [7:0] wData_Out_Ctrl_Mux_Out;
    wire [4:0] wNext_State_Mux_Out;

    reg [7:0] rDVR, rDVR_Mux_Out, rALU_Out, rOperand_A_Mux_Out,
              rOperand_A, rOperand_B, rOperand_B_Mux_Out, 
              rData_Out_Ctrl_Mux_Out;
    reg [6:0] rSPR, rDAR, rSPR_Mux_Out, rDAR_Mux_Out, rAddr_Mux_Out;

//    reg rCurrent_State, rInput_State, rNext_State_Mux_Out;
    reg [4:0] rCurrent_State, rNext_State_Mux_Out;
    reg [23:0] rMicrocode [23:0];

    /* SPR Mux Inputs */
    `define SPR_MUX_INIT        2'd0
    `define SPR_MUX_SPR_SUB_ONE 2'd1
    `define SPR_MUX_SPR_ADD_ONE 2'd2
    `define MICROCODE_SPR_MUX_SELECT 23:22

    `define LD_SPR_DIS         1'd0
    `define LD_SPR_EN          1'd1
    `define MICROCODE_LD_SPR           21

    /* DAR Mux Select */
    `define DAR_MUX_INIT        2'd0
    `define DAR_MUX_SPR_ADD_ONE 2'd1
    `define DAR_MUX_DAR_SUB_ONE 2'd2
    `define DAR_MUX_DAR_ADD_ONE 2'd3
    `define MICROCODE_DAR_MUX_SELECT 20:19

    `define LD_DAR_DIS          1'd0
    `define LD_DAR_EN           1'd1
    `define MICROCODE_LD_DAR           18

    /* DVR Mux Select */
    `define DVR_MUX_INIT    2'd0 
    `define DVR_MUX_DATA_IN 2'd1
    `define DVR_MUX_ALU_OUT 2'd2
    `define DVR_MUX_VAL     2'd3
    `define MICROCODE_DVR_MUX_SELECT 17:16 

    `define LD_DVR_DIS      1'd0
    `define LD_DVR_EN       1'd1
    `define MICROCODE_LD_DVR           15

    /* Addr Mux Select */
    `define ADDR_MUX_SPR 1'd0
    `define ADDR_MUX_DAR 1'd1
    `define MICROCODE_ADDR_MUX_SELECT 14

    /* Operand A Mux Select */
    `define OPERAND_A_MUX_DVR     1'd0
    `define OPERAND_A_MUX_DATA_IN 1'd1
    `define MICROCODE_OPERAND_A_MUX_SELECT 13

    `define LD_OPERAND_A_DIS     1'd0
    `define LD_OPERAND_A_EN      1'd1
    `define MICROCODE_LD_OPERAND_A 12

    /* Operand B Mux Select */
    `define OPERAND_B_MUX_DVR     1'd0
    `define OPERAND_B_MUX_DATA_IN 1'd1
    `define MICROCODE_OPERAND_B_MUX_SELECT 11

    `define LD_OPERAND_B_DIS     1'd0
    `define LD_OPERAND_B_EN      1'd1
    `define MICROCODE_LD_OPERAND_B 10

    /* ALU Select */
    `define ALU_ADD 1'd0
    `define ALU_SUB 1'd1
    `define MICROCODE_ALU_SELECT 9 

    /* Data Out Mux */
    `define DATA_OUT_CTRL_MUX_VAL 1'd0
    `define DATA_OUT_CTRL_MUX_ALU 1'd1
    `define MICROCODE_DATA_OUT_CTRL_MUX_SELECT 8

    /* Next State Mux Select */
    `define NEXT_STATE_MUX_MICROCODE   1'd0 
    `define NEXT_STATE_MUX_INPUT       1'd1 
    `define MICROCODE_NEXT_STATE_MUX   7

    `define CS_DIS          1'd0
    `define CS_EN           1'd1
    `define MICROCODE_CS    6

    `define WE_DIS          1'd0 
    `define WE_EN           1'd1
    `define MICROCODE_WE    5

    `define STATE_WAIT              5'd0
    `define STATE_RST               5'd1
    `define STATE_PUSH              5'd2
    `define STATE_SPR_SPR_SUB_ONE   5'd3 
    `define STATE_DAR_SPR_ADD_ONE   5'd4
    `define STATE_REQUEST_DVR       5'd5
    `define STATE_LOAD_DVR          5'd6
    `define STATE_POP               5'd7
    `define STATE_SUB_SPR_ADD_ONE_B 5'd8
    `define STATE_SUB_REQUEST_B     5'd9
    `define STATE_SUB_LOAD_B        5'd10
    `define STATE_SUB_SPR_ADD_ONE_A 5'd11
    `define STATE_SUB_REQUEST_A     5'd12
    `define STATE_SUB_LOAD_A        5'd13
    `define STATE_SUB_STORE         5'd14
    `define STATE_ADD_SPR_ADD_ONE_B 5'd15
    `define STATE_ADD_REQUEST_B     5'd16
    `define STATE_ADD_LOAD_B        5'd17
    `define STATE_ADD_SPR_ADD_ONE_A 5'd18
    `define STATE_ADD_REQUEST_A     5'd19
    `define STATE_ADD_LOAD_A        5'd20
    `define STATE_ADD_STORE         5'd21
    `define STATE_DEC_DAR           5'd22
    `define STATE_ADD_DAR           5'd23
    `define MICROCODE_NEXT_STATE    4:0
	 
	 clk_div sevseg_clk(clk, 25000, wClk_1ms);
	 button_fsm fsm(clk, iBtns, rInput_State);
	 sevenseg_controller sevseg(4'h3, wClk_1ms, 0, 0, rDVR[7:4], rDVR[3:0], oAn, oSegs);


    assign oAddr = rAddr_Mux_Out;
    assign oData_Out_Ctrl = rData_Out_Ctrl_Mux_Out;
	 assign oWe = rMicrocode[rCurrent_State][`MICROCODE_WE];
	 assign oCs = rMicrocode[rCurrent_State][`MICROCODE_CS];
	 assign oLeds[6:0] = rDAR;
	 assign oLeds[7] = (rSPR == 7'h7F) ? 1 : 0;
	 
    initial begin
        rCurrent_State = 0;
        rDVR = 8'hFF;
        rDAR = 7'h7F;
        rSPR = 7'h00;
        rMicrocode[`STATE_WAIT] = {`SPR_MUX_INIT,`LD_SPR_DIS,`DAR_MUX_INIT,
        `LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_INPUT,`CS_DIS,`WE_DIS,`STATE_WAIT};
        rMicrocode[`STATE_RST] = {`SPR_MUX_INIT,`LD_SPR_EN,`DAR_MUX_INIT,
        `LD_DAR_EN,`DVR_MUX_INIT,`LD_DVR_EN,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,`STATE_WAIT};
        rMicrocode[`STATE_PUSH] = {`SPR_MUX_INIT,`LD_SPR_DIS,`DAR_MUX_INIT,
        `LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_EN,`WE_EN,`STATE_SPR_SPR_SUB_ONE};
        rMicrocode[`STATE_SPR_SPR_SUB_ONE] = {`SPR_MUX_SPR_SUB_ONE,
        `LD_SPR_EN,`DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,
        `ADDR_MUX_SPR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_VAL,`NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,
        `STATE_DAR_SPR_ADD_ONE};
        rMicrocode[`STATE_DAR_SPR_ADD_ONE] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_SPR_ADD_ONE,`LD_DAR_EN,`DVR_MUX_INIT,`LD_DVR_DIS,
        `ADDR_MUX_SPR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_VAL,`NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,
        `STATE_REQUEST_DVR};
        rMicrocode[`STATE_REQUEST_DVR] = {`SPR_MUX_INIT,`LD_SPR_DIS,
       `DAR_MUX_SPR_ADD_ONE,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,
       `ADDR_MUX_DAR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
       `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
       `NEXT_STATE_MUX_MICROCODE,`CS_EN,`WE_DIS,`STATE_LOAD_DVR};
        rMicrocode[`STATE_LOAD_DVR] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_SPR_ADD_ONE,`LD_DAR_DIS,`DVR_MUX_DATA_IN,`LD_DVR_EN,
        `ADDR_MUX_DAR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_VAL,`NEXT_STATE_MUX_MICROCODE,`CS_EN,`WE_DIS,
        `STATE_WAIT};
        rMicrocode[`STATE_POP] = {`SPR_MUX_SPR_ADD_ONE,`LD_SPR_EN,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,`STATE_DAR_SPR_ADD_ONE};
        rMicrocode[`STATE_SUB_SPR_ADD_ONE_B] = {`SPR_MUX_SPR_ADD_ONE,
        `LD_SPR_EN,`DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,
        `ADDR_MUX_SPR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_VAL,`NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,
        `STATE_SUB_REQUEST_B};
        rMicrocode[`STATE_SUB_REQUEST_B] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_EN,`WE_DIS,`STATE_SUB_LOAD_B};
        rMicrocode[`STATE_SUB_LOAD_B] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DATA_IN,
        `LD_OPERAND_B_EN,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,`STATE_SUB_SPR_ADD_ONE_A};
        rMicrocode[`STATE_SUB_SPR_ADD_ONE_A] = {`SPR_MUX_SPR_ADD_ONE,
        `LD_SPR_EN,`DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,
        `ADDR_MUX_SPR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_VAL,`NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,
        `STATE_SUB_REQUEST_A};
        rMicrocode[`STATE_SUB_REQUEST_A] ={`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_EN,`WE_DIS,`STATE_SUB_LOAD_A};
        rMicrocode[`STATE_SUB_LOAD_A] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DATA_IN,`LD_OPERAND_A_EN,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,`STATE_SUB_STORE};
        rMicrocode[`STATE_SUB_STORE] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_ALU_OUT,`LD_DVR_EN,
        `ADDR_MUX_SPR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_SUB,
        `DATA_OUT_CTRL_MUX_ALU,`NEXT_STATE_MUX_MICROCODE,`CS_EN,`WE_EN,
        `STATE_WAIT};
        rMicrocode[`STATE_ADD_SPR_ADD_ONE_B] = {`SPR_MUX_SPR_ADD_ONE,
        `LD_SPR_EN,`DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,
        `ADDR_MUX_SPR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_VAL,`NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,
        `STATE_ADD_REQUEST_B};
        rMicrocode[`STATE_ADD_REQUEST_B] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_EN,`WE_DIS,`STATE_ADD_LOAD_B};
        rMicrocode[`STATE_ADD_LOAD_B] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DATA_IN,
        `LD_OPERAND_B_EN,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,`STATE_ADD_SPR_ADD_ONE_A};
        rMicrocode[`STATE_ADD_SPR_ADD_ONE_A] = {`SPR_MUX_SPR_ADD_ONE,
        `LD_SPR_EN,`DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,
        `ADDR_MUX_SPR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_VAL,`NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,
        `STATE_ADD_REQUEST_A};
        rMicrocode[`STATE_ADD_REQUEST_A] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_EN,`WE_DIS,`STATE_ADD_LOAD_A};
        rMicrocode[`STATE_ADD_LOAD_A] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_INIT,`LD_DVR_DIS,`ADDR_MUX_SPR,
        `OPERAND_A_MUX_DATA_IN,`LD_OPERAND_A_EN,`OPERAND_B_MUX_DVR,
        `LD_OPERAND_B_DIS,`ALU_ADD,`DATA_OUT_CTRL_MUX_VAL,
        `NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,`STATE_ADD_STORE};
        rMicrocode[`STATE_ADD_STORE] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_INIT,`LD_DAR_DIS,`DVR_MUX_ALU_OUT,`LD_DVR_EN,
        `ADDR_MUX_SPR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_ALU,`NEXT_STATE_MUX_MICROCODE,`CS_EN,`WE_EN,
        `STATE_WAIT};
        rMicrocode[`STATE_DEC_DAR] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_DAR_SUB_ONE,`LD_DAR_EN,`DVR_MUX_INIT,`LD_DVR_DIS,
        `ADDR_MUX_DAR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_VAL,`NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,
        `STATE_REQUEST_DVR};
        rMicrocode[`STATE_ADD_DAR] = {`SPR_MUX_INIT,`LD_SPR_DIS,
        `DAR_MUX_DAR_ADD_ONE,`LD_DAR_EN,`DVR_MUX_INIT,`LD_DVR_DIS,
        `ADDR_MUX_DAR,`OPERAND_A_MUX_DVR,`LD_OPERAND_A_DIS,
        `OPERAND_B_MUX_DVR,`LD_OPERAND_B_DIS,`ALU_ADD,
        `DATA_OUT_CTRL_MUX_VAL,`NEXT_STATE_MUX_MICROCODE,`CS_DIS,`WE_DIS,
        `STATE_REQUEST_DVR};
    end

    /* SPR Mux inputs */
    assign wSPRp1 = rSPR + 1;
    assign wSPRm1 = rSPR - 1;
    /* SPR Mux */
    mux4_7 spr_mux(7'h7F, wSPRm1, wSPRp1, 0,
                   rMicrocode[rCurrent_State][`MICROCODE_SPR_MUX_SELECT],
                   wSPR_Mux_Out);
    /*
    always @(rCurrent_State, rSPR) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_SPR_MUX_SELECT])
           `SPR_MUX_INIT: begin
                rSPR_Mux_Out <= 7'h7F; 
           end
           `SPR_MUX_SPR_SUB_ONE: begin
                rSPR_Mux_Out <= rSPR - 1; 
           end
           `SPR_MUX_SPR_ADD_ONE: begin
                rSPR_Mux_Out <= rSPR + 1; 
           end
           default: begin
			  
           end
       endcase
    end /* always */

    /* DAR Mux inputs */
    assign wDARp1 = rDAR + 1;
    assign wDARm1 = rDAR - 1;
    /* DAR Mux */
    mux4_7 dar_mux(7'h00, wSPRp1, wDARm1, wDARp1,
                   rMicrocode[rCurrent_State][`MICROCODE_DAR_MUX_SELECT],
                   wDAR_Mux_Out);
    /*
    always @(rCurrent_State, rSPR, rDAR) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_DAR_MUX_SELECT])
            `DAR_MUX_INIT: begin
                rDAR_Mux_Out <= 7'h00;
            end
            `DAR_MUX_SPR_ADD_ONE: begin
                rDAR_Mux_Out <= rSPR + 1;
            end
            `DAR_MUX_DAR_SUB_ONE: begin
                rDAR_Mux_Out <= rDAR - 1;
            end
            `DAR_MUX_DAR_ADD_ONE: begin
                rDAR_Mux_Out <= rDAR + 1;
            end
            default: begin
            end
        endcase
    end /* always */

    /* DVR Mux inputs */
    
    /* DVR Mux */
    mux4_8 dvr_mux(8'h00, iData_Bus, rALU_Out, iSwtchs,
                   rMicrocode[rCurrent_State][`MICROCODE_DVR_MUX_SELECT],
                   wDVR_Mux_Out);
    /*
    always @(rCurrent_State, iData_Bus, rALU_Out, iSwtchs) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_DVR_MUX_SELECT])
            `DVR_MUX_INIT: begin
                rDVR_Mux_Out <= 8'h00;
            end
            `DVR_MUX_DATA_IN: begin
                rDVR_Mux_Out <= iData_Bus;
            end
            `DVR_MUX_ALU_OUT: begin
                rDVR_Mux_Out <= rALU_Out; 
            end
            `DVR_MUX_VAL: begin
                rDVR_Mux_Out <= iSwtchs;
            end
            default: begin
            end
        endcase
    end /* always */

    /* Addr Mux */
    mux2_7 addr_mux(rSPR, rDAR,
                    rMicrocode[rCurrent_State][`MICROCODE_ADDR_MUX_SELECT],
                    wAddr_Mux_Out);
    /*
    always @(rCurrent_State, rSPR, rDAR) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_ADDR_MUX_SELECT])
            `ADDR_MUX_SPR: begin
                rAddr_Mux_Out <= rSPR;
            end
            `ADDR_MUX_DAR: begin
                rAddr_Mux_Out <= rDAR;
            end
            default: begin
            end
        endcase
    end /* always */

    /* Operand A Mux */
    mux2_8 opA_mux(rDVR, iData_Bus,
                   rMicrocode[rCurrent_State][`MICROCODE_OPERAND_A_MUX_SELECT],
                   wOperand_A_Mux_Out);
    /*
    always @(rCurrent_State, rDVR, iData_Bus) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_OPERAND_A_MUX_SELECT])
            `OPERAND_A_MUX_DVR: begin
                rOperand_A_Mux_Out <= rDVR;
            end
            `OPERAND_A_MUX_DATA_IN: begin
                rOperand_A_Mux_Out <= iData_Bus;
            end
            default: begin
            end
        endcase
    end /* always */

    /* Operand B Mux */
    mux2_8 opB_mux(rDVR, iData_Bus,
                   rMicrocode[rCurrent_State][`MICROCODE_OPERAND_B_MUX_SELECT],
                   wOperand_B_Mux_Out);
    /*
    always @(rCurrent_State, rDVR, iData_Bus) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_OPERAND_B_MUX_SELECT])
            `OPERAND_B_MUX_DVR: begin
                rOperand_B_Mux_Out <= rDVR;
            end
            `OPERAND_B_MUX_DATA_IN: begin
                rOperand_B_Mux_Out <= iData_Bus;
            end
            default: begin
            end
        endcase
    end /* always */

    /* ALU inputs */
    assign wALU_Add = rOperand_A + rOperand_B;
    assign wALU_Sub = rOperand_A - rOperand_B;
    /* ALU */
    mux2_8 alu(wALU_Add, wALU_Sub,
               rMicrocode[rCurrent_State][`MICROCODE_ALU_SELECT],
               wALU_Out);
    /*
    always @(rCurrent_State, rOperand_A, rOperand_B) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_ALU_SELECT])
            `ALU_ADD: begin
                rALU_Out <= rOperand_A + rOperand_B;
            end
            `ALU_SUB: begin
                rALU_Out <= rOperand_A - rOperand_B;
            end
            default: begin
            end
        endcase
    end /* always */
    
    /* Data Out Mux */
    mux2_8 dataOut_mux(iSwtchs, wALU_Out,
                      rMicrocode[rCurrent_State][`MICROCODE_DATA_OUT_CTRL_MUX_SELECT],
                      wData_Out_Ctrl_Mux_Out);
    /*
    always @(rCurrent_State, iSwtchs, rALU_Out) begin
       case(rMicrocode[rCurrent_State][`MICROCODE_DATA_OUT_CTRL_MUX_SELECT])
            `DATA_OUT_CTRL_MUX_VAL: begin
                rData_Out_Ctrl_Mux_Out <= iSwtchs;
            end
            `DATA_OUT_CTRL_MUX_ALU: begin
                rData_Out_Ctrl_Mux_Out <= rALU_Out; 
            end
            default: begin
            end
        endcase
    end /* always */
    
    /* Next State Mux */
    mux2_5 nextState_Mux(rMicrocode[rCurrent_State][`MICROCODE_NEXT_STATE],
                         rInput_State,
                         rMicrocode[rCurrent_State][`MICROCODE_NEXT_STATE_MUX],
                         wNext_State_Mux_Out);
    always @(rCurrent_State, rInput_State) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_NEXT_STATE_MUX])
            `NEXT_STATE_MUX_MICROCODE: begin
                rNext_State_Mux_Out <= 
                    rMicrocode[rCurrent_State][`MICROCODE_NEXT_STATE];
            end
            `NEXT_STATE_MUX_INPUT: begin
                rNext_State_Mux_Out <= rInput_State;
            end
            default: begin
            end
        endcase
    end /* always */

    always @(posedge clk) begin

        if(rMicrocode[rCurrent_State][`MICROCODE_LD_SPR]) begin
            rSPR <= rSPR_Mux_Out;
        end
        else begin
        end

        if(rMicrocode[rCurrent_State][`MICROCODE_LD_DAR]) begin
            rDAR <= rDAR_Mux_Out;
        end
        else begin
        end

        if(rMicrocode[rCurrent_State][`MICROCODE_LD_DVR]) begin
            rDVR <= rDVR_Mux_Out;
        end
        else begin
        end

        if(rMicrocode[rCurrent_State][`MICROCODE_LD_OPERAND_A]) begin
            rOperand_A <= rOperand_A_Mux_Out;
        end
        else begin
        end

        if(rMicrocode[rCurrent_State][`MICROCODE_LD_OPERAND_B]) begin
            rOperand_B <= rOperand_B_Mux_Out;
        end
        else begin
        end

        rCurrent_State <= rNext_State_Mux_Out;

    end /* always */

endmodule /* controller */
