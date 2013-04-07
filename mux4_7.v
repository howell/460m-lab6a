module mux4_7(iA, iB, iC, iD, iSel, oZ);
    input [6:0] iA, iB, iC, iD;
    input [1:0] iSel;
    output [6:0] oZ;

    assign oZ = (iSel == 0) ? iA : 
                (iSel == 1) ? iB :
                (iSel == 2) ? iC : iD;

endmodule   // mux4_7
