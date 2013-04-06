module single_pulser(iClk, iX, oSP, oB);
    // convert a button input signal to a single-pulse;
    // the period of iClk should be sufficiently long enough to debounce
    // the button.
    // the duration of the pulse is the period of iClk.
    input iClk, iX;
    output oSP, oB;

    wire wQ0, wQN0, wQ1, wQN1, wQ2, wQN2;

    DFF FF0(iClk, iX, wQ0, wQN0);
    DFF FF1(iClk, wQ0, wQ1, wQN1);
    DFF FF2(iClk, wQ1, wQ2, wQN2);

    // when the button signal is 0 and changes to 1,
    // the change will propogate to wQ0 and then to wQ1,
    // so the output should go high when wQ0 is 1 and wQ1 is 0
    assign oSP = wQ1 & wQ2N;
    // output the value of the first flip-flop so that the controller
    // can tell which buttons are pressed anytime a pulse is received
    assign oB = wQ1;

endmodule   // single_pulser
