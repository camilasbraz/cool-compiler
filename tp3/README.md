## Decisões de design

#### O ponto de entrada é o construtor da classe CgenClassTable, onde são adicionadas as classes básicas à tabela.

#### Posteriormente, as demais classes são adicionadas à tabela, e a árvore de herança é construída. Além disso, também é criado um array invertido de classes que se refere à elas no construtor, para invocar a função de codificação.

#### Na função de codificação, os dados globais são codificados primeiramente, e em seguida o coletor de lixo é selecionado.

#### Em seguida, é emitida a codificação para todas as constantes do programa. Posteriormente, é construída uma tabela para conter os nomes das classes que aparecem no programa. O mesmo é feito para objetos.

#### Também são emitidos objetos protótipo para todas as classes do programa, e os métodos de inicialização. Depois, são emitidos o restante dos métodos, e sua codificação.
