# ============================================================
# ConfiguraÃ§Ã£o do PROJETO para sÃ­ntese lÃ³gica
#
# Este Ã© um dos poucos arquivos que deve mudar ao reutilizar o
# fluxo em outro projeto. O fluxo genÃ©rico estÃ¡ em flow.tcl.
# ============================================================

set SYNTH_DIR [file dirname [file normalize [info script]]]
set PROJECT_ROOT [file normalize [file join $SYNTH_DIR ..]]

# IdentificaÃ§Ã£o do projeto / top-level
set PROJECT_NAME "aes_spi_low_power"
set TOP "aes_spi_top"

# Arquivos de configuraÃ§Ã£o especializados
set PRESETS_FILE [file join $SYNTH_DIR presets.tcl]
set FEATURES_FILE [file join $SYNTH_DIR features.tcl]
set RTL_FILELIST [file join $SYNTH_DIR rtl_files.tcl]
set CONSTRAINTS_FILE [file join $SYNTH_DIR constraints.tcl]
set TECH_SETUP_FILE [file join $SYNTH_DIR tech saed32.tcl]

# Preset padrÃ£o. Pode ser sobrescrito por SYNTH_PRESET / PRESET=...
set SYNTH_PRESET "default"

# DiretÃ³rios
set WORK_DIR   [file join $SYNTH_DIR work]
set REPORT_DIR [file join $SYNTH_DIR reports]
set RESULT_DIR [file join $SYNTH_DIR results]
set RUNS_DIR   [file join $SYNTH_DIR runs]
set SWEEP_CACHE_DIR [file join $WORK_DIR sweep_cache]

# Clock e ambiente de I/O
set CLOCK_PORT "clk"
set CLOCK_NAME "clk"
set CLOCK_PERIOD 20.0
set CLOCK_UNCERTAINTY 0.5
set CLOCK_TRANSITION 0.10

set INPUT_DELAY 3.0
set OUTPUT_DELAY 3.0
set OUTPUT_LOAD 0.05

# Design-rule/otimizaÃ§Ã£o opcionais
set MAX_TRANSITION 0.50
set MAX_FANOUT 20
set CRITICAL_RANGE 0.50

# CÃ©lulas tentadas, em ordem, para modelar o driver das entradas.
set DRIVE_CELL_CANDIDATES [list INVX1_RVT INVX1]

# Operating conditions explÃ­citas (nomes definidos nas .db).
# Se ENABLE_MIN_MAX_LIBS=true, ambas sÃ£o obrigatÃ³rias.
# Em single-corner, MAX_OPERATING_CONDITION pode ser preenchida para
# substituir a operating condition default da target library.
set MAX_OPERATING_CONDITION ""
set MIN_OPERATING_CONDITION ""

# Atividade de chaveamento para power.
# Caminho vazio = nenhuma anotaÃ§Ã£o SAIF.
set SAIF_FILE ""
set SAIF_INSTANCE ""

# OpÃ§Ãµes de compilaÃ§Ã£o:
#   no_autoungroup -> compile_ultra -no_autoungroup
#   autoungroup    -> compile_ultra
set COMPILE_MODE "no_autoungroup"

# Quantidade de caminhos detalhados nos relatÃ³rios de timing.
set TIMING_MAX_PATHS 10

# Runtime. SÃ³ Ã© aplicado quando ENABLE_MULTICORE=true.
set MAX_CORES 4

# Sweep padrÃ£o. Pode ser alterado aqui sem tocar no sweep.tcl.
set SWEEP_PERIODS [list 20 18 16 14 12 10 8 6 4 2]
set SWEEP_MODES [list no_autoungroup autoungroup]

# -----------------------------------------------------------------
# Overrides opcionais por variÃ¡vel de ambiente / Makefile.
# -----------------------------------------------------------------
if {[info exists ::env(SYNTH_PRESET)] && $::env(SYNTH_PRESET) ne ""} {
  set SYNTH_PRESET $::env(SYNTH_PRESET)
}

if {[info exists ::env(SYNTH_FEATURES_FILE)] && $::env(SYNTH_FEATURES_FILE) ne ""} {
  set _features_override $::env(SYNTH_FEATURES_FILE)
  if {[file pathtype $_features_override] eq "absolute"} {
    set FEATURES_FILE [file normalize $_features_override]
  } else {
    set FEATURES_FILE [file normalize [file join $PROJECT_ROOT $_features_override]]
  }
  unset _features_override
}

if {[info exists ::env(SYNTH_PERIOD)] && $::env(SYNTH_PERIOD) ne ""} {
  set CLOCK_PERIOD $::env(SYNTH_PERIOD)
}

if {[info exists ::env(SYNTH_MODE)] && $::env(SYNTH_MODE) ne ""} {
  set COMPILE_MODE $::env(SYNTH_MODE)
}

if {[info exists ::env(SYNTH_SWEEP_PERIODS)] && $::env(SYNTH_SWEEP_PERIODS) ne ""} {
  set SWEEP_PERIODS [regexp -all -inline {\S+} [string map {"," " "} $::env(SYNTH_SWEEP_PERIODS)]]
}

if {[info exists ::env(SYNTH_SWEEP_MODES)] && $::env(SYNTH_SWEEP_MODES) ne ""} {
  set SWEEP_MODES [regexp -all -inline {\S+} [string map {"," " "} $::env(SYNTH_SWEEP_MODES)]]
}

if {[info exists ::env(SYNTH_MAX_OPCOND)] && $::env(SYNTH_MAX_OPCOND) ne ""} {
  set MAX_OPERATING_CONDITION $::env(SYNTH_MAX_OPCOND)
}

if {[info exists ::env(SYNTH_MIN_OPCOND)] && $::env(SYNTH_MIN_OPCOND) ne ""} {
  set MIN_OPERATING_CONDITION $::env(SYNTH_MIN_OPCOND)
}

if {[info exists ::env(SYNTH_SAIF_FILE)] && $::env(SYNTH_SAIF_FILE) ne ""} {
  set _saif_override $::env(SYNTH_SAIF_FILE)
  if {[file pathtype $_saif_override] eq "absolute"} {
    set SAIF_FILE [file normalize $_saif_override]
  } else {
    set SAIF_FILE [file normalize [file join $PROJECT_ROOT $_saif_override]]
  }
  unset _saif_override
}

if {[info exists ::env(SYNTH_SAIF_INSTANCE)] && $::env(SYNTH_SAIF_INSTANCE) ne ""} {
  set SAIF_INSTANCE $::env(SYNTH_SAIF_INSTANCE)
}
