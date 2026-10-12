# ============================================================
# Constraints do PROJETO
#
# Usa os parâmetros de config.tcl e as features resultantes do preset + overrides.
# O sweep apenas troca CLOCK_PERIOD e reaplica este mesmo arquivo.
# ============================================================

# Garante que não sobre clock de uma iteração anterior do sweep.
catch {remove_clock [all_clocks]}

set clock_port_obj [get_ports $CLOCK_PORT]
create_clock -name $CLOCK_NAME -period $CLOCK_PERIOD $clock_port_obj
set_clock_uncertainty $CLOCK_UNCERTAINTY [get_clocks $CLOCK_NAME]

if {[feature_on ENABLE_CLOCK_TRANSITION]} {
  set_clock_transition $CLOCK_TRANSITION [get_clocks $CLOCK_NAME]
  puts "INFO: clock transition aplicado: $CLOCK_TRANSITION"
}

# Entradas, exceto o clock.
set input_ports [remove_from_collection [all_inputs] $clock_port_obj]

if {[sizeof_collection $input_ports] > 0} {
  set_input_delay $INPUT_DELAY -clock [get_clocks $CLOCK_NAME] $input_ports
}

if {[sizeof_collection [all_outputs]] > 0} {
  set_output_delay $OUTPUT_DELAY -clock [get_clocks $CLOCK_NAME] [all_outputs]
  set_load $OUTPUT_LOAD [all_outputs]
}

# Modelagem de driver com fallback entre nomes comuns da biblioteca.
if {[sizeof_collection $input_ports] > 0} {
  set driver_applied 0
  foreach drive_cell $DRIVE_CELL_CANDIDATES {
    if {!$driver_applied} {
      if {![catch {set_driving_cell -lib_cell $drive_cell $input_ports} drive_msg]} {
        puts "INFO: set_driving_cell usando $drive_cell"
        set driver_applied 1
      }
    }
  }

  if {!$driver_applied} {
    puts "AVISO: nenhuma célula de DRIVE_CELL_CANDIDATES pôde ser aplicada."
    puts "AVISO: candidatos: $DRIVE_CELL_CANDIDATES"
  }
}

if {[feature_on ENABLE_USER_DRC]} {
  set_max_transition $MAX_TRANSITION [current_design]
  set_max_fanout $MAX_FANOUT [current_design]
  puts "INFO: DRC do usuário: max_transition=$MAX_TRANSITION max_fanout=$MAX_FANOUT"
}

if {[feature_on ENABLE_CRITICAL_RANGE]} {
  set_critical_range $CRITICAL_RANGE [current_design]
  puts "INFO: critical range aplicado: $CRITICAL_RANGE"
}

puts "INFO: constraints aplicadas: period=${CLOCK_PERIOD}ns uncertainty=${CLOCK_UNCERTAINTY}ns"
