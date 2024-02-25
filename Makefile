SIM ?= icarus
WAVES ?= 1
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/src/*.sv
TOPLEVEL = mdu_top
MODULE = mdu_test
include $(shell cocotb-config --makefiles)/Makefile.sim