module mux2_5(iA, iB, iSel, oZ);
    input [4:0] iA, iB;
    input iSel;
    output [4:0] oZ;

    assign oZ = (iSel == 0) ? iA : iB;

endmodule   // mux2_5
