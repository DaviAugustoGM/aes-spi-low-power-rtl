# Origem e limites do reaproveitamento

Fonte: arquivo local `D:\Dowloads\VendingMachine-master.zip`, fornecido pelo usuário. O arquivo original permanece intacto.

| Origem | Destino / decisão |
|---|---|
| `synth/flow.tcl`, `config.tcl` | Fluxo preservado, nome/top adaptados para AES |
| `synth/lib/flow_utils.tcl` | Utilitários genéricos preservados |
| `synth/features.tcl`, `presets.tcl` | Opções e presets preservados |
| `synth/sweep.tcl`, `list_presets.tcl` | Exploração de síntese preservada |
| `synth/constraints.tcl`, `tech/saed32.tcl` | Exemplo de clock único e tecnologia preservados; revisar na integração |
| `synth/scripts/collect_results.py` | Coletor de relatórios preservado |
| `synth/rtl_files.tcl` | Substituído por leitura do manifesto comum `rtl/files.f` |
| `Makefile`, `sim/run_vcs.sh` | Fluxo reescrito com entrada Python portátil, Icarus/VCS e lint |
| `fm/formality.tcl` | Adaptado mantendo ordem auto setup → SVF → RTL; par netlist/SVF consistente e saída de erro na falha |
| RTL/testbench de vending | Não reutilizados: moedas, crédito e produtos não fazem parte de AES |
| Logs, netlists, ondas, relatórios e work antigos | Não copiados; não são evidências deste projeto |

O enunciado fornecido é referência de requisitos e cronograma. Não fornece a especificação funcional detalhada, nem autoriza marcar as semanas concluídas. Não se supõe que a figura ausente tenha sido analisada.

