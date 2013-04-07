module memory(iClk, iCS, iWE, iAddr, iDin, oDout);
    input iClk, iCS, iWE;
    input [6:0] iAddr;
    input [7:0] iDin;
    output [7:0] oDout;

    reg [7:0] oDout;

    reg[7:0] rRAM[0:127];

    always @(negedge iClk) begin
        if ((iWE == 1) && (iCS == 1))
            rRAM[iAddr] <= iDin[7:0];

        oDout <= rRAM[iAddr];
    end // always
endmodule   // memory
