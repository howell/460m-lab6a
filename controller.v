module controller (iClk, iCs, iWe, oAddr, iData_Bus, oData_Out_Ctrl, iBtns, 
                    iSwtchs, oLeds, oSegs, oAn);

    input iClk, iCs, iWe, iData_Bus, iSwtchs;
    input [3:0] iBtns;  
    output oAddr, oData_Out_Ctrl, oLeds, oSegs, oAn;

    reg [7:0] rDVR, rDVR_Mux_Out, rALU_Out, rOperand_A_Mux_Out,
              rOperand_B_Mux_Out, rData_Out_Ctrl_Mux_Out;
    reg [6:0] rSPR, rDAR, rSPR_Mux_Out, rDAR_Mux_Out, rAddr_Mux_Out;

    reg rCurrent_State, rInput_State, rNext_State_Mux_Out;
    reg [9:0] rMicrocode [1:0];


    /* SPR Mux Inputs */
    `define SPR_MUX_INIT        0
    `define SPR_MUX_SPR_SUB_ONE 1
    `define SPR_MUX_SPR_ADD_ONE 2
    `define MICROCODE_SPR_MUX_SELECT 1:0
    `define MICROCODE_LD_SPR           2

    /* DAR Mux Select */
    `define DAR_MUX_INIT        0
    `define DAR_MUX_SPR_ADD_ONE 1
    `define DAR_MUX_DAR_SUB_ONE 2
    `define DAR_MUX_DAR_ADD_ONE 3
    `define MICROCODE_DAR_MUX_SELECT 4:3
    `define MICROCODE_LD_DAR           5

    /* DVR Mux Select */
    `define DVR_MUX_INIT    0 
    `define DVR_MUX_DATA_IN 1
    `define DVR_MUX_ALU_OUT 2
    `define MICROCODE_DVR_MUX_SELECT 7:6 
    `define MICROCODE_LD_DVR           8

    /* Addr Mux Select */
    `define ADDR_MUX_SPR 0
    `define ADDR_MUX_DAR 1
    `define MICROCODE_ADDR_MUX_SELECT 9

    /* Operand A Mux Select */
    `define OPERAND_A_MUX_DVR     0
    `define OPERAND_A_MUX_DATA_IN 1
    `define MICROCODE_OPERAND_A_MUX_SELECT 10

    /* Operand B Mux Select */
    `define OPERAND_B_MUX_DVR     0
    `define OPERAND_B_MUX_DATA_IN 1
    `define MICROCODE_OPERAND_B_MUX_SELECT 11

    /* ALU Select */
    `define ALU_ADD 0
    `define ALU_SUB 1
    `define MICROCODE_ALU_SELECT 12 

    /* Data Out Mux */
    `define DATA_OUT_CTRL_MUX_VAL 0
    `define DATA_OUT_CTRL_MUX_ALU 1
    `define MICROCODE_DATA_OUT_CTRL_MUX_SELECT 13

    /* Next State Mux Select */
    `define NEXT_STATE_MUX_MICROCODE   0 
    `define NEXT_STATE_MUX_INPUT 1 
    `define MICROCODE_NEXT_STATE_MUX 14
    `define MICROCODE_NEXT_STATE 15 /* TODO */

    `define MICROCODE_CS    16
    `define MICROCODE_WE    17

    assign oAddr = rAddr_Mux_Out;
    assign oData_Out_Ctrl = rData_Out_Ctr_Mux_Out;

    initial begin
        rCurrent_State = 0;
    end

    /* SPR Mux */
    always @(*) begin
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

    /* DAR Mux */
    always @(*) begin
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

    /* DVR Mux */
    always @(*) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_DVR_MUX_SELECT])
            `DVR_MUX_INIT: begin
                rDVR_Mux_Out <= 7'h00;
            end
            `DVR_MUX_DATA_IN: begin
                rDVR_Mux_Out <= iData_Bus;
            end
            `DVR_MUX_ALU_OUT: begin
                rDVR_Mux_Out <= rALU_Out; 
            end
            default: begin
            end
        endcase
    end /* always */

    /* Addr Mux */
    always @(*) begin
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
    always @(*) begin
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
    always @(*) begin
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

    /* ALU */
    always @(*) begin
        case(rMicrocode[rCurrent_State][`MICROCODE_ALU_SELECT])
            `ALU_ADD: begin
                rALU_Out <= rOperand_A_Mux_Out + rOperand_B_Mux_Out;
            end
            `ALU_SUB: begin
                rALU_Out <= rOperand_A_Mux_Out - rOperand_B_Mux_Out;
            end
            default: begin
            end
        endcase
    end /* always */
    
    /* Data Out Mux */
    always @(*) begin
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
    always @(*) begin
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

    always @(posedge iClk) begin

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

        
        rCurrent_State <= rNext_State_Mux_Out;

    end /* always */

endmodule /* controller */
