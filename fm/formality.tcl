# Adapted from VendingMachine: load auto setup and the paired SVF before RTL.
set PROJECT_ROOT [file normalize [file join [file dirname [info script]] ..]]
source [file join $PROJECT_ROOT synth config.tcl]
source $RTL_FILELIST
if {![info exists ::env(SAED32_TARGET_LIB)] || $::env(SAED32_TARGET_LIB) eq ""} {
    puts stderr "Set SAED32_TARGET_LIB to the same .db used by synthesis."
    exit 1
}
set DB $::env(SAED32_TARGET_LIB)
set SVF [file join $RESULT_DIR ${TOP}.svf]
set NETLIST [file join $RESULT_DIR ${TOP}_netlist.v]
foreach path [list $DB $SVF $NETLIST] {
    if {![file isfile $path]} { puts stderr "Missing input: $path"; exit 1 }
}
set FM_REPORTS [file join $PROJECT_ROOT fm reports]
file mkdir $FM_REPORTS
read_db $DB
set synopsys_auto_setup true
set_svf $SVF
read_sverilog -r $RTL_FILES
set_top r:/WORK/$TOP
read_verilog -i $NETLIST
set_top i:/WORK/$TOP
match
set passed [verify]
redirect [file join $FM_REPORTS status.rpt] { report_status }
redirect [file join $FM_REPORTS unmatched.rpt] { report_unmatched_points }
redirect [file join $FM_REPORTS failing.rpt] { report_failing_points }
if {!$passed} { exit 1 }
exit 0
