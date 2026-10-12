set FLOW_DIR [file dirname [file normalize [info script]]]
source [file join $FLOW_DIR presets.tcl]

puts "Presets disponíveis:"
foreach preset [available_synth_presets] {
  puts [format "  %-20s %s" $preset [describe_synth_preset $preset]]
}
