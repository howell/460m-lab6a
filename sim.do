quit -sim
vsim work.controller
#add wave iClk oAddr iData_Bus oData_Out_Ctrl iSwtchs rDVR rSPR rDAR rCurrent_State rInput_State rOperand_A rOperand_B
force iClk 0 0ns, 1 10ns -repeat 20ns
force -deposit rInput_State 5'd1 0ns, 5'd2 40ns, 5'd8 260ns
force -deposit iSwtchs 8'h55 60ns, 8'h55 80ns
force -deposit iData_Bus 8'h55 140ns, 8'h55 260ns, 8'h55 340ns, 8'h55 400ns
run 500ns


