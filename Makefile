# Fluxo mínimo: make test (local) ou make test TOOLCHAIN=synopsys
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c
.DEFAULT_GOAL := test

TOOLCHAIN ?= open
BUILD := build
LOG_DIR := docs/reports/logs
RTL_F := scripts/rtl.f
TB_F := scripts/tb.f

ifeq ($(TOOLCHAIN),open)
LINT := verilator --lint-only -Wall --top-module aes_spi_top -f $(RTL_F)
COMPILE := iverilog -g2012 -Wall -s tb_smoke -f $(RTL_F) -f $(TB_F) -o $(BUILD)/simv
SIM := vvp simv
TOOLS := verilator iverilog vvp
else ifeq ($(TOOLCHAIN),synopsys)
LINT := spyglass -batch -project scripts/lint.prj -goals lint/lint_rtl
COMPILE := vcs -full64 -sverilog -timescale=1ns/1ps -top tb_smoke -f $(RTL_F) -f $(TB_F) -o $(BUILD)/simv
SIM := ./simv -no_save
TOOLS := spyglass vcs
else
$(error TOOLCHAIN deve ser open ou synopsys)
endif

.PHONY: test check-env lint compile sim smoke run
test: lint sim
	@echo "PASS: fluxo mínimo concluído"

check-env:
	@for tool in $(TOOLS); do 		command -v $$tool >/dev/null || { echo "Ferramenta ausente: $$tool (veja README.md)"; exit 1; }; 	done
	@mkdir -p $(BUILD) $(LOG_DIR)

lint: check-env
	$(LINT) 2>&1 | tee $(LOG_DIR)/$(TOOLCHAIN)_lint.log

compile: check-env
	$(COMPILE) 2>&1 | tee $(LOG_DIR)/$(TOOLCHAIN)_compile.log

sim: compile
	cd $(BUILD) && $(SIM) 2>&1 | tee ../$(LOG_DIR)/$(TOOLCHAIN)_sim.log

smoke: test
run: sim
