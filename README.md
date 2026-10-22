# PUC-261 – Microcontrolador de 8 bits em FPGA

Este projeto implementa o **PUC-261**, um microcontrolador educacional de 8 bits com conjunto de instruções do tipo RISC. Ele foi descrito em VHDL e esquemático no Quartus II e roda na placa **Altera DE2** (Cyclone II EP2C35F672C6).

Para demonstrar o processador, um programa acende os LEDs da placa um de cada vez, em sequência. Uma chave inverte o sentido do deslocamento.

Desenvolvido na disciplina de Sistemas Reconfiguráveis (Engenharia de Computação, 1º semestre de 2026).

**Autores**
- João Gabriel Mendonça Geraime Teodoro
- Lucas Meira Duque
- Luís Felipe Henrique Campelo

**Orientação:** Prof. Francisco Manoel Pinto Garcia

---

## O que o projeto faz

Ao ligar a placa, o processador começa a executar o programa gravado na ROM:

1. Configura a porta A como saída, ligada aos LEDs vermelhos LEDR0–LEDR7.
2. Acende um único LED e chama uma sub-rotina de atraso.
3. Lê a porta B e testa o bit 7, que está ligado à chave SW17:
   - **SW17 = 0:** o LED aceso anda para a esquerda (LEDR0 → LEDR7).
   - **SW17 = 1:** o LED aceso anda para a direita (LEDR7 → LEDR0).
4. Repete o processo indefinidamente.

O botão **KEY3** reinicia o processador.

## Arquitetura do processador

| Item | Especificação |
|---|---|
| Arquitetura | Harvard (memórias separadas de instruções e dados) |
| Memória de programa (ROM) | 1k × 16 bits |
| Memória de dados + E/S | 512 bytes: RAM em 000h–0FFh, E/S em 100h–1FFh |
| Registradores de uso geral | 4 × 8 bits (R0–R3) |
| Flags de status | RC (carry), RH (half carry), RZ (zero), RV (overflow), RN (negativo) |
| Pilha | 8 níveis × 10 bits, usada por CALL/RET |
| Execução | 1 ciclo por instrução; desvios, CALL e RET levam 2 ciclos |

A unidade de controle é uma máquina de dois estados:
- **exec:** decodifica e executa a instrução.
- **wait_fetch:** depois de um desvio, espera um ciclo para a ROM entregar a instrução do novo endereço. A ROM tem saída registrada.

### Conjunto de instruções (16 bits)

| Formato | Bits 15–14 | Instruções | Flags afetados |
|---|---|---|---|
| ALU com 2 registradores | `00`, bit 8 = 0 | ADD, ADDC, SUB, SUBC, AND, OR, XOR, MOV | Aritméticas: todos; lógicas e MOV: só RZ |
| ALU com imediato (8 bits) | `00`, bit 8 = 1 | ADDI, ADDCI, SUBI, SUBCI, ANDI, ORI, XORI, MOVI | Mesma regra da linha anterior |
| ALU com 1 registrador | `01` | RLC, RRC, RL, RR, SLL, SRL, SRA, NOT | RZ sempre; RC em todas, exceto NOT |
| Memória/E/S (endereço de 9 bits) | `10` | RD, WR | Nenhum |
| Desvio/chamada (endereço de 10 bits) | `11` | JMP, JC, JH, JZ, JV, JN, CALL | Nenhum |
| Retorno / nenhuma operação | `11` | RET, NOP | Nenhum |

O registrador RA fica sempre nos bits 10–9 e RB nos bits 7–6. Qualquer código não definido é executado como NOP.

## Conteúdo do repositório

### Hardware

| Arquivo | Descrição |
|---|---|
| `Puc261_tp4.bdf` | Topo da hierarquia em esquemático: liga todos os blocos, os barramentos e os buffers tri-state |
| `control_unit.vhd` | Unidade de controle: decodificação das instruções e máquina de estados |
| `ALU.vhd` | ALU de 8 bits com 16 operações e geração dos 5 flags |
| `reg_bank.vhd` | Banco de registradores R0–R3 (2 leituras, 1 escrita) |
| `status_reg.vhd` | Registrador de status com habilitação de escrita por bit |
| `prog_cnt.vhd` | Contador de programa: manter, incrementar, desviar ou carregar da pilha |
| `stack.vhd` | Pilha de endereços de retorno |
| `ram_256x8.vhd` | RAM de dados 256 × 8 |
| `port_io.vhd` | Porta de E/S bidirecional de 8 bits (registrador de dados em `base`, de direção em `base+1`) |
| `rom_1024x16.tdf/.qip` | ROM de programa gerada pelo MegaWizard (altsyncram) |
| `*.bsf` | Símbolos dos blocos usados no esquemático |

### Programas (arquivos `.mif` da ROM)

| Arquivo | Descrição |
|---|---|
| `Teste3.mif` | Programa principal (LEDs em sequência com troca de sentido); é o que está carregado na ROM |
| `Final.mif` | LEDs em sequência sem leitura da chave, com atraso curto para simulação |
| `Teste2.mif` | Teste de CALL/RET |
| `Teste1.mif` | Eco: copia a porta B para a porta A |

### Simulação e projeto Quartus

| Arquivo | Descrição |
|---|---|
| `Puc261_tp4_teste*.vwf` | Formas de onda da simulação funcional |
| `Puc261_tp4.qpf` / `Puc261_tp4_bdf.qsf` | Projeto e configurações do Quartus (dispositivo, pinagem) |
| `Puc261_tp4_bdf.sof` | Arquivo de configuração para gravar a FPGA |
| `*.rpt`, `*.summary`, `db/`, `incremental_db/` | Relatórios e arquivos gerados pela compilação |

## Mapa de E/S e pinagem na DE2

| Sinal | Endereço | Ligação na placa |
|---|---|---|
| port_A (dados / direção) | 100h / 101h | LEDR0–LEDR7 |
| port_B (dados / direção) | 102h / 103h | port_b[0..2] = KEY0–KEY2, port_b[3..7] = SW13–SW17 |
| `clk` | – | CLOCK_50 (50 MHz, pino N2) |
| `nrst` (ativo em nível baixo) | – | KEY3 |

## Programa principal (`Teste3.mif`)

```
000  MOVI R0, FFh      ; R0 = FFh
001  WR   R0, 101h     ; porta A inteira como saída
002  MOVI R0, 01h      ; padrão inicial dos LEDs
003  WR   R0, 100h     ; atualiza os LEDs          <- laço principal
004  RD   R1, 102h     ; lê a porta B
005  ANDI R1, 80h      ; isola o bit 7 (SW17)
006  JZ   009h         ; chave = 0 -> gira à esquerda
007  RR   R0           ; chave = 1 -> gira à direita
008  JMP  00Ah
009  RL   R0
00A  CALL 020h         ; atraso
00B  JMP  003h

020  MOVI R1, 56h      ; sub-rotina de atraso: 3 laços aninhados
021  MOVI R2, 56h
022  MOVI R3, 56h
023  SUBI R3, 01h
024  JZ   026h
025  JMP  023h
026  SUBI R2, 01h
027  JZ   029h
028  JMP  022h
029  SUBI R1, 01h
02A  JZ   02Ch
02B  JMP  021h
02C  RET
```

Cada volta do laço interno gasta cerca de 5 ciclos. Com os três contadores em 56h (86), o atraso fica em cerca de 3,2 milhões de ciclos, ou ~64 ms a 50 MHz. Para mudar a velocidade, basta alterar os valores carregados em 020h–022h.

## Como usar

1. Abra `Puc261_tp4.qpf` no **Quartus II 9.1 SP2** (revisão `Puc261_tp4_bdf`).
2. Compile com **Processing → Start Compilation**.
3. Grave a placa: no **Programmer**, carregue o `Puc261_tp4_bdf.sof` no modo JTAG.
4. Para trocar o programa, edite o `.mif` (ou aponte a ROM para outro arquivo) e use **Processing → Update Memory Initialization File**.
5. Para simular, use **Processing → Generate Functional Simulation Netlist** e rode o simulador com um dos arquivos `.vwf`.

## Limitações conhecidas

- **Reset com o clock rodando:** se o KEY3 ficar pressionado enquanto o clock roda, a primeira instrução pode ser pulada ao soltar o botão. Uma solução é um estado de reset dedicado no `control_unit` que segure o PC em 0.
- **Multiplexador:** o mux da entrada B da ALU usa o símbolo `BUSMUX` da biblioteca do Quartus, e não um `lpm_mux` gerado pelo MegaWizard.
