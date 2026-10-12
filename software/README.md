# Estudo do AES em C++

`AES_v2.cpp` é o código fornecido pelo autor para acompanhar a cifração de um bloco com AES-128. Foi acrescentado `#include <cstdint>` para declarar `uint8_t` e `uint32_t`, e o texto foi normalizado para UTF-8; a lógica foi preservada. O arquivo original em Downloads não foi alterado.

## Executar

Em Linux/WSL com GNU Make e g++:

```sh
make aes-study
```

O executável fica em `build/aes_study` e a saída em `docs/reports/logs/aes_cpp.log`. O comando é independente de VCS, SpyGlass e do teste RTL. Para usar outro compilador, por exemplo: `make aes-study CXX=clang++`.

## Entender a saída

O programa mostra o estado após AddRoundKey inicial, depois de cada transformação das rodadas 1–9 e na rodada 10, que não executa MixColumns. A expansão de chave é calculada, mas as chaves de rodada não são impressas.

As matrizes são impressas por linha. A mensagem entra e o resultado sai por coluna: leia de cima para baixo a primeira coluna, depois as demais. Essa diferença de apresentação deve ser considerada ao comparar com um vetor hexadecimal ou com o futuro RTL.

No exemplo definido em `main`, mensagem e chave têm exatamente 16 bytes:

| Campo | Valor |
|---|---|
| Mensagem | `Hello. I am Davi` |
| Mensagem em hexadecimal | `48656c6c6f2e204920616d2044617669` |
| Chave | `I see the messag` |
| Chave em hexadecimal | `492073656520746865206d6573736167` |
| Resultado em hexadecimal | `d51a01d792041808474f5907787f7b5e` |

A compilação e execução foram verificadas localmente. Esse resultado foi comparado com `openssl enc -aes-128-ecb`, sem padding e sem salt, para os mesmos 16 bytes e chave, e coincidiu. Essa comparação valida o exemplo executado; os demais vetores e estados intermediários ainda precisam ser verificados antes de usar o código como referência dos testes RTL.

O compilador avisa que `decrypted_message` não é utilizada. O programa implementa apenas cifração, não decifração, SPI ou modos de energia. Para trocar mensagem/chave, edite `main` e mantenha entradas de 16 bytes; o código não trata mensagens de tamanho arbitrário.
