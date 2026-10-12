# Semana 01 — preparação da estrutura

## O que foi feito

- Extração seletiva do fluxo genérico de síntese de Vending Machine.
- Organização de RTL, modelos, simulação, CDC, energia, documentação e relatórios.
- Adaptação do top, manifestos, scripts de simulação e Formality.
- Exemplo mínimo de reset, teste dirigido, backlog e registro das interfaces pendentes.

## Resultados e evidências

Validação local em Ubuntu/WSL, com Icarus Verilog 12.0 e Verilator 5.032:

```text
$ make smoke
verilator --lint-only --top-module aes_spi_top -Wall ...
iverilog -g2012 -Wall -s tb_smoke ...
vvp simv
PASS: reset assertion, synchronized release and ready
```

Lint e compilação sem avisos. O comando também passou em um clone local limpo, sem reaproveitar arquivos de build. A simulação verifica asserção de reset fora da borda, liberação sincronizada, ready e reaplicação de reset. As listas de fontes, sintaxe dos scripts Python, listagem de presets Tcl e interface do coletor de relatórios também foram verificadas.

## Problemas e limites

O teste gera uma transição explícita de reset para evitar depender da inicialização do simulador. Nenhum vetor AES foi testado, pois o núcleo ainda não existe. VCS, Design Compiler, Formality, CDC e ferramentas power-aware não foram executados. Não existem métricas de área, timing ou potência deste projeto.

Faltam a especificação funcional detalhada, biblioteca/PDK e interfaces compatíveis com o verificador. O relatório de estudo sobre AES/SPI da semana 1 ainda está pendente; esta página registra somente a preparação do ambiente.

## Próximos passos

Completar o estudo da semana 1, obter a especificação, definir a arquitetura e revisar as interfaces com o instrutor/verificador antes de implementar os blocos.
