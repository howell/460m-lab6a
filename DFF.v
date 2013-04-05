module DFF(iClk, iD, oQ, oQN);
    input iClk, iD;
    output oQ, oQN;

    reg oQ, oQN;

    initial begin
        oQ = 0;
        oQN = 1;
    end // initial

    always @(posedge iClk) begin
        oQ <= iD;
        oQN <= ~iD;
    end // always

endmodule // module DFF
