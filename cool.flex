/*
 *  The scanner definition for COOL.
 */

%{
#include "cool-parse.h"
#include "stringtab.h"
#include "utilities.h"

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

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

int comm=0;        /* Variable for comment nesting */

%}

/*
 * Define names for regular expressions here.
 */

%option case-insensitive

WHITESPACE        [\n\t\f\r\v]
ALPHA             [a-zA-Z]
DIGIT             [0-9]
DASHCOMMENT       --.*
types             [A-Z]({ALPHA}|{DIGIT}|_)*
objects           [a-z]({ALPHA}|{DIGIT}|_)*

SINGLES           "+"|"-"|"*"|"/"|"~"|"<"|"="|"("|")"|"{"|"}"|";"|":"|"."|","|"@"
INVALID           "`"|"!"|"#"|"$"|"%"|"^"|"&"|"_"|"["|"]"|"|"|[\\]|">"|"?"
TRUE              t[rR][uU][eE]
FALSE             f[aA][lL][sS][eE]
INT_CONST         [0-9]+

/*
 * State Definitions
 */
%x comment string escape

%%

 /*
  *  The multiple-character operators.
  */
"=>"            { return DARROW; }
"<-"            { return ASSIGN; }
"<="            { return LE; }

 /*
  * Case Insensitive Keywords
  */
class            { return CLASS; }
else             { return ELSE; }
fi               { return FI; }
if               { return IF; }
in               { return IN; }
inherits         { return INHERITS; }
let              { return LET; }
loop             { return LOOP; }
pool             { return POOL; }
then             { return THEN; }
while            { return WHILE; }
case             { return CASE; }
esac             { return ESAC; }
of               { return OF; }
new              { return NEW; }
isvoid           { return ISVOID; }
not              { return NOT; }

 /*
  * Start Case sensitive booleans
  */
{TRUE}           { cool_yylval.boolean = true; return BOOL_CONST; }
{FALSE}          { cool_yylval.boolean = false; return BOOL_CONST; }

 /*
  * Identifiers for Ints, Types, and Objects
  */
{INT_CONST}      {
                  cool_yylval.symbol = inttable.add_string(yytext);
                  return INT_CONST;
                }
{types}          {
                  cool_yylval.symbol = idtable.add_string(yytext);
                  return TYPEID;
                }
{objects}|(self) {
                  cool_yylval.symbol = idtable.add_string(yytext);
                  return OBJECTID;
                }

 /*
  * Single Character Special Syntactic Symbols
  */
{SINGLES}        { return yytext[0]; }

 /*
  * Single Invalid Characters
  */
{INVALID}        {
                  cool_yylval.error_msg = yytext;
                  return ERROR;
                }

/*
 * All Comments handled here
 */
"--".*           { /* Ignore single-line comments */ }
"\\(\\*"         { comm = 1; BEGIN(comment); }

<comment>\\*\\)  { if (--comm == 0) BEGIN(INITIAL); }
<comment>\\n     { curr_lineno++; }

<COMMENT><<EOF>> { BEGIN(INITIAL); cool_yylval.error_msg = "EOF in comment."; return ERROR; }

<COMMENT>.        { /* Ignore comment content */ }

 /*
  * String constants (C syntax)
  * Escape sequence \c is accepted for all characters c. Except for
  * \n \t \b \f, the result is c.
  */
"\""             { BEGIN(string); string_buf_ptr = string_buf; }
<string>"\""    {
                  if (string_buf_ptr - string_buf > MAX_STR_CONST - 1) {
                    *string_buf = '\\0';
                    return maxStrLength();
                  }
                  *string_buf_ptr = '\\0';
                  cool_yylval.symbol = stringtable.add_string(string_buf);
                  BEGIN(INITIAL);
                  return STR_CONST;
                }
<string><<EOF>>  { BEGIN(INITIAL); cool_yylval.error_msg = "EOF in string constant."; return ERROR; }
<string>\\0       { *string_buf = '\\0'; BEGIN(escape); cool_yylval.error_msg = "String contains null character."; return ERROR; }
<string>\\n       { *string_buf = '\\0'; BEGIN(INITIAL); cool_yylval.error_msg = "Unterminated string constant."; return ERROR; }
<string>"\\\\n"  { *string_buf_ptr++ = '\\n'; }
<string>"\\\\t"  { *string_buf_ptr++ = '\\t'; }
<string>"\\\\b"  { *string_buf_ptr++ = '\\b'; }
<string>"\\\\f"  { *string_buf_ptr++ = '\\f'; }
<string>"\\\\\\\\[^\\0]" { *string_buf_ptr++ = yytext[1]; }
<string>.         { *string_buf_ptr++ = *yytext; }

<escape>\\[\\n"] { BEGIN(INITIAL); }
<escape>[^\\n"]  { *string_buf_ptr++ = yytext[1]; }

 /*
  * Skip all Whitespace characters
  */
\\n               { curr_lineno++; }
{WHITESPACE}+    { }

 /*
  * When nothing matches, report error text
  */
.                { cool_yylval.error_msg = yytext; return ERROR; }

%%

int maxStrLength() {
    cool_yylval.error_msg = "String constant too long";
    BEGIN(escape);
    return ERROR;
}
