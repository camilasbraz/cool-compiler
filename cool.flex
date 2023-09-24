/*
 *  The scanner definition for COOL.
 */
 
/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */
/*
   The two statements below are here just so this program will compile.
   You may need to change or remove them on your final code.
*/
#define yywrap() 1
#define YY_SKIP_YYWRAP

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

int error_found = 0;
int str_length = 0;
int comment_depth = 0;
int in_nested_comment = 0;

%}


%x STRING_CONSTANT
%x ESCAPE
%x NESTED_COMMENT
%x SIMPLE_COMMENT

DARROW        "=>"
{DARROW} return(DARROW);
LE            "<="
{LE}     return(LE);
ASSIGN        "<-"
{ASSIGN} return(ASSIGN);

FI          (?i:fi)
{FI}        return (FI);
POOL        (?i:pool)
{POOL}      return (POOL);
CLASS       (?i:class)
{CLASS}     return (CLASS);
THEN        (?i:then)
{THEN}      return (THEN);
ELSE        (?i:else)
{ELSE}      return (ELSE);
NEW         (?i:new)
{NEW}       return (NEW);
ISVOID      (?i:isvoid)
{ISVOID}    return (ISVOID);
NOT         (?i:not)
{NOT}       return (NOT);
CASE        (?i:case)
{CASE}      return (CASE);
ESAC        (?i:esac)
{ESAC}      return (ESAC);
WHILE       (?i:while)
{WHILE}     return (WHILE);
IF          (?i:if)
{IF}        return (IF);
IN          (?i:in)
{IN}        return (IN);
INHERITS    (?i:inherits)
{INHERITS}  return (INHERITS);
LET         (?i:let)
{LET}       return (LET);
LOOP        (?i:loop)
{LOOP}      return (LOOP);
OF          (?i:of)
{OF}        return (OF);

DIGIT               [0-9]
LOWERCASE_LETTER    [a-z]
UPPERCASE_LETTER    [A-Z]
LETTER              ({LOWERCASE_LETTER}|{UPPERCASE_LETTER})
BLANK               (" "|\f|\r|\t|\v)

INT_CONST        {DIGIT}+
BOOL_CONST_TRUE  (t)(?i:rue)
BOOL_CONST_FALSE (f)(?i:alse)
TYPEID           ("SELF_TYPE"|{UPPERCASE_LETTER}({LETTER}|{DIGIT}|"_")*)
OBJECTID         ("self"|{LETTER}({LETTER}|{DIGIT}|"_")*)

NESTED_COMMENT_START   "(*"
NESTED_COMMENT_END     "*)"
SIMPLE_COMMENT_START   "--"

"+"         return '+';
"-"         return '-';
"*"         return '*';
"/"         return '/';
"~"         return '~';
"<"         return '<';
"="         return '=';
"("         return '(';
")"         return ')';
"{"         return '{';
"}"         return '}';
";"         return ';';
":"         return ':';
"."         return '.';
","         return ',';
"@"         return '@';

STR_CONST_DELIMITER              \"
%%

 /*
  *  Simple and nested comments
  */

{SIMPLE_COMMENT_START} {
    BEGIN(SIMPLE_COMMENT);
}

<SIMPLE_COMMENT>. {
    // Ignorar caracteres dentro de comentário simples
}

<SIMPLE_COMMENT>\n {
    curr_lineno++;
    BEGIN(INITIAL);
}

{NESTED_COMMENT_START} {
    comment_depth++;
    BEGIN(NESTED_COMMENT);
}

<NESTED_COMMENT>{NESTED_COMMENT_START} {
    comment_depth++;
}

<NESTED_COMMENT>{NESTED_COMMENT_END} {
  if (comment_depth > 0) {
    comment_depth--;
  } else {
    cool_yylval.error_msg = "Unmatched *)";
    return (ERROR);
  }

  if (comment_depth == 0) {
    in_nested_comment = 0;
    BEGIN(INITIAL);
  }
}

<NESTED_COMMENT><<EOF>> {
    if (error_found)
      yyterminate();
      
    cool_yylval.error_msg = "EOF in comment";
    error_found = 1;
    return (ERROR);
}


<NESTED_COMMENT>\n { 
  curr_lineno++; 
}

<NESTED_COMMENT>. {
}

{NESTED_COMMENT_END} {
    if (comment_depth == 0) {
        cool_yylval.error_msg = "Unmatched *)";
        return (ERROR);
    }
    comment_depth--;
}


\n {
 curr_lineno++; 
}

{BLANK}+ {

}

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




{STR_CONST_DELIMITER}  { BEGIN(STRING_CONSTANT); }
<STRING_CONSTANT>{STR_CONST_DELIMITER} {
  string_buf_ptr = (char*) &string_buf;
  cool_yylval.symbol = idtable.add_string(string_buf_ptr, str_length);
  str_length = 0;
  BEGIN(INITIAL);
  return (STR_CONST);
}
<STRING_CONSTANT><<EOF>> {
    if (error_found)
      yyterminate();
      
    cool_yylval.error_msg = "EOF in string constant";
    error_found = 1;
    return (ERROR);
}
<STRING_CONSTANT>\0 {
  	cool_yylval.error_msg = "String contains null character";
    str_length = 0;
		BEGIN(ESCAPE);
		return ERROR;
}
<STRING_CONSTANT>\n {
  	cool_yylval.error_msg = "Unterminated string constant";
    str_length = 0;
    curr_lineno++;
	  BEGIN(INITIAL);
		return ERROR;
}
<STRING_CONSTANT>"\\n" {
    if (str_length + 1< MAX_STR_CONST) {
      string_buf[str_length++] = '\n'; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      str_length = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>"\\t" {
    if (str_length + 1 < MAX_STR_CONST) {
      string_buf[str_length++] = '\t'; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      str_length = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>"\\b" {
    if (str_length + 1 < MAX_STR_CONST) {
      string_buf[str_length++] = '\b'; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      str_length = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>"\\f" {
    if (str_length + 1 < MAX_STR_CONST) {
      string_buf[str_length++] = '\f'; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      str_length = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>"\\"[^\0] {
    if (str_length + 1 < MAX_STR_CONST) {
      string_buf[str_length++] = yytext[1]; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      str_length = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>. {
    if (str_length + 1 < MAX_STR_CONST ) {
      string_buf[str_length++] = yytext[0];
    }
    else {
      cool_yylval.error_msg = "String constant too long";
        str_length = 0;

      BEGIN(ESCAPE);
      return (ERROR); 
    }
}

<ESCAPE>[\n|"] {
   BEGIN(INITIAL);
}
<ESCAPE>[^\n|"]	 { 

}

%%