module DFF(iClk, iD, oQ);
    input iClk, iD;
    output oQ;

    reg oQ;

    initial begin
        oQ = 0;
    end // initial

    always @(posedge iClk) begin
        oQ <= iD;
    end // always

endmodule // module DFF
