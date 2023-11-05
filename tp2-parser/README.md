# Trabalho Prático 2 - O Analisador Sintático COOL

## Alunos:

- Camila Santana Braz - 2019027423
- Pedro Robles Dutenhefner - 2018072557

Parser para a Linguagem COOL
Este é um parser desenvolvido para a linguagem COOL (Classroom Object Oriented Language) utilizando a ferramenta Bison (GNU Parser Generator) e C++. A COOL é uma linguagem de programação orientada a objetos concebida para contextos educacionais, mas que oferece suporte completo para os recursos presentes em linguagens de programação modernas.

Estrutura do Código
Prologue (Cabeçalho)
O prologue do código engloba inclusões de bibliotecas necessárias, definições de tipos e variáveis globais. Além disso, ele define macros que facilitam o manuseio de informações de localização, como números de linha, nos tokens.

Definição de Tokens
Nesta seção, são especificados os tokens necessários para a análise léxica da linguagem COOL. Cada token possui um número associado que serve para identificação interna.

Definição de Não-Terminais e Regras Gramaticais
Aqui, são definidos os não-terminais da gramática COOL e suas respectivas regras. Cada regra gramatical detalha como os não-terminais podem ser derivados a partir de outros não-terminais ou tokens. Estas regras também incluem ações semânticas que são executadas durante o processo de análise para construir a árvore de sintaxe abstrata (AST).

Definição de Ações Semânticas
Nesta seção, encontram-se as ações semânticas que são acionadas durante a análise sintática. Essas ações são responsáveis por construir a árvore de sintaxe abstrata (AST) da linguagem COOL. O AST representa a estrutura hierárquica do programa em forma de árvore, possibilitando análises e manipulações posteriores.

Função yyerror
A função yyerror é invocada para cada erro de análise encontrado durante o processo de compilação. Ela exibe mensagens de erro detalhadas, incluindo informações como o nome do arquivo, a linha e o token onde o erro ocorreu.

Gramática e Produções
A gramática de uma linguagem de programação define sua estrutura sintática, ou seja, como os diferentes elementos do código fonte podem ser combinados para formar programas válidos. No caso do parser COOL apresentado, a gramática foi definida usando a notação de gramática livre de contexto (BNF).

Tokens
Tokens são os blocos básicos da linguagem que são identificados durante a análise léxica. Eles são representados por palavras-chave, símbolos e literais na linguagem de programação. Alguns dos tokens definidos no parser COOL incluem:

CLASS, INHERITS, IF, THEN, ELSE, FI, WHILE, LOOP: Palavras-chave reservadas.
OBJECTID: Identificadores de objetos, como nomes de variáveis e métodos.
TYPEID: Identificadores de tipos, usados para declarar tipos de variáveis e argumentos de método.
INT_CONST: Constantes inteiras.
STR_CONST: Constantes de string.
BOOL_CONST: Constantes booleanas.
ASSIGN, PLUS, MINUS, TIMES, DIVIDE: Operadores aritméticos e de atribuição.
NOT, LE, <, EQUALS: Operadores lógicos e de comparação.
E outros tokens específicos da linguagem COOL.
Não-Terminais
Os não-terminais representam estruturas gramaticais mais complexas e são formados por combinações de tokens e outros não-terminais. Alguns exemplos dos não-terminais definidos no parser COOL incluem:

program: Representa um programa COOL completo, que consiste em uma lista de definições de classes.
class_list: Representa uma lista de definições de classes.
class: Representa uma definição de classe COOL.
features_list: Representa uma lista de membros (atributos e métodos) de uma classe.
feature: Representa um membro de uma classe, que pode ser um atributo ou um método.
....
E outros não-terminais necessários para a gramática COOL.

Regras Gramaticais e Ações Semânticas
As regras gramaticais definem como os não-terminais podem ser derivados a partir de outros não-terminais ou tokens. Cada regra tem uma forma geral, como non_terminal: production1 | production2 | ..., indicando as diferentes maneiras pelas quais o não-terminal pode ser construído.

As ações semânticas são inseridas nas regras gramaticais para realizar operações durante a análise sintática. Elas são responsáveis por construir a árvore de sintaxe abstrata (AST) da linguagem COOL. Por exemplo, uma regra para definir um método pode incluir ações semânticas para criar um nó de árvore correspondente a esse método.

Exemplo de Regra Gramatical com Ações Semânticas:

method_feature : OBJECTID '(' formals ')' ':' TYPEID '{' expr '}' {
                  $$ = method($1, $3, $6, $8);
                }

Neste exemplo, a regra method_feature representa a definição de um método em uma classe COOL. A ação semântica associada à regra ($$ = method(...);) cria um nó de árvore correspondente ao método, usando as informações capturadas pelos não-terminais e tokens na regra.
