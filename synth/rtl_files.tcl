# Read the same source manifest used by simulation and lint.
set RTL_FILES [list]
set fp [open [file join $PROJECT_ROOT rtl files.f] r]
foreach line [split [read $fp] "\n"] {
    set line [string trim $line]
    if {$line eq "" || [string match "#*" $line]} { continue }
    lappend RTL_FILES [file join $PROJECT_ROOT $line]
}
close $fp
