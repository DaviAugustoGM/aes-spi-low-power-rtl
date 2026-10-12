# ============================================================
# Sweep genérico de síntese lógica
#
# Por padrão o RTL é analisado/elaborado UMA vez e salvo como DDC
# unmapped. Cada ponto do sweep recarrega esse DDC, reaplica as
# constraints e compila. Desative com ENABLE_SWEEP_DDC_REUSE=false.
# ============================================================

set FLOW_DIR [file dirname [file normalize [info script]]]

source [file join $FLOW_DIR config.tcl]
source [file join $FLOW_DIR lib flow_utils.tcl]

if {![file exists $PRESETS_FILE]} { synth_fatal "arquivo de presets não encontrado: $PRESETS_FILE" }
source $PRESETS_FILE
if {[catch {apply_synth_preset $SYNTH_PRESET} preset_msg]} { synth_fatal $preset_msg }

if {![file exists $FEATURES_FILE]} { synth_fatal "arquivo de features/overrides não encontrado: $FEATURES_FILE" }
source $FEATURES_FILE
validate_features

source $RTL_FILELIST
source $TECH_SETUP_FILE
validate_feature_dependencies
configure_runtime
print_feature_summary

file mkdir $RUNS_DIR
set PRESET_RUNS_DIR [file join $RUNS_DIR $ACTIVE_SYNTH_PRESET]
file mkdir $PRESET_RUNS_DIR
puts "INFO: runs deste sweep: $PRESET_RUNS_DIR"

if {[llength $SWEEP_PERIODS] == 0} { synth_fatal "nenhum período foi informado para o sweep" }
if {[llength $SWEEP_MODES] == 0} { synth_fatal "nenhum modo foi informado para o sweep" }

foreach period $SWEEP_PERIODS {
  if {![string is double -strict $period] || $period <= 0.0} {
    synth_fatal "período inválido no sweep: '$period'. Use valores numéricos > 0."
  }
}
foreach mode $SWEEP_MODES { validate_compile_mode $mode }

puts "INFO: períodos do sweep : [join $SWEEP_PERIODS {, }] ns"
puts "INFO: modos do sweep    : [join $SWEEP_MODES {, }]"
puts "INFO: total de sínteses : [expr {[llength $SWEEP_PERIODS] * [llength $SWEEP_MODES]}]"
puts "INFO: reuso de DDC      : $ENABLE_SWEEP_DDC_REUSE"

set SWEEP_BASE_DDC ""
if {[feature_on ENABLE_SWEEP_DDC_REUSE]} {
  set base_dir [file join $SWEEP_CACHE_DIR $ACTIVE_SYNTH_PRESET]
  set SWEEP_BASE_DDC [prepare_sweep_base $base_dir]
}

foreach mode $SWEEP_MODES {
  foreach period $SWEEP_PERIODS {
    set period_name [string map {. p} $period]
    set run_dir [file join $PRESET_RUNS_DIR P${period_name}_${mode}]
    set run_report_dir [file join $run_dir reports]
    set run_result_dir [file join $run_dir results]

    if {[feature_on ENABLE_SWEEP_DDC_REUSE]} {
      run_synthesis_from_ddc $period $mode $run_report_dir $run_result_dir $SWEEP_BASE_DDC
    } else {
      run_synthesis $period $mode $run_report_dir $run_result_dir
    }
  }
}

synth_banner "SWEEP CONCLUÍDO"
puts "Runs do preset $ACTIVE_SYNTH_PRESET: $PRESET_RUNS_DIR"
puts "Agora gere o CSV com:"
puts "  python3 synth/scripts/collect_results.py --input synth/runs --output synth/runs/summary.csv"
quit
