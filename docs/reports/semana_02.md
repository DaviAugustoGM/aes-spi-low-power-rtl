# Relatório — Semana 02: SubBytes e ShiftRows

## Implementação

- `minisoc_aes_sbox`: consulta combinacional dos 256 valores da S-Box AES.
- `minisoc_aes_sub_bytes`: 16 instâncias paralelas de S-Box.
- `minisoc_aes_shift_rows`: permutação combinacional das linhas do estado.
- Convenção: byte 0 em `[127:120]`.

## Verificação

Comandos: `make minisoc-test` (VCS), `make minisoc-lint` (SpyGlass Explorer/Classic).

| Verificação | Resultado |
|---|---|
| S-Box — 256 entradas | PASS — VCS X-2025.06-SP2 |
| SubBytes — rodadas 1 e 10 FIPS-197 | PASS — VCS X-2025.06-SP2 |
| ShiftRows — rodadas 1 e 10 FIPS-197 | PASS — VCS X-2025.06-SP2 |
| ShiftRows — posicionamento dos bytes | PASS — VCS X-2025.06-SP2 |
| Lint SpyGlass (3 top-levels) | PASS — 0 fatals, 0 erros, 0 avisos por top; 2 infos por top |

Execução verificada em 06/11/2026 nesta entrega, após carregar o ambiente do laboratório com `source /Tools/synopsys-scripts/snps.sh`. VCS e SpyGlass X-2025.06-SP2 concluíram com código 0. A simulação terminou com `ALL TESTS PASSED` em 262 ns. Os relatórios `moresimple.rpt` dos três tops foram revisados: apenas `DetectTopDesignUnits` e `ElabSummary` (Info), sem waivers.

Evidências locais reproduzíveis (ignoradas pelo Git): `build/minisoc/vcs_sim.log`, `build/minisoc/spyglass_*.log` e `build/spyglass_*/<projeto>/consolidated_reports/<top>_lint_lint_rtl/moresimple.rpt`. Nenhum log, binário ou relatório gerado é incluído neste commit.

A opção incompatível `-log` do SpyGlass foi substituída por redirecionamento do shell, preservando o código de saída. Os projetos selecionam a metodologia instalada em `GuideWare/2025.06`, com fallback para `GuideWare2.0`; `SPYGLASS_METHODOLOGY` permite informar outro caminho. Sem carregar o ambiente, a primeira tentativa VCS falhou por licença ausente; a execução final acima foi bem-sucedida.

Os vetores de rodadas usam o exemplo AES-128 do FIPS-197 (2001), apêndice C.1. Verificação limitada aos blocos combinacionais: não representa validação do núcleo AES completo, SPI ou baixo consumo. Os alvos e arquivos anteriores da semana 01 foram preservados.

## Dúvidas após leitura das seções 1–3 e 8 do Block Guide

1. O datapath deve completar uma rodada inteira por ciclo ou realizar uma transformação por ciclo?
2. A expansão de chave deve gerar as round keys antecipadamente ou a cada rodada?
3. Na decriptação, o datapath será compartilhado com a criptografia ou haverá caminho separado?
4. Como sincronizar a transferência de propriedade da memória para o AES quando o PLL mudar de estado?
5. Qual é a latência esperada para o acesso às quatro palavras que compõem um bloco AES?

> Estas perguntas são propostas de discussão, não requisitos definidos pelo documento.
