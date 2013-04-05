module button_reader(iClk, iB0, iB1, iB2, iB3, oBtns);
    input iClk, iB0, iB1, iB2, iB3;
    output [3:0] oBtns;

    wire wB0_SP, wB1_SP, wB2_SP, wB3_SP, wB0, wB1, wB2, wB3;

    single_pulser SP0(iClk, iB0, wB0_SP, wB0); 
    single_pulser SP1(iClk, iB1, wB1_SP, wB3);
    single_pulser SP2(iClk, iB2, wB2_SP, wB2);
    single_pulser SP3(iClk, iB3, wB3_SP, wB3);


endmodule   // button_reader
