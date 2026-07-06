# -----------------------------------------------------------------------------------------
# Makefile for SRAM Controller UVM Testbench Simulation
# -----------------------------------------------------------------------------------------

# Variables for simulator command and options
XRUN = xrun
RUN_F = run.f
COV_WORK = cov_work

# Set default target
.PHONY: default compile run clean merge_cov

default: compile

# Target to compile-only and build the simulation snapshot
compile:
	$(XRUN) -compile -f $(RUN_F)

# Target to run a single test
# Default to base_test if no TEST variable is provided.
# Usage: make run TEST=addr0_test
TEST ?= base_test
run:
	$(XRUN) -f $(RUN_F) \
		-coverage all \
		-covoverwrite \
		-covtest $(TEST) \
		-covworkdir $(COV_WORK) \
		+UVM_TESTNAME=$(TEST) \
		-l $(TEST).log

# Target to clean simulation workspace
clean:
	rm -rf xcelium.d xrun.log xrun.history waves.shm
	rm -rf $(COV_WORK) merged_cov
	rm -rf *.log *.key *.history
	rm -rf ../*.log

# Target to merge coverage directories using Cadence IMC
merge_cov:
	imc -execcmd "merge $(COV_WORK)/scope/* -out merged_cov -overwrite"
