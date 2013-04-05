module switch_debouncer(iCLK, iX, oZ);

    input iCLK, iX;
    output oZ;

    reg rState, rNextState, rTempZ;
    reg rQ1, rQ2;
    wire wY;

    assign wY = rQ1 & rQ2; /* debouncing */
    assign oZ = rTempZ;

    initial
    begin
        rTempZ = 0;
        rState = 0;
        rNextState = 0;
    end

    always @(rState, iX) /* single pulser FSM */
    begin
        case(rState)
            0: begin
                if(wY) begin
                    rTempZ <= 1;
                    rNextState <= 1;
                end
                else begin
                    rTempZ <= 0;
                    rNextState <= 0;
                end
            end
            1: begin
                if(wY) begin
                    rTempZ <= 0;
                    rNextState <= 1;
                end
                else begin
                    rTempZ <= 0;
                    rNextState <= 0;
                end
            end
            default: begin
            end
        endcase
    end /* always */

    always @(posedge iCLK)
    begin
       rQ1 <= iX;
       rQ2 <= rQ1;
       rState = rNextState;
    end /* always */



endmodule /* switch_debouncer */
