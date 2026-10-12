PYTHON ?= python3
SIMULATOR ?= auto

.PHONY: check lint sim smoke syntax run synth sweep presets formal collect_synth
check:
	$(PYTHON) scripts/run.py check
lint:
	$(PYTHON) scripts/run.py lint
sim:
	$(PYTHON) scripts/run.py sim --simulator $(SIMULATOR)
smoke:
	$(PYTHON) scripts/run.py smoke --simulator $(SIMULATOR)
syntax: lint
run: sim
synth:
	dc_shell -f synth/flow.tcl
sweep:
	dc_shell -f synth/sweep.tcl
presets:
	tclsh synth/list_presets.tcl
formal:
	fm_shell -f fm/formality.tcl
collect_synth:
	$(PYTHON) synth/scripts/collect_results.py --input synth --output synth/summary.csv
