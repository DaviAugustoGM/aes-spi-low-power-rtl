# Semana 01 — estrutura e ambiente

## O que foi feito

A base foi simplificada seguindo a organização do exemplo `aes-spi-crypto-accelerator-main.zip`: RTL, modelos, testbenches, scripts, síntese, formal, UPF e documentação.

O fluxo mínimo fica no Makefile. Foram mantidos o exemplo de reset, teste autoverificável, backlog e listas de fontes compartilhadas. Presets, sweep, coletor de métricas e scripts avançados de síntese/formal foram retirados do esboço; permanecem no histórico Git para consulta futura.

## Resultados

Validação em Ubuntu/WSL com Verilator 5.032 e Icarus Verilog 12.0:

```text
$ make test
Lint: sem erros ou avisos
Compilação: sem erros ou avisos
PASS: reset assertion, synchronized release and ready
PASS: fluxo mínimo concluído
```

Logs reais em `docs/reports/logs/open_lint.log`, `open_compile.log` e `open_sim.log`. O teste cobre reset inicial, liberação sincronizada e reset durante operação. Esses resultados são somente do exemplo mínimo.

## Pendências

- Completar o estudo AES/SPI da semana 1.
- Executar `make test TOOLCHAIN=synopsys` no ambiente do curso; essa opção não foi validada localmente.
- Obter a especificação funcional e confirmar as interfaces com o instrutor/verificador.
- Desenvolver AES, SPI, PLL, memória, CDC e energia nas etapas previstas.

Não houve execução de síntese, equivalência formal ou simulação power-aware. A semana 1 permanece pendente de estudo e aceite; nenhuma entrega funcional de AES está concluída.
