# Arquitetura — a definir na semana 2

O sistema previsto contém RESET, PLL, SPI, CDC, banco de registradores, núcleo AES e subsistema de dados/memória. O exemplo atual valida somente o ambiente e o reset.

Antes de implementar, confirmar:

- Interfaces de topo: GLOBAL RESET, clock do oscilador, SPI IF e MEMORY DATA IF.
- AES: tamanhos de chave, cifração/decifração, ordem dos bytes e microarquitetura.
- SPI: modo, formato dos comandos, ordem dos bits e mapa de registradores.
- SPI no domínio SCLK; registradores/AES no domínio do sistema; travessia coerente de comandos e respostas.
- Reset por domínio, configuração padrão do PLL, sinal locked e reconfiguração.
- Interfaces dos modelos de PLL/memória compatíveis com o verificador.
- Biblioteca, frequências alvo e ferramentas disponíveis.

Domínios de potência, isolamento, retenção e sequências de energia serão definidos nas semanas 10–12. Esta página não constitui arquitetura aprovada.
