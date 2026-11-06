# AES com SPI e baixo consumo

Esboço do projeto RTL de 15 semanas. A estrutura segue o exemplo simples fornecido, com um teste mínimo para conferir o ambiente.

**Estado atual:** exemplo de reset e sinal `ready`, mais os blocos combinacionais S-Box, SubBytes e ShiftRows da semana 02. AES, SPI, PLL, memória e controle de energia ainda serão desenvolvidos. A interface atual de `aes_spi_top` é provisória.

## Estrutura

```text
rtl/                  # RTL sintetizável, sem subdivisões por enquanto
models/               # futuros modelos de PLL e memória, fora da síntese
software/             # código C++ de estudo do AES
tb/                   # testbenches
scripts/              # listas de fontes e configuração de lint
syn/                  # síntese e SDC, a partir da semana 7
formal/               # equivalência RTL × netlist
upf/                  # intenção de potência
docs/
  architecture/       # pontos a definir na arquitetura
  spec/               # especificação fornecida 
  reports/            # relatórios semanais e logs reais
  backlog.md          # cronograma e tarefas
Makefile
```

## Executar

Em Linux ou WSL, com GNU Make, Verilator e Icarus Verilog no PATH:

```sh
git clone https://github.com/DaviAugustoGM/aes-spi-low-power-rtl.git
cd aes-spi-low-power-rtl
make test
```

No ambiente Synopsys do curso, após carregar as ferramentas:

```sh
make test TOOLCHAIN=synopsys
```

Essa opção usa SpyGlass e VCS. O caminho para carregar o ambiente depende do servidor do curso. O fluxo Synopsys ainda não foi validado nesta base.

`make test` executa lint, compilação e simulação. Também existem `make lint`, `make compile` e `make sim`. Qualquer falha de comando ou teste interrompe o fluxo. O resultado esperado da simulação é:

```text
PASS: reset assertion, synchronized release and ready
PASS: fluxo mínimo concluído
```

O teste verifica reset inicial, liberação sincronizada e reset durante operação. Binários e ondas ficam em `build/`; logs ficam em `docs/reports/logs/`, separados por ferramenta. O lint verifica apenas RTL; não é uma análise de CDC.

Ao criar módulos, inclua-os em `scripts/rtl.f`; testbenches em `scripts/tb.f`. Modelos comportamentais devem entrar somente na lista de simulação. Atualize o top do Makefile e do projeto de lint quando necessário.

## Estudo do AES em C++

Seu código está em [software/AES_v2.cpp](software/AES_v2.cpp), separado do RTL. Com um compilador C++ disponível, execute:

```sh
make aes-study
```

O programa imprime os estados intermediários das rodadas e salva a saída em `docs/reports/logs/aes_cpp.log`. Veja [como interpretar os resultados](software/README.md). Este exemplo de software não altera o estado de implementação do núcleo RTL.

Para decifrar o resultado e conferir a mensagem original, instale `software/requirements.txt` no seu ambiente Python e execute `python software/decrypt.py` ou `make decrypt`. As instruções e o resultado verificado estão em [software/README.md](software/README.md).

## Próximos passos

Completar o estudo AES/SPI, obter a especificação funcional e definir a arquitetura e o verificador. O sistema final precisa de AES, SPI no domínio SCLK, CDC, registradores, reset, PLL e subsistema de dados/memória. As interfaces devem ser compatíveis com as da trilha de verificação.

Síntese, Formality e UPF serão acrescentados nas etapas correspondentes, com a biblioteca e os requisitos reais do projeto. Os scripts avançados da primeira versão continuam recuperáveis pelo histórico Git.

Consulte [backlog](docs/backlog.md) e [relatório da semana 1](docs/reports/semana_01.md). O núcleo AES completo ainda não está integrado.

## MiniSoC AES — semana 02

Três módulos combinacionais em `rtl/minisoc_aes/`, com estado em ordem de colunas e byte 0 em `[127:120]`. O testbench autoverificável cobre as 256 entradas da S-Box, SubBytes e ShiftRows nas rodadas 1 e 10 do exemplo AES-128 FIPS-197 e a permutação de bytes 00..0F.

```sh
make minisoc-test  # VCS
make minisoc-lint  # SpyGlass, três tops independentes
make minisoc-all
```

Requer `vcs` e `spyglass` no PATH e licenças válidas; caminhos podem ser definidos com `VCS=...` e `SPYGLASS=...`. Os alvos anteriores continuam disponíveis. No laboratório, carregue primeiro `source /Tools/synopsys-scripts/snps.sh`. A metodologia pode ser sobrescrita com a variável de ambiente `SPYGLASS_METHODOLOGY`. Logs e arquivos gerados ficam em `build/` e não entram na entrega. O lint usa redirecionamento do shell, pois `-log` é incompatível com `-project`. Consulte os resultados e limitações em [semana 02](docs/reports/semana_02.md).
