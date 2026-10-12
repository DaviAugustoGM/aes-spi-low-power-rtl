# ============================================================
# Configuração da TECNOLOGIA - SAED32
# ============================================================

set TECH_NAME "SAED32"

if {[info exists ::env(SAED32_TARGET_LIB)] && $::env(SAED32_TARGET_LIB) ne ""} {
  set TARGET_LIBRARY [list $::env(SAED32_TARGET_LIB)]
} else {
  set TARGET_LIBRARY [list saed32rvt_tt1p05v25c.db]
}

set SYNTHETIC_LIBRARY [list dw_foundation.sldb]
set ADDITIONAL_LINK_LIBRARIES [list]

set TECH_SEARCH_PATHS [list \
  $PROJECT_ROOT \
  [file join $PROJECT_ROOT rtl] \
  $SYNTH_DIR \
  [file join $PROJECT_ROOT libs] \
  [file join $SYNTH_DIR libs] \
]

set_app_var search_path [concat [get_app_var search_path] $TECH_SEARCH_PATHS]
set_app_var target_library $TARGET_LIBRARY
set_app_var synthetic_library $SYNTHETIC_LIBRARY
set_app_var link_library [concat "*" $TARGET_LIBRARY $ADDITIONAL_LINK_LIBRARIES $SYNTHETIC_LIBRARY]

file mkdir $WORK_DIR
define_design_lib WORK -path $WORK_DIR

set hdlin_enable_rtl_for_iq 1
set hdlin_check_no_latch true

# -----------------------------------------------------------------
# Relação min/max opcional.
# IMPORTANTE: a min library NÃO é adicionada à target/link library.
# Ela é associada à max library via set_min_library.
# -----------------------------------------------------------------
set HAS_MIN_LIBRARY false
set MIN_LIBRARY ""

if {[feature_on ENABLE_MIN_MAX_LIBS]} {
  if {![info exists ::env(SAED32_MIN_LIB)] || $::env(SAED32_MIN_LIB) eq ""} {
    synth_fatal "ENABLE_MIN_MAX_LIBS=true, mas SAED32_MIN_LIB não foi definido."
  }

  set MIN_LIBRARY $::env(SAED32_MIN_LIB)
  set max_lib [lindex $TARGET_LIBRARY 0]
  if {[catch {set_min_library $max_lib -min_version $MIN_LIBRARY} minlib_msg]} {
    synth_fatal "set_min_library falhou: $minlib_msg"
  }
  set HAS_MIN_LIBRARY true
  puts "INFO: relação min/max habilitada: max=$max_lib min=$MIN_LIBRARY"
} elseif {[info exists ::env(SAED32_MIN_LIB)] && $::env(SAED32_MIN_LIB) ne ""} {
  puts "AVISO: SAED32_MIN_LIB foi definida, mas ENABLE_MIN_MAX_LIBS=false; biblioteca mínima ignorada."
}

puts "INFO: tecnologia carregada: $TECH_NAME"
puts "INFO: target_library: $TARGET_LIBRARY"
