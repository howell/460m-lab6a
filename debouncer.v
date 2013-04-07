module debouncer(iClk, iX, oB);
    // debounce a button signal
    // iClk period should be sufficient to avoid any transients (~10ms)
    input iClk, iX;
    output oB;

    wire wQ0, wQN0, wQN1;

    DFF FF0(iClk, iX, wQ0, wQN0);
    DFF FF1(iClk, wQ0, oB, wQN1);

//    assign oB = wQ1;

endmodule   // debouncer 
