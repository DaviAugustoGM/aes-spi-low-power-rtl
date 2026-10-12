# ============================================================
# PRESETS DE SÍNTESE LÓGICA
#
# O preset é aplicado PRIMEIRO; features.tcl vem depois e pode
# sobrescrever qualquer ENABLE_* manualmente.
# ============================================================

proc available_synth_presets {} {
  return [list default fast timing aggressive_timing area power]
}

proc describe_synth_preset {name} {
  switch -- $name {
    default { return "Fluxo equilibrado, verificável e conservador para síntese lógica." }
    fast { return "Exploração rápida; reduz reports/arquivos secundários, mantendo gates de sanidade." }
    timing { return "Foco em timing; auto path groups no design mapeado e passe incremental." }
    aggressive_timing { return "Timing de maior esforço; critical range e exatamente um passe com retiming." }
    area { return "Foco em recuperação de área pós-mapeamento com optimize_netlist -area." }
    power { return "Foco em power: clock gating; com SAIF informado também ativa otimização dinâmica." }
    default { return "Preset desconhecido." }
  }
}

proc apply_synth_preset {name} {
  set preset [string tolower [string trim $name]]

  if {[lsearch -exact [available_synth_presets] $preset] < 0} {
    return -code error "preset '$name' inválido. Disponíveis: [join [available_synth_presets] {, }]"
  }

  # Baseline / default
  set ::ENABLE_FIX_MULTIPLE_PORT_NETS true
  set ::ENABLE_CHANGE_NAMES           true

  set ::ENABLE_CHECK_DESIGN_POST          true
  set ::ENABLE_REPORT_AREA                true
  set ::ENABLE_REPORT_TIMING              true
  set ::ENABLE_REPORT_POWER               true
  set ::ENABLE_REPORT_CONSTRAINTS         true
  set ::ENABLE_REPORT_QOR                 true
  set ::ENABLE_CHECK_TIMING_PRE           true
  set ::ENABLE_REPORT_CHECK_TIMING_POST   true
  set ::ENABLE_REPORT_DESIGN              true
  set ::ENABLE_REPORT_CLOCK               true
  set ::ENABLE_REPORT_RESOURCES           true
  set ::ENABLE_REPORT_REFERENCES          true
  set ::ENABLE_REPORT_HIERARCHY           true
  set ::ENABLE_REPORT_FSM                 true
  set ::ENABLE_REPORT_PATH_GROUPS         true
  set ::ENABLE_REPORT_COMPILE_OPTIONS     true
  set ::ENABLE_REPORT_TIMING_REQUIREMENTS true
  set ::ENABLE_REPORT_SAIF                false

  set ::ENABLE_CLOCK_TRANSITION false
  set ::ENABLE_USER_DRC         false
  set ::ENABLE_MIN_MAX_LIBS     false
  set ::ENABLE_FIX_HOLD         false
  set ::ENABLE_CRITICAL_RANGE   false
  set ::ENABLE_AUTO_PATH_GROUPS false

  set ::ENABLE_CLOCK_GATING               false
  set ::ENABLE_READ_SAIF                  false
  set ::ENABLE_DYNAMIC_POWER_OPTIMIZATION false

  set ::ENABLE_INCREMENTAL_COMPILE    false
  set ::ENABLE_RETIMING               false
  set ::ENABLE_OPTIMIZE_NETLIST_AREA  false

  set ::ENABLE_WRITE_UNMAPPED_DDC true
  set ::ENABLE_WRITE_MAPPED_DDC   true
  set ::ENABLE_WRITE_NETLIST      true
  set ::ENABLE_WRITE_SDC          true
  set ::ENABLE_WRITE_SDF          true
  set ::ENABLE_WRITE_SVF          true
  set ::ENABLE_SWEEP_DDC_REUSE    true

  set ::ENABLE_MULTICORE false

  switch -- $preset {
    default {
      # Baseline já configurada.
    }

    fast {
      set ::ENABLE_REPORT_POWER               false
      set ::ENABLE_REPORT_DESIGN              false
      set ::ENABLE_REPORT_CLOCK               false
      set ::ENABLE_REPORT_RESOURCES           false
      set ::ENABLE_REPORT_REFERENCES          false
      set ::ENABLE_REPORT_HIERARCHY           false
      set ::ENABLE_REPORT_FSM                 false
      set ::ENABLE_REPORT_PATH_GROUPS         false
      set ::ENABLE_REPORT_COMPILE_OPTIONS     false
      set ::ENABLE_REPORT_TIMING_REQUIREMENTS false
      set ::ENABLE_REPORT_SAIF                false
      set ::ENABLE_WRITE_UNMAPPED_DDC         false
      set ::ENABLE_WRITE_SDF                  false
      set ::ENABLE_WRITE_SVF                  false
    }

    timing {
      set ::ENABLE_CLOCK_TRANSITION true
      set ::ENABLE_AUTO_PATH_GROUPS true
      # AUTO_PATH_GROUPS já cria o único passe incremental necessário.
      set ::ENABLE_INCREMENTAL_COMPILE false
    }

    aggressive_timing {
      set ::ENABLE_CLOCK_TRANSITION true
      set ::ENABLE_AUTO_PATH_GROUPS true
      set ::ENABLE_CRITICAL_RANGE   true
      set ::ENABLE_RETIMING         true
      set ::ENABLE_WRITE_SVF        true
      set ::ENABLE_INCREMENTAL_COMPILE false
      # flow_utils garante que o retiming ocorre em somente UM compile:
      # no segundo passe quando houver auto path groups/incremental.
    }

    area {
      set ::ENABLE_INCREMENTAL_COMPILE    true
      set ::ENABLE_OPTIMIZE_NETLIST_AREA true
      set ::ENABLE_AUTO_PATH_GROUPS       false
      set ::ENABLE_RETIMING               false
    }

    power {
      set ::ENABLE_REPORT_POWER        true
      set ::ENABLE_REPORT_CLOCK        true
      set ::ENABLE_CLOCK_TRANSITION    true
      set ::ENABLE_CLOCK_GATING        true
      set ::ENABLE_INCREMENTAL_COMPILE true
      set ::ENABLE_AUTO_PATH_GROUPS    false
      set ::ENABLE_RETIMING            false

      # Se o usuário fornecer SAIF, o preset evolui automaticamente de
      # clock-gating exploration para power otimizado com atividade real.
      if {[info exists ::SAIF_FILE] && [string trim $::SAIF_FILE] ne ""} {
        set ::ENABLE_READ_SAIF                  true
        set ::ENABLE_DYNAMIC_POWER_OPTIMIZATION true
        set ::ENABLE_REPORT_SAIF                true
      }
    }
  }

  set ::ACTIVE_SYNTH_PRESET $preset
  set ::ACTIVE_SYNTH_PRESET_DESCRIPTION [describe_synth_preset $preset]
}
