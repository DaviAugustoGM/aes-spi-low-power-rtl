# ============================================================
# OVERRIDES MANUAIS DE FEATURES
#
# 1) Um preset é aplicado antes deste arquivo.
# 2) Qualquer "set" feito aqui SOBRESCREVE o preset.
# 3) Use somente true ou false para as flags ENABLE_*.
#
# O arquivo pode ficar sem nenhum override.
# ============================================================

# Limpeza / compatibilidade da netlist
# set ENABLE_FIX_MULTIPLE_PORT_NETS true
# set ENABLE_CHANGE_NAMES           true

# Sanidade / relatórios
# set ENABLE_CHECK_DESIGN_POST          true
# set ENABLE_REPORT_AREA                true
# set ENABLE_REPORT_TIMING              true
# set ENABLE_REPORT_POWER               true
# set ENABLE_REPORT_CONSTRAINTS         true
# set ENABLE_REPORT_QOR                 true
# set ENABLE_CHECK_TIMING_PRE           true
# set ENABLE_REPORT_CHECK_TIMING_POST   true
# set ENABLE_REPORT_DESIGN              true
# set ENABLE_REPORT_CLOCK               true
# set ENABLE_REPORT_RESOURCES           true
# set ENABLE_REPORT_REFERENCES          true
# set ENABLE_REPORT_HIERARCHY           true
# set ENABLE_REPORT_FSM                 true
# set ENABLE_REPORT_PATH_GROUPS         true
# set ENABLE_REPORT_COMPILE_OPTIONS     true
# set ENABLE_REPORT_TIMING_REQUIREMENTS true
# set ENABLE_REPORT_SAIF                false

# Constraints / timing
# set ENABLE_CLOCK_TRANSITION false
# set ENABLE_USER_DRC         false
# set ENABLE_MIN_MAX_LIBS     false
# set ENABLE_FIX_HOLD         false
# set ENABLE_CRITICAL_RANGE   false
# set ENABLE_AUTO_PATH_GROUPS false

# Power
# set ENABLE_CLOCK_GATING               false
# set ENABLE_READ_SAIF                  false
# set ENABLE_DYNAMIC_POWER_OPTIMIZATION false

# Otimização
# set ENABLE_INCREMENTAL_COMPILE   false
# set ENABLE_RETIMING              false
# set ENABLE_OPTIMIZE_NETLIST_AREA false

# Arquivos de saída / reuso
# set ENABLE_WRITE_UNMAPPED_DDC true
# set ENABLE_WRITE_MAPPED_DDC   true
# set ENABLE_WRITE_NETLIST      true
# set ENABLE_WRITE_SDC          true
# set ENABLE_WRITE_SDF          true
# set ENABLE_WRITE_SVF          true
# set ENABLE_SWEEP_DDC_REUSE    true

# Runtime
# set ENABLE_MULTICORE false
