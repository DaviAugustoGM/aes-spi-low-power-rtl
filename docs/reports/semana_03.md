# Semana 03 — transformações combinacionais AES

## O que foi feito

Escopo: semana 03 de `docs/backlog.md` — SubBytes, ShiftRows, MixColumns, AddRoundKey e vetores intermediários. SubBytes e ShiftRows foram preservados da semana 02.

- `rtl/minisoc_aes/minisoc_aes_mix_columns.sv`: quatro colunas paralelas, matriz AES com coeficientes 02/03/01/01 em GF(2^8), redução pelo polinômio 0x11b.
- `rtl/minisoc_aes/minisoc_aes_add_round_key.sv`: XOR de estado e chave de rodada de 128 bits, fornecida externamente.
- Ambos são combinacionais, sem clock/reset ou armazenamento. Convenção preservada: estado em ordem de colunas, byte 0 em `[127:120]`, índice `4*coluna+linha`.
- Testbench autoverificável `tb/tb_minisoc_aes_week3.sv`, dois projetos SpyGlass adicionais e Makefile com regressão das semanas 02 e 03.

## Resultados e evidências

Verificação executada em 06/11/2026 com Synopsys VCS e SpyGlass X-2025.06-SP2, ambiente do laboratório carregado:

```sh
source /Tools/synopsys-scripts/snps.sh
make minisoc-test
make minisoc-lint
```

Para executar apenas o novo testbench: `make minisoc-week3-test`. Caminhos podem ser sobrescritos com `VCS=...`, `SPYGLASS=...` e a variável de ambiente `SPYGLASS_METHODOLOGY`.

| Verificação | Resultado observado |
|---|---|
| Regressão semana 02: S-Box 256/256, rodadas 1/10 e ordem dos bytes | PASS; `ALL TESTS PASSED`, 262 ns |
| AddRoundKey inicial e estados intermediários FIPS-197 C.1, rodadas 1..10 | PASS; SubBytes, ShiftRows, MixColumns (1..9), AddRoundKey |
| Saída após décima rodada, sem MixColumns | PASS: `69c4e0d86a7b0430d8cdb78070b4c55a` |
| MixColumns: 16 posições × 256 valores, demais bytes zerados | PASS: 4.096 casos; modelo independente com produto e redução polinomial |
| AddRoundKey: bits isolados no estado e na chave, cancelamento | PASS: 384 casos |
| MixColumns e AddRoundKey: estados/chaves pseudoaleatórios | PASS: 1.000 combinações, xorshift32 com semente `0x20261106` |
| Testbench semana 03 | `ALL WEEK 3 TESTS PASSED`, 5.492 ns; processo com código 0 |
| SpyGlass S-Box, SubBytes, ShiftRows, MixColumns, AddRoundKey | Cada top: código 0, 0 fatals, 0 erros, 0 avisos de RTL, 2 infos; nenhum waiver |

As duas informações de cada top são `DetectTopDesignUnits` e `ElabSummary`. Os cinco relatórios `moresimple.rpt` foram revisados. Não se inferiu ausência de violações apenas do retorno do processo.

Evidências locais, ignoradas pelo Git: `build/minisoc/vcs_sim.log`, `build/minisoc_week3/vcs_sim.log`, `build/minisoc/spyglass_*.log` e `build/spyglass_*/<projeto>/consolidated_reports/<top>_lint_lint_rtl/moresimple.rpt`. Logs, binários e bases geradas não fazem parte da entrega.

Referência dos vetores fixos: [NIST FIPS-197, edição 2001, apêndice C.1, AES-128](https://csrc.nist.gov/files/pubs/fips/197/final/docs/fips-197.pdf), páginas impressas 35–36. As chaves e resultados esperados são constantes de referência; o testbench compara cada transformação, sem gerar os valores esperados usando o DUT.

## Problemas encontrados

Na primeira repetição do lint, os três projetos antigos restauraram bases existentes e emitiram aviso 237 (releitura necessária) e código 11, embora os resumos de RTL já estivessem sem violações. As bases anteriores foram guardadas em `build/previous_lint_week3/`; uma execução com bases novas concluiu os cinco projetos com código 0. Caso o aviso reapareça ao repetir o comando, use uma cópia limpa ou mova as pastas geradas `build/spyglass_*` para fora dos caminhos de trabalho e execute novamente. O Makefile preserva os códigos de erro da ferramenta.

SpyGlass também emite aviso de infraestrutura `POLICY_DEPRECATED` sobre políticas legadas que serão descontinuadas. A migração para VC SpyGlass depende da versão e licença do laboratório; esse aviso não é uma violação do RTL.

## Limitações e próximos passos

A composição de rodadas existe no testbench para verificar as transformações; não é um controlador AES sintetizável. As chaves de rodada são fornecidas pelo testbench. Expansão de chave, controle, protocolo de entrada/saída e validação do núcleo AES integrado pertencem à semana 04. Não houve síntese, medição de área/timing/potência, formal, SPI, CDC ou integração de baixo consumo nesta entrega.

Implementação e verificação do escopo da semana 03 no backlog concluídas; aceite acadêmico depende da revisão do instrutor e do enunciado oficial.

## Visualização das transformações no terminal

O testbench passou a exibir o AddRoundKey inicial e as dez rodadas com os valores reais de entrada/saída de cada transformação, chave aplicada em cada AddRoundKey e `[PASS]` após a comparação com a referência. A rodada final informa que MixColumns é omitido e apresenta o ciphertext. Os testes dirigidos e pseudoaleatórios continuam resumidos.

- `make minisoc-week3-test`: trace hexadecimal.
- `make minisoc-week3-test MINISOC_SIM_ARGS=+AES_MATRIX`: inclui matrizes 4×4 de entrada e saída lado a lado, respeitando a ordem de colunas AES.

Ambos os modos foram executados no VCS X-2025.06-SP2 em 06/11/2026: código 0, `ALL WEEK 3 TESTS PASSED` e 5.492 ns. Conferidos 40 passos com `[PASS]`, 11 chaves e o ciphertext FIPS esperado; o modo de matrizes apresentou 40 pares de matrizes. Os logs permanecem em `build/minisoc_week3/` e não são versionados. A mudança é restrita ao testbench, argumentos de simulação e documentação; o RTL não mudou, portanto o lint não foi repetido.
