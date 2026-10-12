# AES com SPI e baixo consumo — base do projeto RTL

Estrutura inicial extraída e adaptada de `VendingMachine-master.zip` para o trabalho de 15 semanas. O fluxo genérico de Design Compiler, presets, sweep e coleta de resultados foi reaproveitado. A simulação e o Formality foram adaptados para o novo projeto.

**Estado atual:** infraestrutura e exemplo mínimo de reset. Ainda não implementa criptografia AES, interface SPI, memória, PLL ou modos de energia. A interface de `aes_spi_top` é provisória; não representa a interface final do instrutor.

## Organização

| Pasta | Uso |
|---|---|
| `rtl/aes/` | Transformações, expansão de chave e controle AES |
| `rtl/spi/`, `rtl/registers/`, `rtl/cdc/` | SPI em SCLK, registradores no clock do sistema e travessias |
| `rtl/reset/` | Reset por domínio de clock |
| `rtl/data/`, `rtl/power/` | Subsistema de dados e controlador de energia |
| `models/` | Modelos comportamentais de PLL e memória, fora da síntese |
| `sim/` | Teste mínimo, testes unitários e integração |
| `synth/` | Design Compiler, tecnologia, restrições, presets e relatórios |
| `fm/` | Formality RTL × netlist com SVF da mesma síntese |
| `constraints/`, `upf/` | Reservadas para restrições do sistema final e intenção de potência |
| `docs/` | Backlog, arquitetura, decisões e relatórios semanais |

## Fluxo mínimo

Em Linux/WSL, disponibilize Python 3, GNU Make, Verilator e Icarus Verilog (`iverilog` e `vvp`) no PATH. Então:

```sh
make smoke
```

Esse comando faz lint do RTL, compila e simula o teste de reset. Deve terminar com `PASS: reset assertion, synchronized release and ready`. Saídas temporárias ficam em `build/sim/`, incluindo `waves.vcd`. O teste cobre reset inicial, liberação após dois ciclos, sinal ready e novo reset durante operação.

Com VCS configurado: `make smoke SIMULATOR=vcs` (lint continua usando Verilator). Para simulação sem lint: `make sim SIMULATOR=vcs`.

Sem Make, inclusive no Windows com as ferramentas no PATH:

```sh
python scripts/run.py smoke
```

`python scripts/run.py check` valida somente as listas de fontes; não substitui compilação ou simulação. Os scripts funcionam a partir de qualquer diretório. Adicione fontes sintetizáveis em `rtl/files.f` e fontes de simulação em `sim/files.f`.

## Síntese e equivalência

O fluxo reaproveitado usa Design Compiler e, inicialmente, SAED32. Confirme com o instrutor a biblioteca e os presets antes de usar. Não versione bibliotecas proprietárias.

```sh
export SAED32_TARGET_LIB=/caminho/da/biblioteca.db
make synth
make formal
make collect_synth
```

`synth/config.tcl` seleciona `aes_spi_top` e permite overrides `SYNTH_PERIOD`, `SYNTH_PRESET`, `SYNTH_MODE`, `SYNTH_SAIF_FILE` e outros herdados. A restrição atual é apenas para o exemplo de clock único, com período didático de 20 ns; não é um SDC final do sistema AES/SPI.

O Formality lê `synth/results/aes_spi_top.svf` e `aes_spi_top_netlist.v`, gerados juntos por `make synth`. Reexecute síntese após alterar RTL ou configuração. O fluxo encerra com erro se a equivalência não passar. Ainda requer validação no ambiente Synopsys do instrutor.

Os resultados antigos da máquina de vendas não foram copiados. Relatórios de síntese/formal podem ser versionados; temporários ficam ignorados. Relatórios selecionados do sweep devem ser copiados de `synth/runs/` para uma pasta de entrega versionada junto com a configuração que os gerou.

## Desenvolvimento e entregas

Consulte [backlog](docs/backlog.md), [arquitetura inicial](docs/arquitetura.md) e [origem da adaptação](docs/reaproveitamento.md). Use relatórios `docs/reports/semana_XX.md` e tags semanais após cumprir o critério de aceite. Nenhuma entrega funcional de AES está concluída nesta base.
