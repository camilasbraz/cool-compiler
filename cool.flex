/*
 * Definição do analisador léxico para COOL.
 */

/*
 * Conteúdo dentro de %{ %} na primeira seção é copiado literalmente para o
 * arquivo de saída, portanto, cabeçalhos e definições globais são colocados aqui
 * para serem visíveis para o código no arquivo. Não remova nada que já estava aqui.
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* O compilador assume esses identificadores. */
#define yylval cool_yylval
#define yylex cool_yylex

/* Tamanho máximo das constantes de string */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT /* mantém o g++ feliz */

/*
   As duas declarações abaixo estão aqui apenas para que este programa compile.
   Você pode precisar alterá-las ou removê-las em seu código final.
*/
#define yywrap() 1
#define YY_SKIP_YYWRAP

extern FILE fin; // Lemos deste arquivo

/* Define YY_INPUT para ler do arquivo FILE fin:
 * Essa mudança permite o uso deste analisador léxico no compilador Cool.
 */
#undef YY_INPUT
#define YY_INPUT(buf, result, max_size)                               \
    if ((result = fread((char *)buf, sizeof(char), max_size, fin)) < 0) \
        YY_FATAL_ERROR("read() no analisador léxico flex falhou");

char string_buf[MAX_STR_CONST]; /* Para montar constantes de string */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 * Adicione suas próprias definições aqui.
 */

int comment_size = 0;
int comment_nested = 0;
int error_flag = 0;
int string_size = 0;

%}

%x STRING_CONSTANT
%x ESCAPE
%x NESTED_COMMENT
%x SIMPLE_COMMENT

/*
 * Defina nomes para expressões regulares aqui.
 */

DIGIT [0-9]
LOWERCASE_LETTER [a-z]
UPPERCASE_LETTER [A-Z]
LETTER ({LOWERCASE_LETTER}|{UPPERCASE_LETTER})
BLANK (" "|\f|\r|\t|\v)

CLASS (?i:class)
ELSE (?i:else)
FI (?i:fi)
IF (?i:if)
IN (?i:in)
INHERITS (?i:inherits)
LET (?i:let)
LOOP (?i:loop)
POOL (?i:pool)
THEN (?i:then)
WHILE (?i:while)
CASE (?i:case)
ESAC (?i:esac)
OF (?i:of)
NEW (?i:new)
NOT (?i:not)
ISVOID (?i:isvoid)

DARROW "=>"
LE "<="
ASSIGN "<-"

INT_CONST {DIGIT}+
BOOL_CONST_TRUE (t)(?i:rue)
BOOL_CONST_FALSE (f)(?i:alse)
TYPEID ("SELF_TYPE"|{UPPERCASE_LETTER}({LETTER}|{DIGIT}|"_")*)
OBJECTID ("self"|{LETTER}({LETTER}|{DIGIT}|"_")*)

NESTED_COMMENT_START "(*"
NESTED_COMMENT_END "*)"
SIMPLE_COMMENT_START "--"

STR_CONST_DELIMITER \"
%%

/*
 * Comentários simples e aninhados
 */

{SIMPLE_COMMENT_START} { BEGIN(SIMPLE_COMMENT); }
<SIMPLE_COMMENT>\n { curr_lineno++; BEGIN(INITIAL); }
<SIMPLE_COMMENT>. {}

{NESTED_COMMENT_START}
{
    comment_size++;
    BEGIN(NESTED_COMMENT);
    comment_nested = 1;
}

<NESTED_COMMENT>{NESTED_COMMENT_START} { comment_size++; }
<NESTED_COMMENT>{NESTED_COMMENT_END}
{
    comment_size--;

    if (comment_size < 0) {
        cool_yylval.error_msg = "Unmatched *)";
        return (ERROR);
    }

    if (comment_size == 0) {
        comment_nested = 0;
        BEGIN(INITIAL);
    }
}

<NESTED_COMMENT><<EOF>> {
    if (error_flag)
        yyterminate();

    cool_yylval.error_msg = "EOF no comentário";
    error_flag = 1;
    return (ERROR);
}
<NESTED_COMMENT>\n { curr_lineno++; }
<NESTED_COMMENT>. {}

{NESTED_COMMENT_END}
{
    if (!comment_nested) {
        cool_yylval.error_msg = "Unmatched *)";
        return (ERROR);
    }
}

/*
 * Operadores de um e dois caracteres.
 */
{DARROW} return (DARROW);
{LE} return (LE);
{ASSIGN} return (ASSIGN);

/*
 * Palavras-chave não são sensíveis a maiúsculas e minúsculas, exceto para os valores true e false,
 * que devem começar com uma letra minúscula.
 */
{CLASS} return (CLASS);
{ELSE} return (ELSE);
{FI} return (FI);
{IF} return (IF);
{IN} return (IN);
{INHERITS} return (INHERITS);
{LET} return (LET);
{LOOP} return (LOOP);
{POOL} return (POOL);
{THEN} return (THEN);
{WHILE} return (WHILE);
{CASE} return (CASE);
{ESAC} return (ESAC);
{OF} return (OF);
{NEW} return (NEW);
{ISVOID} return (ISVOID);
{NOT} return (NOT);

"+" return '+';
"-" return '-';
"" return '';
"/" return '/';
"" return '';
"<" return '<';
"=" return '=';
"(" return '(';
")" return ')';
"{" return '{';
"}" return '}';
";" return ';';
":" return ':';
"." return '.';
"," return ',';
"@" return '@';

\n {
    curr_lineno++;
}

{BLANK}+ {}

{BOOL_CONST_TRUE} {
    cool_yylval.boolean = true;
    return (BOOL_CONST);
}

{BOOL_CONST_FALSE} {
    cool_yylval.boolean = false;
    return (BOOL_CONST);
}

{INT_CONST} {
    cool_yylval.symbol = inttable.add_string(yytext);
    return (INT_CONST);
}

{TYPEID} {
    cool_yylval.symbol = inttable.add_string(yytext);
    return (TYPEID);
}
{OBJECTID} {
    cool_yylval.symbol = inttable.add_string(yytext);
    return (OBJECTID);
}

/*
 * Constantes de string (sintaxe C)
 * Sequência de escape \c é aceita para todos os caracteres c. Exceto para
 * \n \t \b \f, o resultado é c.
 */
{STR_CONST_DELIMITER} { BEGIN(STRING_CONSTANT); }
<STRING_CONSTANT>{STR_CONST_DELIMITER} {
    string_buf_ptr = (char *)&string_buf;
    cool_yylval.symbol = idtable.add_string(string_buf_ptr, string_size);
    string_size = 0;
    BEGIN(INITIAL);
    return (STR_CONST);
}
<STRING_CONSTANT><<