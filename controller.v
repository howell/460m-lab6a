module controller (clk, oCs, oWe, oAddr, iData_Bus, 
    oData_Out_Ctrl, iBtns, iSwtchs, oLeds, oSegs, oAn);

    input clk;
    input [7:0] iData_Bus, iSwtchs;
    input [3:0] iBtns;  
    output [3:0] oAn;
    output [6:0] oAddr;
    output [7:0] oData_Out_Ctrl, oSegs, oLeds;
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
    wire [23:0] wNext_MicroOp;

    reg [7:0] rDVR, rOperand_A, rOperand_B;
    reg [6:0] rSPR, rDAR;
    reg [23:0] rMicroOp;

    reg [4:0] rCurrent_State;
	 
    `define MICROCODE_NEXT_STATE                    4:0
    `define MICROCODE_WE                            5
    `define MICROCODE_CS                            6
    `define MICROCODE_NEXT_STATE_MUX                7
    `define MICROCODE_DATA_OUT_CTRL_MUX_SELECT      8
    `define MICROCODE_ALU_SELECT                    9 
    `define MICROCODE_LD_OPERAND_B                  10
    `define MICROCODE_OPERAND_B_MUX_SELECT          11
    `define MICROCODE_LD_OPERAND_A                  12
    `define MICROCODE_OPERAND_A_MUX_SELECT          13
    `define MICROCODE_ADDR_MUX_SELECT               14
    `define MICROCODE_LD_DVR                        15
    `define MICROCODE_DVR_MUX_SELECT                17:16 
    `define MICROCODE_LD_DAR                        18
    `define MICROCODE_DAR_MUX_SELECT                20:19
    `define MICROCODE_LD_SPR                        21
    `define MICROCODE_SPR_MUX_SELECT                23:22

	 clk_div sevseg_clk(clk, 25000, wClk_1ms);
	 button_fsm fsm(clk, iBtns, rInput_State);
	 sevenseg_controller sevseg(4'h3, wClk_1ms, 0, 0, 
                    rDVR[7:4], rDVR[3:0], oAn, oSegs);


     assign oAddr = wAddr_Mux_Out;
     assign oData_Out_Ctrl = wData_Out_Ctrl_Mux_Out;
     assign oWe = rMicroOp[`MICROCODE_WE];
     assign oCs = rMicroOp[`MICROCODE_CS];
     assign oLeds[6:0] = rDAR;
     assign oLeds[7] = (rSPR == 7'h7F) ? 1 : 0;
	 
    initial begin
        rCurrent_State = 0;
        rDVR = 8'hFF;
        rDAR = 7'h7F;
        rSPR = 7'h00;
    end

    /* SPR Mux inputs */
    assign wSPRp1 = rSPR + 1;
    assign wSPRm1 = rSPR - 1;

    /* SPR Mux */
    mux4_7 spr_mux(7'h7F, wSPRm1, wSPRp1, 0,
                   rMicroOp[`MICROCODE_SPR_MUX_SELECT],
                   wSPR_Mux_Out);

    /* DAR Mux inputs */
    assign wDARp1 = rDAR + 1;
    assign wDARm1 = rDAR - 1;

    /* DAR Mux */
    mux4_7 dar_mux(7'h00, wSPRp1, wDARm1, wDARp1,
                   rMicroOp[`MICROCODE_DAR_MUX_SELECT],
                   wDAR_Mux_Out);

    /* DVR Mux */
    mux4_8 dvr_mux(8'h00, iData_Bus, wALU_Out, iSwtchs,
                   rMicroOp[`MICROCODE_DVR_MUX_SELECT],
                   wDVR_Mux_Out);

    /* Addr Mux */
    mux2_7 addr_mux(rSPR, rDAR,
                    rMicroOp[`MICROCODE_ADDR_MUX_SELECT],
                    wAddr_Mux_Out);

    /* Operand A Mux */
    mux2_8 opA_mux(rDVR, iData_Bus,
                   rMicroOp[`MICROCODE_OPERAND_A_MUX_SELECT],
                   wOperand_A_Mux_Out);

    /* Operand B Mux */
    mux2_8 opB_mux(rDVR, iData_Bus,
                   rMicroOp[`MICROCODE_OPERAND_B_MUX_SELECT],
                   wOperand_B_Mux_Out);

    /* ALU inputs */
    assign wALU_Add = rOperand_A + rOperand_B;
    assign wALU_Sub = rOperand_A - rOperand_B;

    /* ALU */
    mux2_8 alu(wALU_Add, wALU_Sub,
               rMicroOp[`MICROCODE_ALU_SELECT],
               wALU_Out);
    
    /* Data Out Mux */
    mux2_8 dataOut_mux(iSwtchs, wALU_Out,
                      rMicroOp[`MICROCODE_DATA_OUT_CTRL_MUX_SELECT],
                      wData_Out_Ctrl_Mux_Out);
    
    /* Next State Mux */
    mux2_5 nextState_Mux(rMicroOp[`MICROCODE_NEXT_STATE],
                         rInput_State,
                         rMicroOp[`MICROCODE_NEXT_STATE_MUX],
                         wNext_State_Mux_Out);

    /* Microcode ROM */
    microcode_rom ucode_rom(clk, wNext_State_Mux_Out, 
                            wNext_MicroOp);

    always @(posedge clk) begin

        if(rMicroOp[`MICROCODE_LD_SPR]) begin
            rSPR <= wSPR_Mux_Out;
        end
        else begin
        end

        if(rMicroOp[`MICROCODE_LD_DAR]) begin
            rDAR <= wDAR_Mux_Out;
        end
        else begin
        end

        if(rMicroOp[`MICROCODE_LD_DVR]) begin
            rDVR <= wDVR_Mux_Out;
        end
        else begin
        end

        if(rMicroOp[`MICROCODE_LD_OPERAND_A]) begin
            rOperand_A <= wOperand_A_Mux_Out;
        end
        else begin
        end

        if(rMicroOp[`MICROCODE_LD_OPERAND_B]) begin
            rOperand_B <= wOperand_B_Mux_Out;
        end
        else begin
        end

        rCurrent_State <= wNext_State_Mux_Out; // TODO
        rMicroOp <= wNext_MicroOp;

    end /* always */

endmodule /* controller */
