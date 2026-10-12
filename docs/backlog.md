# Backlog inicial

Todas as semanas permanecem abertas até cumprir os critérios do enunciado.

| Semana | Trabalho / critério a verificar |
|---|---|
| 01 | Estrutura, fluxo mínimo, estudo FIPS-197/SPI, relatório e execução em clone limpo |
| 02 | Especificação detalhada, interfaces, registradores, clocks/reset/CDC, modelos e defesa |
| 03 | SubBytes, ShiftRows, MixColumns, AddRoundKey e vetores intermediários |
| 04 | Expansão de chave, controle e vetores AES completos |
| 05 | SPI, banco de registradores, travessia, reset e modelo PLL; testes dirigidos |
| 06 | Subsistema de dados, memória, integração, teste fim a fim, lint/CDC e RTL v1.0 |
| 07 | SDC final, síntese com PDK, área/timing/potência baseline |
| 08 | Formality baseline com bibliotecas e SVF consistentes |
| 09 | Fechamento de equivalência, exercício de diagnóstico e RTL v1.1 |
| 10 | Domínios, estados, isolamento, retenção e defesa de energia |
| 11 | UPF, validação estática e simulação power-aware |
| 12 | Controlador de energia e sequências de power gating |
| 13 | ICG, redução de atividade, regressão e RTL v2.0 |
| 14 | Síntese low power, comparação e equivalência |
| 15 | Documentação, defeitos, apresentação, artigo e release reproduzível |

## Próximas tarefas

- [x] Manter estrutura simples, listas de fontes e fluxo mínimo executável.
- [x] Criar exemplo mínimo e teste de reset.
- [x] Validar lint, compilação e simulação no WSL com ferramentas abertas.
- [ ] Validar o fluxo Synopsys no ambiente do curso.
- [ ] Completar o estudo AES/SPI da semana 1.
- [ ] Obter especificação funcional e interfaces do RTL de referência.
- [ ] Confirmar biblioteca, ferramentas e estratégia de modelos com instrutor/verificador.
- [ ] Implementar o AES após confirmar escopo e ordem dos bytes.

Marcos futuros: `w06-rtl-v1.0`, `w09-rtl-v1.1`, `w13-rtl-v2.0`. Não criar tags de aceite antecipadamente.
