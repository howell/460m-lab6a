module mux4_8(iA, iB, iC, iD, iSel, oZ);
    input [7:0] iA, iB, iC, iD;
    input [1:0] iSel;
    output [7:0] oZ;

    assign oZ = (iSel == 0) ? iA : 
                (iSel == 1) ? iB :
                (iSel == 2) ? iC : iD;

endmodule   // mux4_8
