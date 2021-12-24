TB_FILES += tb.v

TB_TOP := tb

VERILOG_COMPILER := iverilog
COMPILER_OPTS := -Wall -v  -I../vmodel
DEBUG ?= 0

.PHONY:

compile:
	iverilog $(COMPILER_OPTS) $(TB_FILES) -s $(TB_TOP) -o vsim.out

run: compile
	./vsim.out	

waves:
	gtkwave test.vcd

clean:
	rm -f  *.out *.vcd *.txt
