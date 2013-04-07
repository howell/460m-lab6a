quit -sim
vsim work.top
add wave clk iBtns iSwtchs oLEDS oSegs oAN oBus oCs oWe oAddr oData_Out_Ctrl oData_Out_Mem oNext_State

force clk 0 0ns, 1 10ns -repeat 20ns
force -deposit iBtns 4'd0 0ns, 5'd1 40ns, 5'd0 140ns
force -deposit iSwtchs 8'h55 60ns, 8'h55 80ns
run 1000
