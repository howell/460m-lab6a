module memory(iClk, iCS, iWE, iAddr, iDin, oDout);
    input iClk, iCS, iWE;
    input [6:0] iAddr;
    input [7:0] iDin;
    output [7:0] oDout;

    reg [7:0] oDout;
    reg[7:0] rRAM[0:127];
    integer i;
    
    initial begin
       for(i = 0; i < 128; i = i + 1) begin
         rRAM[i] = 8'h00;
       end
    end

    always @(negedge iClk) begin
        if ((iWE == 1) && (iCS == 1)) begin
            rRAM[iAddr] <= iDin[7:0];
        end
        else begin
        end

        oDout <= rRAM[iAddr];
    end // always
endmodule   // memory
