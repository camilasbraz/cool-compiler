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
 * Define names for regular expressions here.
 */


DIGIT               [0-9]
LOWERCASE_LETTER    [a-z]
UPPERCASE_LETTER    [A-Z]
LETTER              ({LOWERCASE_LETTER}|{UPPERCASE_LETTER})
BLANK               (" "|\f|\r|\t|\v)

DARROW          =>
LE              <=
ASSIGN          <-


INT_CONST        {DIGIT}+
BOOL_CONST_TRUE  (t)(?i:rue)
BOOL_CONST_FALSE (f)(?i:alse)
TYPEID           ("SELF_TYPE"|{UPPERCASE_LETTER}({LETTER}|{DIGIT}|"_")*)
OBJECTID         ("self"|{LETTER}({LETTER}|{DIGIT}|"_")*)


NESTED_COMMENT_START   "(*"
NESTED_COMMENT_END     "*)"
SIMPLE_COMMENT_START   "--"

STR_CONST_DELIMITER              \"
%%

 /*
  *  Simple and nested comments
  */

{SIMPLE_COMMENT_START} { BEGIN(SIMPLE_COMMENT); }
<SIMPLE_COMMENT>\n        { curr_lineno++; BEGIN(INITIAL); }
<SIMPLE_COMMENT>.         {  }

{NESTED_COMMENT_START} { comment_size++; BEGIN(NESTED_COMMENT); comment_nested = 1; }
<NESTED_COMMENT>{NESTED_COMMENT_START} { comment_size++; }
<NESTED_COMMENT>{NESTED_COMMENT_END} {
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
      
    cool_yylval.error_msg = "EOF in comment";
    error_flag = 1;
    return (ERROR);
}
<NESTED_COMMENT>\n        { curr_lineno++; }
<NESTED_COMMENT>.         {  }

{NESTED_COMMENT_END} {
  if (!comment_nested) {
    cool_yylval.error_msg = "Unmatched *)";
	  return (ERROR);
  }
}


 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

"+"             {   return '+'; }
"/"             {   return '/'; }
"-"             {   return '-'; }
""             {   return ''; }
"="             {   return '='; }
"<"             {   return '<'; }
"."             {   return '.'; }
""             {   return ''; }
","             {   return ','; }
";"             {   return ';'; }
":"             {   return ':'; }
"("             {   return '('; }
")"             {   return ')'; }
"@"             {   return '@'; }
"{"             {   return '{'; }
"}"             {   return '}'; }


(?i:class)      {   return (CLASS); }
(?i:else)       {   return (ELSE); }
(?i:fi)         {   return (FI); }
(?i:if)         {   return (IF); }
(?i:in)         {   return (IN); }
(?i:inherits)   {   return (INHERITS); }
(?i:let)        {   return (LET); }
(?i:loop)       {   return (LOOP); }
(?i:pool)       {   return (POOL); }
(?i:then)       {   return (THEN); }
(?i:while)      {   return (WHILE); }
(?i:case)       {   return (CASE); }
(?i:esac)       {   return (ESAC); }
(?i:of)         {   return (OF); }
(?i:new)        {   return (NEW); }
(?i:not)        {   return (NOT); }
(?i:isvoid)     {   return (ISVOID); }

{DARROW}		{   return DARROW; }
{LE}            {   return LE; }
{ASSIGN}        {   return ASSIGN; }

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
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


{STR_CONST_DELIMITER}  { BEGIN(STRING_CONSTANT); }
<STRING_CONSTANT>{STR_CONST_DELIMITER} {
  string_buf_ptr = (char*) &string_buf;
  cool_yylval.symbol = idtable.add_string(string_buf_ptr, string_size);
  string_size = 0;
  BEGIN(INITIAL);
  return (STR_CONST);
}
<STRING_CONSTANT><<EOF>> {
    if (error_flag)
      yyterminate();
      
    cool_yylval.error_msg = "EOF in string constant";
    error_flag = 1;
    return (ERROR);
}
<STRING_CONSTANT>\0 {
  	cool_yylval.error_msg = "String contains null character";
    string_size = 0;
		BEGIN(ESCAPE);
		return ERROR;
}
<STRING_CONSTANT>\n {
  	cool_yylval.error_msg = "Unterminated string constant";
    string_size = 0;
    curr_lineno++;
	  BEGIN(INITIAL);
		return ERROR;
}
<STRING_CONSTANT>"\\n" {
    if (string_size + 1< MAX_STR_CONST) {
      string_buf[string_size++] = '\n'; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      string_size = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>"\\t" {
    if (string_size + 1 < MAX_STR_CONST) {
      string_buf[string_size++] = '\t'; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      string_size = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>"\\b" {
    if (string_size + 1 < MAX_STR_CONST) {
      string_buf[string_size++] = '\b'; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      string_size = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>"\\f" {
    if (string_size + 1 < MAX_STR_CONST) {
      string_buf[string_size++] = '\f'; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      string_size = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>"\\"[^\0] {
    if (string_size + 1 < MAX_STR_CONST) {
      string_buf[string_size++] = yytext[1]; 
    } 
    else {
      cool_yylval.error_msg = "String literal too long";
      string_size = 0;
      BEGIN(ESCAPE);
      return (ERROR); 
    }
}
<STRING_CONSTANT>. {
    if (string_size + 1 < MAX_STR_CONST ) {
      string_buf[string_size++] = yytext[0];
    }
    else {
      cool_yylval.error_msg = "String constant too long";
        string_size = 0;

      BEGIN(ESCAPE);
      return (ERROR); 
    }
}

<ESCAPE>[\n|"]	 { BEGIN(INITIAL);  }
<ESCAPE>[^\n|"]	 { }

%%