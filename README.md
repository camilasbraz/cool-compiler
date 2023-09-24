# Trabalho Prático 1 - O Analisador Léxico COOL

## Alunos:

- Camila Santana Braz - 2019027423
- Pedro Robles Dutenhefner - 2018072557

No desenvolvimento deste projeto, foi necessário definir as regras Flex que se alinham com a especificação dos tokens presentes na linguagem COOL (Classroom Object Oriented Language). Esse processo envolveu a criação de expressões regulares que abrangem as diversas categorias de tokens da linguagem, abarcando identificadores, números, strings, comentários e outros elementos. A elaboração dessas regras baseou-se no manual oficial da linguagem Cool e no guia de uso do Flex.

Além de definir dos tokens, foram estabelecidas ações específicas a serem tomadas quando ocorressem suas identificações, incluindo a necessidade de armazenar os lexemas quando relevante, como nos casos de identificadores e literais.

Para a construção completa dessas definições, foram criados quatro contextos distintos: ambiente de comentário, ambiente de comentário de várias linhas, ambiente de literal de string e ambiente de sequência de escape de quebra de linha. Esses contextos foram essenciais devido às diferentes maneiras pelas quais o reconhecimento de tokens ocorre em cada um deles. Por exemplo, quando dentro de uma string, não se deve reconhecer outros tokens até que o caractere de terminação de string seja encontrado.

A incorporação desses contextos possibilitou a detecção de erros previstos na especificação da linguagem Cool, como strings não fechadas e comentários não encerrados, proporcionando ainda a adição de mensagens de erro para os casos em que um token não é reconhecido ou quando um dos problemas mencionados anteriormente é identificado.

Por fim, foi realizado um aprimoramento do arquivo test.cl, incluindo um conjunto mais amplo de testes, abrangendo uma maior variedade de tokens e situações de erro.
