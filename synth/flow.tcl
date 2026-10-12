# ============================================================
# FLUXO GENÉRICO de síntese
#
# Execute de qualquer diretório:
#   dc_shell -f /caminho/projeto/synth/flow.tcl
#
# Overrides úteis:
#   SYNTH_PERIOD=8 SYNTH_MODE=autoungroup dc_shell -f synth/flow.tcl
#   SYNTH_PRESET=timing dc_shell -f synth/flow.tcl
#   SYNTH_FEATURES_FILE=synth/features_custom.tcl dc_shell -f synth/flow.tcl
# ============================================================

set FLOW_DIR [file dirname [file normalize [info script]]]

source [file join $FLOW_DIR config.tcl]
source [file join $FLOW_DIR lib flow_utils.tcl]

if {![file exists $PRESETS_FILE]} {
  synth_fatal "arquivo de presets não encontrado: $PRESETS_FILE"
}
source $PRESETS_FILE

if {[catch {apply_synth_preset $SYNTH_PRESET} preset_msg]} {
  synth_fatal $preset_msg
}

if {![file exists $FEATURES_FILE]} {
  synth_fatal "arquivo de features/overrides não encontrado: $FEATURES_FILE"
}
source $FEATURES_FILE
validate_features

source $RTL_FILELIST
source $TECH_SETUP_FILE
validate_feature_dependencies
configure_runtime
print_feature_summary

run_synthesis $CLOCK_PERIOD $COMPILE_MODE $REPORT_DIR $RESULT_DIR

puts "Relatórios: $REPORT_DIR"
puts "Resultados: $RESULT_DIR"
puts "Dica: rode 'python3 synth/scripts/collect_results.py --input synth --output synth/summary.csv' para gerar o resumo."

quit
