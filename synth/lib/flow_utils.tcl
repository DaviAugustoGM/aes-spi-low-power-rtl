# ============================================================
# Utilitários genéricos do fluxo de síntese lógica
# ============================================================

proc synth_banner {message} {
  puts "============================================================"
  puts $message
  puts "============================================================"
}

proc synth_fatal {message} {
  synth_banner "ERRO DE SÍNTESE: $message"
  exit 1
}

proc feature_names {} {
  return [list \
    ENABLE_FIX_MULTIPLE_PORT_NETS \
    ENABLE_CHANGE_NAMES \
    ENABLE_CHECK_DESIGN_POST \
    ENABLE_REPORT_AREA \
    ENABLE_REPORT_TIMING \
    ENABLE_REPORT_POWER \
    ENABLE_REPORT_CONSTRAINTS \
    ENABLE_REPORT_QOR \
    ENABLE_CHECK_TIMING_PRE \
    ENABLE_REPORT_CHECK_TIMING_POST \
    ENABLE_REPORT_DESIGN \
    ENABLE_REPORT_CLOCK \
    ENABLE_REPORT_RESOURCES \
    ENABLE_REPORT_REFERENCES \
    ENABLE_REPORT_HIERARCHY \
    ENABLE_REPORT_FSM \
    ENABLE_REPORT_PATH_GROUPS \
    ENABLE_REPORT_COMPILE_OPTIONS \
    ENABLE_REPORT_TIMING_REQUIREMENTS \
    ENABLE_REPORT_SAIF \
    ENABLE_CLOCK_TRANSITION \
    ENABLE_USER_DRC \
    ENABLE_MIN_MAX_LIBS \
    ENABLE_FIX_HOLD \
    ENABLE_CRITICAL_RANGE \
    ENABLE_AUTO_PATH_GROUPS \
    ENABLE_CLOCK_GATING \
    ENABLE_READ_SAIF \
    ENABLE_DYNAMIC_POWER_OPTIMIZATION \
    ENABLE_INCREMENTAL_COMPILE \
    ENABLE_RETIMING \
    ENABLE_OPTIMIZE_NETLIST_AREA \
    ENABLE_WRITE_UNMAPPED_DDC \
    ENABLE_WRITE_MAPPED_DDC \
    ENABLE_WRITE_NETLIST \
    ENABLE_WRITE_SDC \
    ENABLE_WRITE_SDF \
    ENABLE_WRITE_SVF \
    ENABLE_SWEEP_DDC_REUSE \
    ENABLE_MULTICORE \
  ]
}

proc feature_on {name} {
  if {![info exists ::$name]} {
    synth_fatal "feature '$name' não foi definida pelo preset nem pelos overrides"
  }

  set value [string tolower [string trim [set ::$name]]]
  if {$value ne "true" && $value ne "false"} {
    synth_fatal "feature '$name' deve ser exatamente true ou false; recebido '[set ::$name]'"
  }
  return [expr {$value eq "true"}]
}

proc validate_features {} {
  foreach feature [feature_names] {
    feature_on $feature
  }
}

proc validate_feature_dependencies {} {
  global MAX_OPERATING_CONDITION MIN_OPERATING_CONDITION SAIF_FILE

  if {[feature_on ENABLE_MIN_MAX_LIBS]} {
    if {![info exists ::HAS_MIN_LIBRARY] || !$::HAS_MIN_LIBRARY} {
      synth_fatal "ENABLE_MIN_MAX_LIBS=true requer uma SAED32_MIN_LIB válida."
    }
    if {[string trim $MAX_OPERATING_CONDITION] eq "" || [string trim $MIN_OPERATING_CONDITION] eq ""} {
      synth_fatal "ENABLE_MIN_MAX_LIBS=true requer MAX_OPERATING_CONDITION e MIN_OPERATING_CONDITION (ou MAX_OPCOND/MIN_OPCOND no make)."
    }
  }

  if {[feature_on ENABLE_FIX_HOLD] && ![feature_on ENABLE_MIN_MAX_LIBS]} {
    synth_fatal "ENABLE_FIX_HOLD=true requer ENABLE_MIN_MAX_LIBS=true."
  }

  if {[feature_on ENABLE_RETIMING] && ![feature_on ENABLE_WRITE_SVF]} {
    synth_fatal "ENABLE_RETIMING=true requer ENABLE_WRITE_SVF=true para guidance de verificação."
  }

  if {[feature_on ENABLE_OPTIMIZE_NETLIST_AREA] && [llength [info commands optimize_netlist]] == 0} {
    synth_fatal "ENABLE_OPTIMIZE_NETLIST_AREA=true, mas optimize_netlist não está disponível."
  }

  if {[feature_on ENABLE_CLOCK_GATING] && [llength [info commands set_clock_gating_style]] == 0} {
    synth_fatal "ENABLE_CLOCK_GATING=true, mas clock-gating/Power Compiler não parece disponível."
  }

  if {[feature_on ENABLE_AUTO_PATH_GROUPS] && [llength [info commands create_auto_path_groups]] == 0} {
    synth_fatal "ENABLE_AUTO_PATH_GROUPS=true, mas create_auto_path_groups não está disponível."
  }

  if {[feature_on ENABLE_DYNAMIC_POWER_OPTIMIZATION] && [llength [info commands set_dynamic_optimization]] == 0} {
    synth_fatal "ENABLE_DYNAMIC_POWER_OPTIMIZATION=true, mas set_dynamic_optimization não está disponível."
  }

  if {[feature_on ENABLE_READ_SAIF]} {
    if {[string trim $SAIF_FILE] eq ""} {
      synth_fatal "ENABLE_READ_SAIF=true, mas SAIF_FILE não foi definido."
    }
    if {![file exists $SAIF_FILE]} {
      synth_fatal "arquivo SAIF não encontrado: $SAIF_FILE"
    }
    if {[llength [info commands read_saif]] == 0} {
      synth_fatal "ENABLE_READ_SAIF=true, mas read_saif não está disponível."
    }
  }

  if {[feature_on ENABLE_DYNAMIC_POWER_OPTIMIZATION] && ![feature_on ENABLE_READ_SAIF]} {
    puts "AVISO: otimização dinâmica ativa sem SAIF; o resultado dependerá da atividade default/anotada manualmente."
  }

  if {[feature_on ENABLE_AUTO_PATH_GROUPS] && [feature_on ENABLE_INCREMENTAL_COMPILE]} {
    puts "AVISO: AUTO_PATH_GROUPS já executa um passe incremental; não será criado um terceiro compile."
  }
}

proc validate_run_parameters {period mode} {
  global CRITICAL_RANGE
  validate_compile_mode $mode

  if {![string is double -strict $period] || $period <= 0.0} {
    synth_fatal "período inválido: '$period'. Use valor numérico > 0."
  }

  if {[feature_on ENABLE_CRITICAL_RANGE]} {
    if {![string is double -strict $CRITICAL_RANGE] || $CRITICAL_RANGE <= 0.0} {
      synth_fatal "CRITICAL_RANGE deve ser numérico e maior que zero."
    }
    if {$CRITICAL_RANGE > (0.10 * double($period))} {
      puts "AVISO: CRITICAL_RANGE=$CRITICAL_RANGE é maior que 10% do período $period ns; runtime pode aumentar."
    }
  }
}

proc print_feature_summary {} {
  global TOP CLOCK_PERIOD COMPILE_MODE MAX_CORES ACTIVE_SYNTH_PRESET ACTIVE_SYNTH_PRESET_DESCRIPTION
  global MAX_OPERATING_CONDITION MIN_OPERATING_CONDITION SAIF_FILE SAIF_INSTANCE

  synth_banner "SYNTHESIS CONFIGURATION"
  puts [format "%-36s : %s" "TOP" $TOP]
  puts [format "%-36s : %s ns" "CLOCK PERIOD" $CLOCK_PERIOD]
  puts [format "%-36s : %s" "COMPILE MODE" $COMPILE_MODE]
  puts [format "%-36s : %s" "PRESET" $ACTIVE_SYNTH_PRESET]
  puts [format "%-36s : %s" "PRESET DESCRIPTION" $ACTIVE_SYNTH_PRESET_DESCRIPTION]
  puts [format "%-36s : %s" "FEATURES FILE" $::FEATURES_FILE]
  puts [format "%-36s : %s" "MAX OPERATING CONDITION" [expr {$MAX_OPERATING_CONDITION eq "" ? "<library default>" : $MAX_OPERATING_CONDITION}]]
  puts [format "%-36s : %s" "MIN OPERATING CONDITION" [expr {$MIN_OPERATING_CONDITION eq "" ? "<not set>" : $MIN_OPERATING_CONDITION}]]
  puts [format "%-36s : %s" "SAIF FILE" [expr {$SAIF_FILE eq "" ? "<not set>" : $SAIF_FILE}]]
  if {$SAIF_INSTANCE ne ""} {
    puts [format "%-36s : %s" "SAIF INSTANCE" $SAIF_INSTANCE]
  }
  puts "------------------------------------------------------------"
  foreach feature [feature_names] {
    puts [format "%-36s : %s" $feature [set ::$feature]]
  }
  if {[feature_on ENABLE_MULTICORE]} {
    puts [format "%-36s : %s" "MAX_CORES" $MAX_CORES]
  }
  puts "============================================================"
}

proc validate_compile_mode {mode} {
  if {$mode ne "no_autoungroup" && $mode ne "autoungroup"} {
    synth_fatal "COMPILE_MODE inválido: '$mode'. Use no_autoungroup ou autoungroup."
  }
}

proc configure_runtime {} {
  global MAX_CORES
  if {[feature_on ENABLE_MULTICORE]} {
    if {![string is integer -strict $MAX_CORES] || $MAX_CORES < 1} {
      synth_fatal "MAX_CORES deve ser inteiro >= 1."
    }
    puts "INFO: multicore habilitado: max_cores=$MAX_CORES"
    set_host_options -max_cores $MAX_CORES
  }
}

proc write_run_metadata {run_dir period mode input_source input_path svf_file retiming_pass} {
  global TOP PROJECT_NAME TECH_NAME FEATURES_FILE ACTIVE_SYNTH_PRESET ACTIVE_SYNTH_PRESET_DESCRIPTION
  global MAX_OPERATING_CONDITION MIN_OPERATING_CONDITION SAIF_FILE SAIF_INSTANCE

  set fp [open [file join $run_dir run_metadata.txt] "w"]
  puts $fp "project=$PROJECT_NAME"
  puts $fp "top=$TOP"
  puts $fp "technology=$TECH_NAME"
  puts $fp "period_ns=$period"
  puts $fp "frequency_mhz=[expr {1000.0 / double($period)}]"
  puts $fp "mode=$mode"
  puts $fp "preset=$ACTIVE_SYNTH_PRESET"
  puts $fp "preset_description=$ACTIVE_SYNTH_PRESET_DESCRIPTION"
  puts $fp "features_file=[file normalize $FEATURES_FILE]"
  puts $fp "input_source=$input_source"
  puts $fp "input_path=$input_path"
  puts $fp "retiming_pass=$retiming_pass"
  puts $fp "max_operating_condition=$MAX_OPERATING_CONDITION"
  puts $fp "min_operating_condition=$MIN_OPERATING_CONDITION"
  puts $fp "saif_file=$SAIF_FILE"
  puts $fp "saif_instance=$SAIF_INSTANCE"
  puts $fp "power_activity=[expr {[feature_on ENABLE_READ_SAIF] ? "saif" : "default_or_manual"}]"
  puts $fp "svf_file=$svf_file"

  foreach feature [feature_names] {
    puts $fp "feature.$feature=[set ::$feature]"
  }
  close $fp
}

proc run_optional_report {feature report_path report_script} {
  if {![feature_on $feature]} { return }
  if {[catch {redirect $report_path $report_script} report_msg]} {
    puts "AVISO: falha ao gerar [file tail $report_path]: $report_msg"
  }
}

proc check_design_gate {report_path stage} {
  set ::__check_design_ok 1
  if {[catch {
    redirect $report_path { set ::__check_design_ok [check_design] }
  } check_msg]} {
    catch {unset ::__check_design_ok}
    synth_fatal "check_design ($stage) falhou: $check_msg"
  }
  if {!$::__check_design_ok} {
    unset ::__check_design_ok
    synth_fatal "check_design ($stage) encontrou erro. Veja $report_path"
  }
  unset ::__check_design_ok
}

proc report_post_synthesis {report_dir} {
  global TIMING_MAX_PATHS

  run_optional_report ENABLE_REPORT_AREA [file join $report_dir area.rpt] {report_area -hierarchy}

  if {[feature_on ENABLE_REPORT_TIMING]} {
    run_optional_report ENABLE_REPORT_TIMING [file join $report_dir timing_setup.rpt] \
      [list report_timing -max_paths $TIMING_MAX_PATHS -delay_type max]
    run_optional_report ENABLE_REPORT_TIMING [file join $report_dir timing_hold.rpt] \
      [list report_timing -max_paths $TIMING_MAX_PATHS -delay_type min]
  }

  run_optional_report ENABLE_REPORT_POWER [file join $report_dir power.rpt] {report_power}
  run_optional_report ENABLE_REPORT_CONSTRAINTS [file join $report_dir constraints.rpt] {report_constraint -all_violators}
  run_optional_report ENABLE_REPORT_QOR [file join $report_dir qor.rpt] {report_qor}
  run_optional_report ENABLE_REPORT_CHECK_TIMING_POST [file join $report_dir check_timing_post.rpt] {check_timing}
  run_optional_report ENABLE_REPORT_DESIGN [file join $report_dir design.rpt] {report_design}
  run_optional_report ENABLE_REPORT_CLOCK [file join $report_dir clock.rpt] {report_clock}
  run_optional_report ENABLE_REPORT_RESOURCES [file join $report_dir resources.rpt] {report_resources}
  run_optional_report ENABLE_REPORT_REFERENCES [file join $report_dir references.rpt] {report_reference -hierarchy}
  run_optional_report ENABLE_REPORT_HIERARCHY [file join $report_dir hierarchy.rpt] {report_hierarchy}
  run_optional_report ENABLE_REPORT_FSM [file join $report_dir fsm.rpt] {report_fsm}
  run_optional_report ENABLE_REPORT_PATH_GROUPS [file join $report_dir path_groups.rpt] {report_path_group}
  run_optional_report ENABLE_REPORT_COMPILE_OPTIONS [file join $report_dir compile_options.rpt] {report_compile_options}
  run_optional_report ENABLE_REPORT_TIMING_REQUIREMENTS [file join $report_dir timing_requirements.rpt] {report_timing_requirements}

  if {[feature_on ENABLE_REPORT_SAIF]} {
    if {[llength [info commands report_saif]] == 0} {
      puts "AVISO: ENABLE_REPORT_SAIF=true, mas report_saif não está disponível."
    } else {
      run_optional_report ENABLE_REPORT_SAIF [file join $report_dir saif.rpt] {report_saif}
    }
  }
}

proc compile_current_design {mode {incremental 0} {retime 0}} {
  validate_compile_mode $mode
  set compile_args [list]

  if {$mode eq "no_autoungroup"} { lappend compile_args -no_autoungroup }
  if {$incremental} { lappend compile_args -incremental }
  if {$retime} { lappend compile_args -retime }
  if {[feature_on ENABLE_CLOCK_GATING]} { lappend compile_args -gate_clock }

  puts "INFO: compile_ultra [join $compile_args { }]"
  if {[catch {eval [linsert $compile_args 0 compile_ultra]} compile_msg]} {
    synth_fatal "compile_ultra falhou: $compile_msg"
  }
}

proc needs_second_pass {} {
  return [expr {[feature_on ENABLE_AUTO_PATH_GROUPS] || [feature_on ENABLE_INCREMENTAL_COMPILE]}]
}

proc apply_operating_conditions {} {
  global MAX_OPERATING_CONDITION MIN_OPERATING_CONDITION

  if {[feature_on ENABLE_MIN_MAX_LIBS]} {
    puts "INFO: operating conditions min/max: max=$MAX_OPERATING_CONDITION min=$MIN_OPERATING_CONDITION"
    if {[catch {
      set_operating_conditions -max $MAX_OPERATING_CONDITION -min $MIN_OPERATING_CONDITION
    } op_msg]} {
      synth_fatal "set_operating_conditions min/max falhou: $op_msg"
    }
  } elseif {[string trim $MAX_OPERATING_CONDITION] ne ""} {
    puts "INFO: operating condition explícita: $MAX_OPERATING_CONDITION"
    if {[catch {set_operating_conditions $MAX_OPERATING_CONDITION} op_msg]} {
      synth_fatal "set_operating_conditions falhou: $op_msg"
    }
    if {[string trim $MIN_OPERATING_CONDITION] ne ""} {
      puts "AVISO: MIN_OPERATING_CONDITION foi definida, mas ENABLE_MIN_MAX_LIBS=false; valor mínimo ignorado."
    }
  }
}

proc apply_power_activity {} {
  global SAIF_FILE SAIF_INSTANCE

  if {[feature_on ENABLE_DYNAMIC_POWER_OPTIMIZATION]} {
    puts "INFO: set_dynamic_optimization true"
    if {[catch {set_dynamic_optimization true} dyn_msg]} {
      synth_fatal "set_dynamic_optimization falhou: $dyn_msg"
    }
  }

  if {[feature_on ENABLE_READ_SAIF]} {
    set saif_args [list -input $SAIF_FILE]
    if {[string trim $SAIF_INSTANCE] ne ""} {
      lappend saif_args -instance_name $SAIF_INSTANCE
    }
    puts "INFO: read_saif [join $saif_args { }]"
    if {[catch {eval [linsert $saif_args 0 read_saif]} saif_msg]} {
      synth_fatal "read_saif falhou: $saif_msg"
    }
  }
}

proc apply_precompile_features {} {
  global CLOCK_NAME
  if {[feature_on ENABLE_FIX_MULTIPLE_PORT_NETS]} {
    puts "INFO: set_fix_multiple_port_nets -all -buffer_constants"
    set_fix_multiple_port_nets -all -buffer_constants
  }
  if {[feature_on ENABLE_FIX_HOLD]} {
    puts "INFO: set_fix_hold para clock $CLOCK_NAME"
    set_fix_hold [get_clocks $CLOCK_NAME]
  }
}

proc run_optional_second_pass {mode retime_second} {
  if {[feature_on ENABLE_AUTO_PATH_GROUPS]} {
    puts "INFO: criando auto path groups no design mapeado"
    if {[catch {create_auto_path_groups -mode mapped} apg_msg]} {
      synth_fatal "create_auto_path_groups falhou: $apg_msg"
    }
    compile_current_design $mode 1 $retime_second
    if {[catch {remove_auto_path_groups} remove_apg_msg]} {
      puts "AVISO: remove_auto_path_groups falhou: $remove_apg_msg"
    }
    return
  }

  if {[feature_on ENABLE_INCREMENTAL_COMPILE]} {
    puts "INFO: segundo passe incremental habilitado"
    compile_current_design $mode 1 $retime_second
  }
}

proc run_optional_area_recovery {} {
  if {![feature_on ENABLE_OPTIMIZE_NETLIST_AREA]} { return }
  puts "INFO: recuperação de área com optimize_netlist -area"
  if {[catch {optimize_netlist -area} area_msg]} {
    synth_fatal "optimize_netlist -area falhou: $area_msg"
  }
}

proc apply_output_naming {} {
  if {[feature_on ENABLE_CHANGE_NAMES]} {
    puts "INFO: aplicando nomes compatíveis com Verilog"
    if {[catch {change_names -rules verilog -hierarchy} names_msg]} {
      synth_fatal "change_names falhou: $names_msg"
    }
  }
}

proc write_synthesis_outputs {result_dir} {
  global TOP
  if {[feature_on ENABLE_WRITE_NETLIST]} {
    write -format verilog -hierarchy -output [file join $result_dir ${TOP}_netlist.v]
  }
  if {[feature_on ENABLE_WRITE_MAPPED_DDC]} {
    write -format ddc -hierarchy -output [file join $result_dir ${TOP}_mapped.ddc]
  }
  if {[feature_on ENABLE_WRITE_SDC]} {
    write_sdc [file join $result_dir ${TOP}.sdc]
  }
  if {[feature_on ENABLE_WRITE_SDF]} {
    if {[catch {write_sdf [file join $result_dir ${TOP}.sdf]} sdf_msg]} {
      puts "AVISO: write_sdf falhou: $sdf_msg"
    }
  }
}

proc start_svf {svf_path} {
  if {![feature_on ENABLE_WRITE_SVF]} { return "" }
  file mkdir [file dirname $svf_path]
  if {[catch {set_svf $svf_path} svf_msg]} {
    synth_fatal "set_svf falhou: $svf_msg"
  }
  return $svf_path
}

proc stop_svf {} {
  if {[feature_on ENABLE_WRITE_SVF]} {
    catch {set_svf -off}
  }
}

proc load_rtl_design {} {
  global TOP RTL_FILES
  if {[catch {analyze -format sverilog $RTL_FILES} analyze_msg]} {
    synth_fatal "falha no analyze: $analyze_msg"
  }
  if {[catch {elaborate $TOP} elaborate_msg]} {
    synth_fatal "falha no elaborate de $TOP: $elaborate_msg"
  }
  current_design $TOP
  if {[catch {set link_ok [link]} link_msg] || !$link_ok} {
    synth_fatal "falha no link do RTL: $link_msg"
  }
}

proc load_ddc_design {ddc_path} {
  global TOP
  if {![file exists $ddc_path]} {
    synth_fatal "DDC base não encontrado: $ddc_path"
  }
  if {[catch {read_ddc $ddc_path} read_msg]} {
    synth_fatal "read_ddc falhou: $read_msg"
  }
  current_design $TOP
  if {[catch {set link_ok [link]} link_msg] || !$link_ok} {
    synth_fatal "falha no link após read_ddc: $link_msg"
  }
}

proc prepare_sweep_base {base_dir} {
  global TOP
  file delete -force $base_dir
  file mkdir $base_dir
  catch {remove_design -all}

  synth_banner "Preparando DDC base reutilizável para o sweep"
  set base_svf ""
  if {[feature_on ENABLE_WRITE_SVF]} {
    set base_svf [start_svf [file join $base_dir ${TOP}_rtl_to_unmapped.svf]]
  }

  load_rtl_design
  check_design_gate [file join $base_dir check_design_base.rpt] "sweep-base"

  set base_ddc [file join $base_dir ${TOP}_unmapped.ddc]
  if {[catch {write -format ddc -hierarchy -output $base_ddc} ddc_msg]} {
    stop_svf
    synth_fatal "falha ao salvar DDC base do sweep: $ddc_msg"
  }
  stop_svf

  puts "INFO: DDC base do sweep: $base_ddc"
  if {$base_svf ne ""} { puts "INFO: SVF RTL->unmapped: $base_svf" }
  return $base_ddc
}

proc run_synthesis_internal {period mode report_dir result_dir input_source input_path} {
  global TOP CONSTRAINTS_FILE

  validate_run_parameters $period $mode
  file mkdir $report_dir
  file mkdir $result_dir
  synth_banner "Síntese: TOP=$TOP | período=${period}ns | modo=$mode | entrada=$input_source"

  catch {remove_design -all}

  if {$input_source eq "rtl"} {
    set svf_path [start_svf [file join $result_dir ${TOP}.svf]]
    load_rtl_design
  } elseif {$input_source eq "unmapped_ddc"} {
    set svf_path [start_svf [file join $result_dir ${TOP}_unmapped_to_mapped.svf]]
    load_ddc_design $input_path
  } else {
    synth_fatal "input_source inválido: $input_source"
  }

  check_design_gate [file join $report_dir check_design.rpt] "pre-compile"

  # Mantém um checkpoint por run quando solicitado, mesmo no sweep com DDC reuse.
  if {[feature_on ENABLE_WRITE_UNMAPPED_DDC]} {
    write -format ddc -hierarchy -output [file join $result_dir ${TOP}_unmapped.ddc]
  }

  apply_operating_conditions

  set ::CLOCK_PERIOD $period
  uplevel #0 [list source $CONSTRAINTS_FILE]
  apply_power_activity

  if {[feature_on ENABLE_CHECK_TIMING_PRE]} {
    run_optional_report ENABLE_CHECK_TIMING_PRE [file join $report_dir check_timing_pre.rpt] {check_timing}
  }

  apply_precompile_features

  # Retiming ocorre exatamente UMA vez. Se existir segundo passe, ele é
  # reservado para esse passe; caso contrário ocorre no compile inicial.
  set second_pass [needs_second_pass]
  set retime_initial [expr {[feature_on ENABLE_RETIMING] && !$second_pass}]
  set retime_second  [expr {[feature_on ENABLE_RETIMING] && $second_pass}]
  set retiming_pass "disabled"
  if {$retime_initial} { set retiming_pass "initial" }
  if {$retime_second}  { set retiming_pass "second" }

  if {[feature_on ENABLE_RETIMING]} {
    puts "INFO: retiming habilitado em exatamente um passe: $retiming_pass"
  }

  compile_current_design $mode 0 $retime_initial
  run_optional_second_pass $mode $retime_second
  run_optional_area_recovery

  if {[feature_on ENABLE_CHECK_DESIGN_POST]} {
    check_design_gate [file join $report_dir check_design_post.rpt] "post-compile"
  }

  report_post_synthesis $report_dir
  apply_output_naming
  write_synthesis_outputs $result_dir
  stop_svf

  set run_dir [file dirname $report_dir]
  write_run_metadata $run_dir $period $mode $input_source $input_path $svf_path $retiming_pass
  synth_banner "Síntese concluída: [file normalize $run_dir]"
}

proc run_synthesis {period mode report_dir result_dir} {
  run_synthesis_internal $period $mode $report_dir $result_dir "rtl" "RTL_FILES"
}

proc run_synthesis_from_ddc {period mode report_dir result_dir base_ddc} {
  run_synthesis_internal $period $mode $report_dir $result_dir "unmapped_ddc" $base_ddc
}
