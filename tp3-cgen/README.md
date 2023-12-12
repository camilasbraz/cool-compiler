## Visão Geral
Este projeto implementa a geração de código para o compilador da linguagem COOL (Classroom Object-Oriented Language), desenvolvido no curso de Compiladores da Universidade de Stanford. O objetivo principal é converter a Árvore de Análise Sintática Abstrata (AST) em código de máquina SPIM, uma variante do MIPS que é usada para propósitos educacionais.

## Estrutura do Projeto
O projeto consiste em vários arquivos, com o principal sendo `cgen.cc`. Este arquivo contém a lógica para percorrer a AST e gerar código de máquina correspondente. Outros arquivos importantes incluem:

- `cgen.h`: Define as classes e métodos utilizados para a geração de código.
- `cgen_gc.h`: Contém funções relacionadas à coleta de lixo.
- `cool-tree.h`: Define a estrutura da AST.

## `cgen.cc` - Esqueleto do Gerador de Código
`cgen.cc` é o arquivo esqueleto para o gerador de código. Este fornece três componentes essenciais do gerador de código:

- Funções para construir o grafo de herança (fornecido caso não tenha sido implementado no PA4).
- Funções para emitir dados globais e constantes.
- Funções para emitir instruções SPIM.

## `cgen.h` - Arquivo de Cabeçalho
`cgen.h` é o arquivo de cabeçalho para o gerador de código. Sinta-se à vontade para adicionar o que for necessário.

## `cgen_supp.cc` - Suporte ao Gerador de Código
`cgen_supp.cc` contém código de suporte geral para o gerador de código. Você pode adicionar funções conforme achar necessário, mas não modifique as três funções:

- `byte_mode`
- `ascii_mode`
- `emit_string_constant`

## `emit.h` - Macros Úteis
`emit.h` define uma série de macros úteis para a emissão de código. Altere conforme necessário para atender às suas necessidades.

## Funcionalidades Implementadas
O esqueleto do código gera segmentos iniciais, declara globais e emite constantes. As funcionalidades implementadas incluem:

- Inicialização das tags de classes base em `CgenClassTable::CgenClassTable`.
- Adição de rótulos para tabelas de despacho em `IntEntry::code_def`, `StringEntry::code_def`, e `BoolConst::code_def`.
- Geração de código para todas as necessidades restantes em `CgenClassTable::code`.


## Testes
O arquivo `example.cl` é um exemplo de um programa escrito em COOL com diversos teste da linguagem. Ele passa pelo gerador de código e a execução do SPIM no output gerado roda o programa corretamente.

