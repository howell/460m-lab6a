module button_reader(iClk, iB0, iB1, iB2, iB3, oBtns);
    input iClk, iB0, iB1, iB2, iB3;
    output [3:0] oBtns;

    // button presses for commands
    `define CMD_PSH 4'b0001
    `define CMD_POP 4'b0010
    `define CMD_ADD 4'b0101
    `define CMD_SUB 4'b0110
    `define CMD_TOP 4'b1001
    `define CMD_RST 4'b1010
    `define CMD_INC 4'b1101
    `define CMD_DEC 4'b1110

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

    wire wB0_SP, wB1_SP, wB2_SP, wB3_SP, wB0, wB1, wB2, wB3;
    reg oBtns, rNBtns;

    initial begin
        oBtns = 0;
        rNBtns = 0;
    end

    single_pulser SP0(iClk, iB0, wB0_SP, wB0); 
    single_pulser SP1(iClk, iB1, wB1_SP, wB1);
    single_pulser SP2(iClk, iB2, wB2_SP, wB2);
    single_pulser SP3(iClk, iB3, wB3_SP, wB3);

    always @(*) begin
       // only output a new value if a pulse is detected
       if(wB0_SP | wB1_SP | wB2_SP | wB3_SP) begin
            case({wB3, wB2, wB1, wB0})
                `CMD_PSH: begin
                    rNBtns = `ST_PSH;
                end

                `CMD_POP: begin
                    rNBtns = `ST_POP;
                end

                `CMD_ADD: begin
                    rNBtns = `ST_ADD;
                end

                `CMD_SUB: begin
                    rNBtns = `ST_SUB;
                end

                `CMD_TOP: begin
                    rNBtns = `ST_TOP;
                end

                `CMD_RST: begin
                    rNBtns = `ST_RST;
                end

                `CMD_INC: begin
                    rNBtns = `ST_INC;
                end

                `CMD_DEC: begin
                    rNBtns = `ST_DEC;
                end

                default: begin
                    rNBtns = `ST_IDLE;
                end
            endcase
       end  
       else begin
           rNBtns = 0;
       end  // if
    end // always

    always @(posedge iClk) begin
        oBtns <= rNBtns;
    end


endmodule   // button_reader
