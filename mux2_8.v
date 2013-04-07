module mux2_8(iA, iB, iSel, oZ);
    input [7:0] iA, iB;
    input iSel;
    output [7:0] oZ;

    assign oZ = (iSel == 0) ? iA : iB;

endmodule   // mux2_8
