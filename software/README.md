# Estudo do AES em C++

`AES_v2.cpp` é o código fornecido para acompanhar a cifração de um bloco com AES-128.

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

A compilação e execução foram verificadas localmente.

O compilador avisa que `decrypted_message` não é utilizada. O programa implementa apenas cifração, não decifração, SPI ou modos de energia. Para trocar mensagem/chave, edite `main` e mantenha entradas de 16 bytes; o código não trata mensagens de tamanho arbitrário.

## Confirmar por decifração em Python

`decrypt.py` é o script fornecido. Ele usa PyCryptodome para decifrar com a mesma chave do exemplo C++ e AES em modo ECB, sem padding.

Instale a dependência no ambiente Python escolhido:

```sh
python -m pip install -r software/requirements.txt
python software/decrypt.py
```

Informe `d51a01d792041808474f5907787f7b5e`. O resultado verificado é:

```text
Mensagem original: Hello. I am Davi
```

Também pode executar `make decrypt` (Python 3 no Linux/WSL) para salvar a saída em `docs/reports/logs/aes_decrypt.log`. Para escolher o interpretador, use `make decrypt PYTHON=python`.

O script espera hexadecimal válido, blocos completos de 16 bytes e texto decifrado em UTF-8. A chave está fixa; se alterá-la no C++, atualize-a aqui também. A recuperação da mensagem confirma o exemplo executado, sem substituir a verificação dos demais vetores AES e das etapas intermediárias.
