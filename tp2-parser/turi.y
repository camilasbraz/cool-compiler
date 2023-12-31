/*
*  cool.y
*              Parser definition for the COOL language.
*
*/

/* http://www.gnu.org/software/bison/manual/bison.html#Prologue
 */
%{
  #include <iostream>
  #include "cool-tree.h"
  #include "stringtab.h"
  #include "utilities.h"
  #include "list.h"
  
  extern char *curr_filename;
  
  
  /* Locations */
  #define YYLTYPE int              /* the type of locations */
  #define cool_yylloc curr_lineno  /* use the curr_lineno from the lexer
  for the location of tokens */
    
    extern int node_lineno;          /* set before constructing a tree node
    to whatever you want the line number
    for the tree node to be */
      
      
      #define YYLLOC_DEFAULT(Current, Rhs, N)         \
      Current = Rhs[1];                             \
      node_lineno = Current;
    
    
    #define SET_NODELOC(Current)  \
    node_lineno = Current;
    
    /* IMPORTANT NOTE ON LINE NUMBERS
    *********************************
    * The above definitions and macros cause every terminal in your grammar to 
    * have the line number supplied by the lexer. The only task you have to
    * implement for line numbers to work correctly, is to use SET_NODELOC()
    * before constructing any constructs from non-terminals in your grammar.
    * Example: Consider you are matching on the following very restrictive 
    * (fictional) construct that matches a plus between two integer constants. 
    * (SUCH A RULE SHOULD NOT BE  PART OF YOUR PARSER):
    
    plus_consts : INT_CONST '+' INT_CONST 
    
    * where INT_CONST is a terminal for an integer constant. Now, a correct
    * action for this rule that attaches the correct line number to plus_const
    * would look like the following:
    
    plus_consts : INT_CONST '+' INT_CONST 
    {
      // Set the line number of the current non-terminal:
      // ***********************************************
      // You can access the line numbers of the i'th item with @i, just
      // like you acess the value of the i'th exporession with $i.
      //
      // Here, we choose the line number of the last INT_CONST (@3) as the
      // line number of the resulting expression (@$). You are free to pick
      // any reasonable line as the line number of non-terminals. If you 
      // omit the statement @$=..., bison has default rules for deciding which 
      // line number to use. Check the manual for details if you are interested.
      @$ = @3;
      
      
      // Observe that we call SET_NODELOC(@3); this will set the global variable
      // node_lineno to @3. Since the constructor call "plus" uses the value of 
      // this global, the plus node will now have the correct line number.
      SET_NODELOC(@3);
      
      // construct the result node:
      $$ = plus(int_const($1), int_const($3));
    }
    
    */
    
    
    
    void yyerror(char *s);        /*  defined below; called for each parse error */
    extern int yylex();           /*  the entry point to the lexer  */

    /************************************************************************/
    /*                DONT CHANGE ANYTHING IN THIS SECTION                  */
    
    Program ast_root;       /* the result of the parse  */
    Classes parse_results;        /* for use in semantic analysis */
    int omerrs = 0;               /* number of errors in lexing and parsing */
    %}
    
    /* A union of all the types that can be the result of parsing actions. */
    %union {
      Boolean boolean;
      Symbol symbol;
      Program program;
      Class_ class_;
      Classes classes;
      Feature feature;
      Features features;
      Formal formal;
      Formals formals;
      Case case_;
      Cases cases;
      Expression expression;
      Expressions expressions;
      char *error_msg;
    }
    
    /* 
    Declare the terminals; a few have types for associated lexemes.
    The token ERROR is never used in the parser; thus, it is a parse
    error when the lexer returns it.
    
    The integer following token declaration is the numeric constant used
    to represent that token internally.  Typically, Bison generates these
    on its own, but we give explicit numbers to prevent version parity
    problems (bison 1.25 and earlier start at 258, later versions -- at
    257)
    */
    %token CLASS 258 ELSE 259 FI 260 IF 261 IN 262 
    %token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
    %token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
    %token <symbol>  STR_CONST 275 INT_CONST 276 
    %token <boolean> BOOL_CONST 277
    %token <symbol>  TYPEID 278 OBJECTID 279 
    %token ASSIGN 280 NOT 281 LE 282 ERROR 283
    
    /*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
    /**************************************************************************/
    
    /* Complete the nonterminal list below, giving a type for the semantic
    value of each non terminal. (See section 3.6 in the bison 
    documentation for details). */
    
  /* Declare types for the grammar's non-terminals. */
  %type <program> program
  %type <class_> class
  %type <features> class_list
  %type <features> features_list
  %type <features> features
  %type <feature> feature
  %type <formals> formals
  %type <formal> formal
  %type <expressions> expr
  %type <cases> case_branch_list
  %type <case_> case_branch


    %right ASSIGN
    %left NOT
    %nonassoc LE '<' '='
    %left '+' '-'
    %left '*' '/'
    %left ISVOID
    %left '~'
    %left '@'
    %left '.'

    %%
    /* Think about what this grammar means; a program is made up of a list of one or more classes */
    /* Definição das regras da gramática Cool */
    program : class_list { 
                /* Salva o nó raiz da árvore de sintaxe abstrata em uma variável global @$ 
                * Veja a seção 6.5 no arquivo Tour of Cool para mais informações */
                @$ = @1; 
                ast_root = program($1); 
            }
            ;

    class_list  : class {

                    $$ = single_Classes($1);

                    parse_results = $$; }
                | class_list class {
                    $$ = append_Classes($1,single_Classes($2));
                    parse_results = $$; }
                ;
    
    class     : CLASS TYPEID '{' features_list '}' ';' {
                    $$ = class_($2, idtable.add_string("Object"), $4, stringtable.add_string(curr_filename)); }
                | CLASS TYPEID INHERITS TYPEID '{' features_list '}' ';' {
                    $$ = class_($2, $4, $6, stringtable.add_string(curr_filename)); }

                | CLASS TYPEID '{' error '}' ';' { yyclearin; $$ = NULL; }
                | CLASS error '{' features_list '}' ';' { yyclearin; $$ = NULL; }
                | CLASS error '{' error '}' ';' { yyclearin; $$ = NULL; }
                ;

    /* Lista de features: pode ser vazia ou conter uma ou mais features */
    features_list : features { $$ = $1; }
                | empty_list { $$ = $1; }
                ;

    /* Lista de features vazia */
    empty_list : /* Vazia */ { $$ = nil_Features(); };

    /* Pode ser um único atributo ou um método, ou uma lista de features seguida por uma feature */
    features : feature ';' { $$ = single_Features($1); }
            | multiple_features { $$ = $1; }
            | error ';' { yyclearin; $$ = NULL; }
            ;

    feature : method_feature { $$ = $1; }
            | attribute_feature { $$ = $1; }
            ;

    method_feature : OBJECTID '(' formals ')' ':' TYPEID '{' expr '}' {
                      $$ = method($1, $3, $6, $8);
                    }

    attribute_feature : OBJECTID ':' TYPEID { $$ = attr($1, $3, no_expr()); }
                        | OBJECTID ':' TYPEID ASSIGN expr { $$ = attr($1, $3, $5); }
                ;

    formals : non_empty_formals
            | /* Vazio */ { $$ = nil_Formals(); }
            ;

    non_empty_formals : formal { $$ = single_Formals($1); }
                      | non_empty_formals ',' formal {
                          $$ = append_Formals($1, single_Formals($3));
                        }
                      ;

    formal : OBJECTID ':' TYPEID {
              $$ = formal($1, $3);
            }
          ;

    expression : basic_expression { $$ = $1; }
           | conditional_expression { $$ = $1; }
           | loop_expression { $$ = $1; }
           | block_expression { $$ = $1; }
           | let_expression { $$ = $1; }
           | case_expression { $$ = $1; }
           | new_expression { $$ = $1; }
           | isvoid_expression { $$ = $1; }
           | arithmetic_expression { $$ = $1; }
           | logical_expression { $$ = $1; }
           ;

    basic_expression : OBJECTID ASSIGN expr { $$ = assign($1, $3); }
                        | basic_expression '.' OBJECTID '(' param_expr ')' { $$ = dispatch($1, $3, $5); }
                        | basic_expression '@' TYPEID '.' OBJECTID '(' param_expr ')' { $$ = static_dispatch($1, $3, $5, $7); }
                        | OBJECTID '(' param_expr ')' { $$ = dispatch(object(idtable.add_string("self")), $1, $3); }
                        | INT_CONST { $$ = int_const($1); }
                        | STR_CONST { $$ = string_const($1); }
                        | BOOL_CONST { $$ = bool_const($1); }
                        | '(' expr ')' { $$ = $2; }

    conditional_expression : IF expr THEN expr ELSE expr FI { $$ = cond($2, $4, $6); }
    loop_expression : WHILE expr LOOP expr POOL { $$ = loop($2, $4); }

    block_expression : '{' one_or_more_expr '}' { $$ = block($2); }
    let_expression : LET let_expr { $$ = $2; }

    case_expression : CASE expr OF case_branch_list ESAC { $$ = typcase($2, $4); }
    new_expression : NEW TYPEID { $$ = new_($2); }
    isvoid_expression : ISVOID expr { $$ = isvoid($2); }

    arithmetic_expression : | expr '+' expr { $$ = plus($1, $3); }
                            | expr '-' expr { $$ = sub($1, $3); }
                            | expr '*' expr { $$ = mul($1, $3); }
                            | expr '/' expr { $$ = divide($1, $3); }

    logical_expression :  | '~' expr { $$ = neg($2); }
                          | expr '<' expr { $$ = lt($1, $3); }
                          | expr LE expr { $$ = leq($1, $3); }
                          | expr '=' expr { $$ = eq($1, $3); }
                          | NOT expr { $$ = comp($2); }


    let_expr    : OBJECTID ':' TYPEID IN expr { $$ = let($1, $3, no_expr(), $5); }
                | OBJECTID ':' TYPEID ASSIGN expr IN expr { $$ = let($1, $3, $5, $7); }
                | OBJECTID ':' TYPEID ',' let_expr { $$ = let($1, $3, no_expr(), $5); }
                | OBJECTID ':' TYPEID ASSIGN expr ',' let_expr { $$ = let($1, $3, $5, $7); }
                | error IN expr { yyclearin; $$ = NULL; }
                | error ',' let_expr { yyclearin; $$ = NULL; }
                ;

    one_or_more_expr    : expr ';' { $$ = single_Expressions($1); }
                        | one_or_more_expr expr ';' { $$ = append_Expressions($1, single_Expressions($2)); }

                        | error ';' { yyclearin; $$ = NULL; }
                        ;

    param_expr          : expr { $$ = single_Expressions($1); }
                        | param_expr ',' expr { $$ = append_Expressions($1, single_Expressions($3)); }

                        | { $$ = nil_Expressions(); }
                        ;

    case_branch_list    : case_branch { $$ = single_Cases($1); }

                        | case_branch_list case_branch { $$ = append_Cases($1, single_Cases($2)); }
                        ;
    case_branch         : OBJECTID ':' TYPEID DARROW expr ';' { $$ = branch($1, $3, $5); }
                        ;

    %%

    void yyerror(char *s)
    {
      extern int curr_lineno;
      
      cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
      << s << " at or near ";
      print_cool_token(yychar);
      cerr << endl;
      omerrs++;
      
      if(omerrs>50) {fprintf(stdout, "More than 50 errors\n"); exit(1);}
    }

