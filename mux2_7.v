module mux2_7(iA, iB, iSel, oZ);
    input [6:0] iA, iB;
    input iSel;
    output [6:0] oZ;

    assign oZ = (iSel == 0) ? iA : iB;

endmodule   // mux2_7
